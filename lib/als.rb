require 'nokogiri'
require 'zlib'
require 'drum_rack'
require 'simpler'

module ALS
	class Set
		attr_reader :midi_tracks, :tempo, :audio_tracks

		def Set.load(path)
			File.open(path) { |f|
				gz = Zlib::GzipReader.new(f)
				Set.from_xml_document(Nokogiri::XML(gz.read))
			}
		end

		def Set.from_xml_document(doc)
			set = doc.xpath('//Ableton/LiveSet')
			tempo_node = set.xpath('./MasterTrack/DeviceChain/Mixer/Tempo/Manual').first
			tempo = Float(tempo_node['Value'])
			midi_tracks = set.xpath('./Tracks/MidiTrack').map { |track_node|
				MidiTrack.parse(track_node)
			}
			audio_tracks = set.xpath('./Tracks/AudioTrack').map { |track_node|
				AudioTrack.parse(track_node)
			}
			Set.new(tempo: tempo, midi_tracks: midi_tracks, audio_tracks: audio_tracks)
		end

		def initialize(tempo:, midi_tracks:, audio_tracks:)
			@tempo = tempo
			@midi_tracks = midi_tracks
			@audio_tracks = audio_tracks
		end
	end

	class VstPluginInfo
		attr_reader :preset_buffer, :program_number
		def VstPluginInfo.parse(vst_plugin_info_node)
			vst_preset = vst_plugin_info_node.xpath('./Preset/VstPreset').first
			preset_buffer = vst_preset.xpath('./Buffer')
				.first.text
				.gsub("\t", '')
				.gsub("\n", '')
			program_number = Integer(
				vst_preset.xpath('./ProgramNumber').first['Value']
			)
			VstPluginInfo.new(preset_buffer, program_number)
		end

		def initialize(preset_buffer, program_number)
			@preset_buffer = preset_buffer
			@program_number = program_number
		end
	end

	class Track
		def Track.name(track_node)
			track_node.xpath('./Name/EffectiveName').first['Value']
		end

		def Track.device_chain(track_node)
			track_node.xpath('./DeviceChain')
		end
	end

	class AudioTrack
		attr_reader :clips, :name
		def AudioTrack.parse(midi_track_node)
			name = Track.name(midi_track_node)
			device_chain = Track.device_chain(midi_track_node)
			clips = device_chain.xpath(
				'./MainSequencer/ClipSlotList/ClipSlot/ClipSlot/Value/AudioClip'
			).map { |clip_node|
				AudioClip.parse(clip_node)
			}
			AudioTrack.new(name: name, clips: clips)
		end

		def initialize(name:, clips:)
			@name = name
			@clips = clips
		end
	end

	class MidiTrack
		attr_reader :clips, :name, :vst_plugin_info, :drum_rack, :simpler

		def MidiTrack.parse(midi_track_node)
			name = Track.name(midi_track_node)
			device_chain = Track.device_chain(midi_track_node)
			vst_plugin_nodes = device_chain.xpath(
				'./DeviceChain/Devices/PluginDevice/PluginDesc/VstPluginInfo'
			)
			vst_plugin_info = nil
			unless vst_plugin_nodes.empty?
				vst_plugin_info = VstPluginInfo.parse(vst_plugin_nodes.first)
			end
			clips = device_chain.xpath(
				'./MainSequencer/ClipSlotList/ClipSlot/ClipSlot/Value/MidiClip'
			).map { |clip_node|
				MidiClip.parse(clip_node)
			}
			drum_rack = DrumRack.new(midi_track_node.css('DrumGroupDevice'))

			simpler = Simpler.new(midi_track_node)
			MidiTrack.new(name, vst_plugin_info, clips, drum_rack, simpler)
		end

		def initialize(name, vst_plugin_info, clips, drum_rack, simpler)
			@name = name
			@vst_plugin_info = vst_plugin_info
			@clips = clips
			@drum_rack = drum_rack
			@simpler = simpler
		end
	end

	class Clip
		def Clip.name(clip_node)
			clip_node.xpath('./Name').first['Value']
		end
	end

	class AudioClip
		attr_reader :name, :sample_ref, :loop, :time_sig, :sample_volume

		def AudioClip.parse(clip_node)
			sample_ref_nodes = clip_node.xpath('./SampleRef')
			sample_ref = nil
			unless sample_ref_nodes.empty?
				sample_ref = SampleRef.parse(sample_ref_nodes.first)
			end

			loop_nodes = clip_node.xpath('./Loop')
			loop_obj = nil
			unless loop_nodes.empty?
				loop_obj = Loop.parse(loop_nodes.first)
			end
			AudioClip.new(
				name: Clip.name(clip_node),
				sample_ref: sample_ref,
				loop: loop_obj,
				time_sig: TimeSignature.parse(clip_node.xpath('./TimeSignature')),
				sample_volume: Float(clip_node.xpath('./SampleVolume').first['Value'])
			)
		end

		def initialize(name:, sample_ref:, loop:, time_sig:, sample_volume:)
			@name = name
			@sample_ref = sample_ref
			@loop = loop
			@time_sig = time_sig
			@sample_volume = sample_volume
		end
	end

	class TimeSignature
		attr_reader :numerator, :denominator
		def TimeSignature.parse(time_sig_node)
			remoteable_time_signature = time_sig_node.xpath(
				'./TimeSignatures/RemoteableTimeSignature'
			).first
			numerator = remoteable_time_signature.xpath('./Numerator').first['Value']
			denominator = remoteable_time_signature.xpath('./Denominator').first['Value']
			TimeSignature.new(
				numerator: Integer(numerator),
				denominator: Integer(denominator)
			)
		end

		def initialize(numerator:, denominator:)
			@numerator = numerator
			@denominator = denominator
		end
	end

	class Loop
		attr_reader :start_time, :end_time
		def Loop.parse(loop_node)
			start_time = Float(loop_node.xpath('./LoopStart').first['Value'])
			end_time = Float(loop_node.xpath('./LoopEnd').first['Value'])
			Loop.new(start_time: start_time, end_time: end_time)
		end

		def initialize(start_time:, end_time:)
			@start_time = start_time
			@end_time = end_time
		end
	end

	class MidiClip
		attr_reader :notes, :name

		def MidiClip.parse(clip_node)
			name = Clip.name(clip_node)
			notes = clip_node.xpath('./Notes/KeyTracks/KeyTrack').map { |key_track_node|
				midi_note = Integer(key_track_node.xpath('./MidiKey').first['Value'])
					key_track_node.xpath('./Notes/MidiNoteEvent').map {|note|
						MidiNote.parse(midi_note, note)
					}
			}.flatten
			MidiClip.new(notes: notes, name:name)
		end

		def initialize(notes:, name:)
			@notes = notes
			@name = name
		end
	end

	class SampleRef
		attr_reader :file_path

		def SampleRef.parse(sample_ref_node)
			file_ref = sample_ref_node.xpath('./FileRef').first
			file_name = file_ref.xpath('./Name').first['Value']
			path_components = file_ref.xpath('./RelativePath/RelativePathElement').map {|rp_node|
				rp_node['Dir']
			} + [file_name]
			SampleRef.new(file_path: File.join(path_components))
		end

		def initialize(file_path:)
			@file_path = file_path
		end
	end

	class MidiNote
		attr_reader :midi_note, :start_time,
			:on_velocity, :off_velocity, :duration

		def MidiNote.parse(midi_note, midi_note_event)
			MidiNote.new(
				midi_note: midi_note,
				on_velocity: Float(midi_note_event['Velocity']),
				off_velocity: Integer(midi_note_event['OffVelocity']),
				duration: Float(midi_note_event['Duration']),
				start_time: Float(midi_note_event['Time'])
			)
		end

		def initialize(
			midi_note:, on_velocity:, off_velocity:, duration:, start_time:
		)
			@midi_note = midi_note
			@on_velocity = on_velocity
			@off_velocity = off_velocity
			@duration = duration
			@start_time = start_time
		end
	end
end

class Ableton::AbletonClip < Ableton
	
	def initialize(clip_xml)
		@clip_xml = clip_xml
	end

	def clip_xml
		@clip_xml
	end

	def keys
		@clip_xml.css('KeyTrack')
	end

	def loop_end
		(@clip_xml.css('LoopEnd').first['Value'].to_i / 4).to_s + 'm'
	end

	def events(keys = self.keys)
		array = []
		keys.each do |key|
			note = key.css('MidiKey').first['Value']
			note_name = midi_note_to_note_name(note)
			events = key.css('MidiNoteEvent')
			events.each do |event|
				time = event['Time']
				duration = duration_converter(event['Duration'])
				array.push({ time: time.to_s + ' * 4n', note: note_name, duration: duration })
			end
		end
		return array
	end

	def build_part(instrument)
		Part.new(instrument, events, true, loop_end)
	end

end
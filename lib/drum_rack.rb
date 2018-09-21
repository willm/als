class DrumRack
	def initialize(rack_xml)
		@rack_xml = rack_xml
	end

	def rack_xml
		@rack_xml
	end

	def sample_mapping
		branches = {}
		@rack_xml.css('DrumBranch').each do |xml|
			sample_file = xml.css('MultiSamplePart SampleRef FileRef Name').first['Value']
			note = xml.css('BranchInfo ReceivingNote').first['Value']
			branches[drum_track_note_to_note_name(note)] = sample_file
		end
		return branches
	end

	def drum_track_note_to_note_name(note)
		midi_converter_array.reverse[note.to_i - 9]
	end

	def midi_converter_array
		array = []
		note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
		10.times do |i|
			note_names.each do |n|
				array.push( n + (i-2).to_s)
			end
		end
		return array
	end
end

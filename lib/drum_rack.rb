require 'note_helpers'

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
			branches[NoteHelpers::drum_track_note_to_note_name(note)] = sample_file
		end
		return branches
	end

end

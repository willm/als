class Ableton::Simpler < Ableton
	def initialize(rack_xml)
		@rack_xml = rack_xml
	end

	def rack_xml
		@rack_xml
	end

	def sample_file
		@rack_xml.css('MultiSamplePart SampleRef FileRef Name').first['Value']
	end

	def root_key
		drum_track_note_to_note_name(@rack_xml.css('MultiSamplePart RootKey').first['Value'])
	end


	def build_sampler(sample_folder_path = '/samples/')
		Sampler.new(self.root_key => sample_folder_path + self.sample_file )
	end
end
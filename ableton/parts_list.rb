class Ableton::PartsList < Audio

	attr_accessor :scripts, :parts

	def initialize(parts)
		@parts = parts
		part_identifiers = parts.map{|p| p.identifier}.join(', ')
		@scripts = ["var #{identifier} = [#{part_identifiers}]"]
	end

	def start_scene
		script = "start_scene(#{self.identifier})"
	end

	def link_parts_to_track
		@parts.each do |part|
			@scripts.push("#{part.identifier}.track = #{self.identifier};")
		end
	end

	def identifier
			"partslist_" + object_id.to_s
	end

end
module NoteHelpers
	def NoteHelpers.drum_track_note_to_note_name(note)
		NoteHelpers.midi_converter_array.reverse[note.to_i - 9]
	end

	def NoteHelpers.midi_converter_array
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

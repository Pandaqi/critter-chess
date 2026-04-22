extends MovementResource
class_name MovementResourceSequence

@export var sequence : Array[PuzzleGrid.Direction] = []
@export var reverse_order := false # whether it's allowed to reverse the sequence as well

func get_moves_for_sequence(cd:CritterData, seq:Array[PuzzleGrid.Direction]) -> Array[CommandMove]:
	var current_cell := cd.get_cell()
	var is_impossible := false
	for dir in seq:
		current_cell = current_cell.get_neighbor_at(dir)
		if not current_cell:
			is_impossible = true
			break
	
	if is_impossible: return []
	return [CommandMove.new(cd, cd.get_cell(), current_cell)]

func get_possible_moves(cd:CritterData, _gen:PuzzleGenerator) -> Array[CommandMove]:
	var arr : Array[CommandMove] = []
	arr += get_moves_for_sequence(cd, sequence)
	
	if reverse_order:
		var sequence_reversed : Array[PuzzleGrid.Direction] = sequence.duplicate(false)
		sequence_reversed.reverse()
		arr += get_moves_for_sequence(cd, sequence_reversed)
	
	return arr

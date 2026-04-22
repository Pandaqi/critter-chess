extends MovementResource
class_name MovementResourceNeighbors

func get_possible_moves(cd:CritterData, gen:PuzzleGenerator) -> Array[CommandMove]:
	# check for pieces on orthogonal neighbors; if so, always return that we can't move at all
	var ortho_dirs := PuzzleGrid.get_orthogonal_directions()
	for dir in ortho_dirs:
		var nb := cd.get_cell().get_neighbor_at(dir)
		if not nb: continue
		if not nb.has_piece(): continue
		return []
	
	return super.get_possible_moves(cd, gen)

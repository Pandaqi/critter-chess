extends MovementResource
class_name MovementResourceTargets

func cell_has_neighbors(cell:CellData) -> bool:
	var ortho_dirs := PuzzleGrid.get_orthogonal_directions()
	for dir in ortho_dirs:
		var nb := cell.get_neighbor_at(dir)
		if not nb: continue
		if not nb.has_piece(): continue
		return true
	return false

func get_possible_moves(cd:CritterData, gen:PuzzleGenerator) -> Array[CommandMove]:
	var moves := super.get_possible_moves(cd, gen)
	var moves_valid : Array[CommandMove] = []
	for move in moves:
		if cell_has_neighbors(move.cell_to): continue
		moves_valid.append(move)
	return moves_valid

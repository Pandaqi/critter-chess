extends MovementResource
class_name MovementResourceRowCol

func get_possible_moves(cd:CritterData, gen:PuzzleGenerator) -> Array[CommandMove]:
	var cur_cell := cd.get_cell()
	var cur_pos := cur_cell.pos
	
	var row := gen.grid.get_row(cur_pos.y)
	for cell in row:
		if cell.has_piece() and not cell == cur_cell: 
			return super.get_possible_moves(cd, gen)
	
	var column := gen.grid.get_column(cur_pos.x)
	for cell in column:
		if cell.has_piece() and not cell == cur_cell: 
			return super.get_possible_moves(cd, gen)
	
	return []

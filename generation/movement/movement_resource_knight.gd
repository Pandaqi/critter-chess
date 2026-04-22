extends MovementResource
class_name MovementResourceKnight

func get_possible_moves(cd:CritterData, _gen:PuzzleGenerator) -> Array[CommandMove]:
	var current_cell := cd.get_cell()
	var arr : Array[CommandMove] = []
	
	for dir in PuzzleGrid.get_diagonal_directions():
		var new_cell := current_cell.get_neighbor_at(dir)
		if not new_cell: continue
		
		var vec := PuzzleGrid.convert_direction_to_vector(dir)
		var dir_1 := PuzzleGrid.convert_vector_to_direction( Vector2i(vec.x, 0) )
		var dir_2 := PuzzleGrid.convert_vector_to_direction( Vector2i(0, vec.y) )
		
		var final_cell_1 := new_cell.get_neighbor_at(dir_1)
		if final_cell_1:
			arr.append(CommandMove.new(cd, current_cell, final_cell_1))
		
		var final_cell_2 := new_cell.get_neighbor_at(dir_2)
		if final_cell_2:
			arr.append(CommandMove.new(cd, current_cell, final_cell_2))
	
	return arr

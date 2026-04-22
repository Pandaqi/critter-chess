extends Resource
class_name MovementResource

@export var directions : Array[PuzzleGrid.Direction]
@export var max_distance := 1
@export var can_jump := false
@export var mystery := false

func is_valid(cmd:CommandMove) -> bool:
	return true

func get_possible_moves(cd:CritterData, gen:PuzzleGenerator) -> Array[CommandMove]:
	var max_dist := max_distance
	if gen.pieces_go_as_far_as_they_can: max_dist = -1
	
	var directions_final : Array[PuzzleGrid.Direction] = directions.duplicate(false)
	var directions_num := directions_final.size()
	if gen.pieces_can_go_backward:
		for i in range(directions_num):
			directions_final.append(PuzzleGrid.get_opposite_direction_of(directions_final[i]))
	
	var arr : Array[CommandMove] = []
	var cells_already_considered : Array[CellData] = []
	for dir in directions_final:
		var cells := gen.grid.get_cells_in_direction(cd.cell, dir, max_dist)
		for cell in cells:
			if cell.has_piece() and not can_jump: break
			if cells_already_considered.has(cell): continue
			arr.append(CommandMove.new(cd, cd.cell, cell))
			cells_already_considered.append(cell)
	return arr

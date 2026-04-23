extends Resource
class_name MovementResource

@export var directions : Array[PuzzleGrid.Direction]
@export var min_distance := -1  # -1 means "listen to puzzle generator settings/defaults for this one"
@export var max_distance := -1
@export var min_jumps := -1
@export var max_jumps := -1
@export var mystery := false

func is_valid(_cmd:CommandMove) -> bool:
	return true

func get_possible_moves(cd:CritterData, gen:PuzzleGenerator) -> Array[CommandMove]:
	var max_dist := 1
	if gen.pieces_go_as_far_as_they_can: max_dist = -1
	if max_distance != -1: max_dist = max_distance
	
	var min_dist := 1
	if min_distance != -1: min_dist = min_distance
	
	var directions_final : Array[PuzzleGrid.Direction] = directions.duplicate(false)
	var directions_num := directions_final.size()
	if gen.pieces_can_go_backward:
		for i in range(directions_num):
			directions_final.append(PuzzleGrid.get_opposite_direction_of(directions_final[i]))
	
	var cur_max_jumps := 0
	if gen.pieces_can_jump: cur_max_jumps = 1
	if max_jumps != -1: cur_max_jumps = max_jumps
	
	var cur_min_jumps := 0
	if min_jumps != -1: cur_min_jumps = min_jumps
	
	var arr : Array[CommandMove] = []
	var cells_already_considered : Array[CellData] = []
	for dir in directions_final:
		var num_jumps := 0
		var distance_traveled := 0
		var cells : Array[CellData] 
		cells.assign( gen.grid.get_cells_in_direction(cd.cell, dir, max_dist) )
		
		for cell in cells:
			distance_traveled += 1
			
			# register jump; continue because we can't land here
			if cell.has_piece(): 
				num_jumps += 1
				continue
			
			# jumped one time too many? don't continue any further
			if num_jumps > cur_max_jumps: break
			
			# to prevent duplicates + wasting time considering cells 2(+) times
			if cells_already_considered.has(cell): continue
			
			# haven't traveled far enough yet? do continue
			if distance_traveled < min_dist: continue
			
			# haven't jumped enough yet? do continue
			# @TODO: check LENGTH of each individual jump (i.e. how many pieces at once)?
			if num_jumps < cur_min_jumps: continue
			
			# we're happy, this is a valid square
			arr.append(CommandMove.new(cd, cd.cell, cell))
			cells_already_considered.append(cell)
	return arr

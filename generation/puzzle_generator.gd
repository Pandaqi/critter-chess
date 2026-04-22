class_name PuzzleGenerator

#region DifficultyProperties

var grid_width_bounds := Vector2i(3,5)
var grid_height_bounds := Vector2i(3,5)

var pieces_allowed : Array[CritterData.Type] = []
var pieces_required : Array[CritterData.Type] = [CritterData.Type.GOAT, CritterData.Type.FOX, CritterData.Type.OWL, CritterData.Type.LADYBUG]

var num_pieces_bounds := Vector2i(4,4)
var num_turns_bounds := Vector2i(6,8)

var pieces_go_as_far_as_they_can := false
var pieces_can_go_backward := false
var pieces_can_start_on_homes := true
var pieces_with_home_percentage := 0.75

var remove_home_upon_completion := true
var allow_mystery_animals := false

var forbid_backtracking := true
var forbid_shuffling := true

#endregion

#region FixedProperties


#endregion

var grid : PuzzleGrid
var pieces : Array[CritterData]
var homes : Array[CellData]
var solution : Array[CommandMove]

#region CoreAlgorithm

func generate() -> void:
	PuzzleSettings.apply_difficulty_properties(self)
	
	var num_tries := 0
	var max_tries := 50
	while true:
		print("PuzzleGenerator | Attempt ", num_tries)
		num_tries += 1
		create_map()
		take_turns()
		var success := clean_up(num_tries >= max_tries)
		if success: break

func create_map() -> void:
	# create an empty grid
	var grid_size := Vector2i(randi_range(grid_width_bounds.x, grid_width_bounds.y), randi_range(grid_height_bounds.x, grid_height_bounds.y))
	
	grid = PuzzleGrid.new()
	grid.creation_callback = func(pos:Vector2i): return CellData.new(pos)
	grid.create(grid_size)
	
	var cells := get_all_cells()
	cells.shuffle()
	
	# place pieces randomly
	var num_pieces := randi_range(num_pieces_bounds.x, num_pieces_bounds.y)
	var piece_types : Array[CritterData.Type] = []
	piece_types += pieces_required
	
	if allow_mystery_animals:
		pieces_allowed += CritterData.get_mystery_types()
	
	if pieces_allowed.size() <= 0: 
		pieces_allowed = pieces_required
	
	while piece_types.size() < num_pieces:
		piece_types.append(pieces_allowed.pick_random())
	
	pieces = []
	for i in range(num_pieces):
		var my_type := piece_types[i]
		var piece := CritterData.new(my_type)
		pieces.append(piece)
		var rand_cell : CellData = cells.pop_back()
		rand_cell.add_piece(piece)
		rand_cell.mark_as_start_for(piece)

func take_turns() -> void:
	var num_turns := randi_range(num_turns_bounds.x, num_turns_bounds.y)
	solution = []
	
	var commands := PuzzleCommands.new()
	while solution.size() < num_turns:
		var possible_moves : Array[CommandMove] = []
		for piece in pieces:
			possible_moves += piece.get_possible_moves(self)
		if possible_moves.size() <= 0: break
		
		var move_picked := pick_valid_move(possible_moves)
		if not move_picked: break
		
		commands.execute_command(move_picked)
		solution.append(move_picked)
	
	var num_homes := roundi(pieces_with_home_percentage * pieces.size())
	var pieces_with_home := pieces.duplicate(false)
	pieces_with_home.shuffle()
	pieces_with_home = pieces_with_home.slice(0, num_homes)
	
	homes = []
	for piece in pieces_with_home:
		piece.get_cell().mark_as_home_for(piece.type)
		homes.append(piece.get_cell())

func clean_up(desperate := false) -> bool:
	# required checks; if not passed the puzzle is always illegal and discarded
	if solution.size() < num_turns_bounds.x:
		print("PuzzleGenerator | Attempt Discarded | Too few turns.")
		return false
	
	for piece in pieces:
		var start_cell := piece.get_start_cell()
		if not start_cell.is_home(): continue
		if not pieces_can_start_on_homes:
			print("PuzzleGenerator | Piece starts on home while the configuration disallows this")
			return false
		
		if start_cell.is_home_for(piece.type):
			print("PuzzleGenerator | Piece starts on home of correct type already.")
			return false
	
	# nice-to-have checks that are turned off if we're struggling to find a puzzle
	if not desperate:
		var min_moves_wanted := floori(0.5 * solution.size() / float(pieces.size()))
		var min_distance_wanted := floori(0.33 * grid.size.x)
		for piece in pieces:
			var moved_too_little := piece.path.size() < min_moves_wanted
			if moved_too_little:
				print("PuzzleGenerator | Attempt Discarded | Piece moved too little.")
				return false
			
			var distance_from_home := PuzzleGrid.get_distance_between(piece.get_start_cell(), piece.get_cell())
			var too_close_to_home := distance_from_home < min_distance_wanted
			if too_close_to_home:
				print("PuzzleGenerator | Attempt Discarded | Piece starts too close to home (puzzle likely too easy).")
				return false
	
	# put all pieces back in their place
	for piece in pieces:
		var final_cell := piece.get_cell()
		final_cell.remove_piece(piece)
	for piece in pieces:
		var start_cell := piece.get_start_cell()
		start_cell.add_piece(piece)
	
	# reset any cell data accumulated during generation
	for cell in get_all_cells():
		cell.reset()
	
	return true

#endregion

#region Helpers

# The score is HIGHER (and thus move more likely to be picked) if ...
# > This piece has been moved LESS so far
# > The distance of the move is GREATER
# > The move visits a cell that was previously occupied by (many) OTHER PIECES
func get_move_score(cmd:CommandMove) -> float:
	var num_times_piece_moved := cmd.piece.count_path()
	var move_dist := PuzzleGrid.get_distance_between(cmd.cell_from, cmd.cell_to)
	var num_times_used := cmd.cell_to.count_pieces_in_history()
	return (0.5*move_dist + num_times_used) / float(num_times_piece_moved)

func pick_valid_move(moves:Array[CommandMove]) -> CommandMove:
	var moves_valid : Array[CommandMove] = []
	
	# filter out any that are illegal (due to restrictions/algorithm choices)
	for move in moves:
		if forbid_backtracking and move.piece.is_in_path(move.cell_to): continue
		if forbid_shuffling and move.piece.get_path_from_end(1) == move.cell_to: continue
		moves_valid.append(move)
	
	if moves_valid.size() <= 0: return null
	
	# sort based on what we PREFER
	moves_valid.shuffle()
	moves_valid.sort_custom(func(cmd1:CommandMove, cmd2:CommandMove):
		return get_move_score(cmd1) > get_move_score(cmd2)
	)
	
	# then pick one of the first ones at random
	var index := mini(randi() % 4, moves_valid.size() - 1)
	return moves_valid[index]

func get_all_cells() -> Array[CellData]:
	var arr : Array[CellData]
	arr.assign(grid.cells)
	return arr

func get_pieces_at_home() -> Array[CritterData]:
	var arr : Array[CritterData] = []
	for piece in pieces:
		if not piece.is_at_home(): continue
		arr.append(piece)
	return arr

func all_pieces_are_home() -> bool:
	return get_pieces_at_home().size() >= pieces.size()

func get_homes_filled() -> Array[CellData]:
	return homes.filter(func(h:CellData): 
		if remove_home_upon_completion and (not h.is_home()): return true
		return h.has_piece() and h.is_home_for(h.piece.type)
	)

func all_homes_are_filled() -> bool:
	return get_homes_filled().size() >= homes.size()

func is_in_winning_state() -> bool:
	return all_homes_are_filled()

#endregion

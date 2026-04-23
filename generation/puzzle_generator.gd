class_name PuzzleGenerator

#region DifficultyProperties

var grid_width_bounds := Vector2i(3,5)
var grid_height_bounds := Vector2i(3,5)

var pieces_allowed : Array[String] = []
var pieces_required : Array[String] = []

var num_pieces_bounds := Vector2(0.3, 0.45) # ratio of total number of cells
var num_turns_bounds := Vector2(1.5, 3.0) # ratio of number of pieces

var pieces_go_as_far_as_they_can := false
var pieces_can_go_backward := false
var pieces_can_jump := false

var allow_anonymous_homes := false

var place_collectibles := false
var forbid_backtracking := true

var collectible_ratio := Vector2(0.75, 0.95)

#endregion

#region FixedProperties

var remove_home_upon_completion := false
var pieces_can_start_on_homes := true
var pieces_with_home_percentage := Vector2(0.85, 1.0)

var forbid_shuffling := true

#endregion

var grid : PuzzleGrid
var pieces : Array[CritterData]
var homes : Array[CellData]
var solution : Array[CommandMove]

var min_turns_required : int
var max_turns_allowed : int

#region CoreAlgorithm

func generate() -> void:
	PuzzleSettings.apply_difficulty_properties(self)
	
	allow_anonymous_homes = PuzzleSettings.get_value("allow_anonymous_homes")
	
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
	grid.neighbor_mode = PuzzleGrid.NeighborMode.ALL
	grid.create(grid_size)
	
	var cells := get_all_cells()
	cells.shuffle()
	
	# place pieces randomly
	# @NOTE: This is a stupid hack needed to convert string to enum because Godot can't do enum arrays in the inspector (when I'm setting up these values for the different difficulties), so I just input pieces by STRING and convert that back to the INT behind the scenes
	var pieces_allowed_types : Array[CritterData.Type] = [] 
	pieces_allowed_types.assign( pieces_allowed.map(func(string:String): return CritterData.convert_string_to_type(string)) )
	
	var pieces_required_types : Array[CritterData.Type] = []
	pieces_required_types.assign( pieces_required.map(func(string:String): return CritterData.convert_string_to_type(string)) )
	
	var total_num_cells := grid.cells.size()
	var num_pieces := roundi(randf_range(num_pieces_bounds.x, num_pieces_bounds.y) * total_num_cells)

	var piece_types : Array[CritterData.Type] = []
	piece_types += pieces_required_types
	piece_types.shuffle()
	
	if PuzzleSettings.get_value("allow_mystery_animals"):
		pieces_allowed_types += CritterData.get_mystery_types()
	
	if pieces_allowed_types.size() <= 0: 
		pieces_allowed_types = pieces_required_types
	
	while piece_types.size() < num_pieces:
		piece_types.append(pieces_allowed_types.pick_random())
	
	pieces = []
	for i in range(num_pieces):
		var my_type := piece_types[i]
		var piece := CritterData.new(my_type)
		pieces.append(piece)
		var rand_cell : CellData = cells.pop_back()
		rand_cell.add_piece(piece)
		rand_cell.mark_as_start_for(piece)

func take_turns() -> void:
	min_turns_required = floori(num_turns_bounds.x * count_pieces())
	max_turns_allowed = ceili(num_turns_bounds.y * count_pieces())
	
	var num_turns := randi_range(min_turns_required, max_turns_allowed)
	
	solution = []
	
	# take random turns until we're satisfied
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
	
	# turn the final cells of pieces into their assigned homes
	generate_homes()

	# place collectibles in empty spaces along the way (if needed)
	generate_collectibles()

func generate_homes() -> void:
	var num_homes := roundi(randf_range(pieces_with_home_percentage.x, pieces_with_home_percentage.y) * pieces.size())
	if allow_anonymous_homes: num_homes = pieces.size()
	
	var pieces_with_home := pieces.duplicate(false)
	pieces_with_home.shuffle()
	pieces_with_home = pieces_with_home.slice(0, num_homes)
	
	homes = []
	for piece in pieces_with_home:
		piece.get_cell().mark_as_home_for(piece.type)
		homes.append(piece.get_cell())
	

func generate_collectibles() -> void:
	if not place_collectibles: return
	
	# turn any unused cells into collectibles
	var possible_collectible_dirs : Dictionary[CellData, Array] = {}
	for piece in pieces:
		for i in range(1, piece.path.size()):
			var cell_from := piece.path[i-1]
			var cell_to := piece.path[i]
			if not cell_to.can_receive_collectible(): continue
			var dir := PuzzleGrid.get_direction_between(cell_from, cell_to)
			if dir == PuzzleGrid.Direction.NONE: continue
			if not (cell_to in possible_collectible_dirs): possible_collectible_dirs[cell_to] = []
			possible_collectible_dirs[cell_to].append(dir)
	
	var possible_collectible_cells := possible_collectible_dirs.keys()
	possible_collectible_cells.shuffle()
	var num_options = possible_collectible_cells.size()
	if num_options <= 0: return
	
	var num_collectibles := roundi(randf_range(collectible_ratio.x, collectible_ratio.y) * num_options) 
	for i in range(num_collectibles):
		var cell : CellData = possible_collectible_cells.pop_back()
		var dir : PuzzleGrid.Direction = possible_collectible_dirs[cell].pick_random()
		cell.add_collectible(dir)

func clean_up(desperate := false) -> bool:
	# required checks; if not passed the puzzle is always illegal and discarded
	if solution.size() < min_turns_required:
		print("PuzzleGenerator | Attempt Discarded | Too few turns.")
		return false
	
	for piece in pieces:
		var start_cell := piece.get_start_cell()
		if not start_cell.is_home(): continue
		if (not pieces_can_start_on_homes) or allow_anonymous_homes:
			print("PuzzleGenerator | Piece starts on home while the configuration disallows this")
			return false
		
		if start_cell.is_home_for(piece.type):
			print("PuzzleGenerator | Piece starts on home of correct type already.")
			return false
	
	# nice-to-have checks that are turned off if we're struggling to find a puzzle
	if not desperate:
		var min_moves_wanted := floori(min_turns_required / float(pieces.size()))
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
		if not h.has_piece(): return false
		if allow_anonymous_homes: return true
		return h.is_home_for(h.piece.type)
	)

func all_homes_are_filled() -> bool:
	return get_homes_filled().size() >= homes.size()

func no_collectibles_left() -> bool:
	for cell in get_all_cells():
		if cell.has_collectible(): return false
	return true

func is_in_winning_state() -> bool:
	return all_homes_are_filled() and no_collectibles_left()

func count_pieces() -> int:
	return pieces.size()

#endregion

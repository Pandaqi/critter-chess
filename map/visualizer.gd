extends Node2D
class_name PuzzleVisualizer

var generator : PuzzleGenerator
var commands : PuzzleCommands

@export var cell_scene : PackedScene
var cells : Array[Cell] = []

@export var critter_double : Critter
@export var audio_tap : AudioStreamPlayer2D
@export var audio_direction : AudioStreamPlayer

static var cell_size := Vector2(256.0, 256.0)

enum StateTurn
{
	NONE,
	PICKING_PIECE,
	PICKING_TARGET,
	EXECUTING
}

var state_turn := StateTurn.NONE
var piece_chosen : CritterData
var target_chosen : CellData
var valid_targets : Array[CellData] = []

var piece_chosen_previous : CritterData
var keep_same_piece_selected := true

signal state_turn_changed(st:StateTurn)

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	
	for cell_data in generator.get_all_cells():
		var cell : Cell = cell_scene.instantiate()
		var real_pos := PuzzleGrid.convert_grid_pos_to_real_pos(cell_data.pos, cell_size)
		cell.set_position(real_pos)
		add_child(cell)
		cells.append(cell)
		
		cell.sync_to_data(cell_data)
		cell.area_clickable.clicked.connect(_on_cell_clicked, CONNECT_APPEND_SOURCE_OBJECT)
	
	commands = PuzzleCommands.new()
	commands.prepare_for_play(self)
	
	var solution : Array[PuzzleCommand]
	solution.assign(generator.solution)
	commands.set_solution(solution)
	
	commands.turns_changed.connect(_on_turns_changed)
	
	audio_tap.bus = "UI"
	critter_double.hide()
	for cell in cells:
		cell.play_appear_animation()

func get_cell_from_data(cell_data:CellData) -> Cell:
	return cells[PuzzleGrid.get_index_from_grid_pos(cell_data.pos, generator.grid.size)]

func set_state_turn(st:StateTurn) -> void:
	state_turn = st
	state_turn_changed.emit(state_turn)
	
	if state_turn == StateTurn.EXECUTING:
		execute_turn()

func _on_turns_changed(cur_turn:int, max_turns:int) -> void:
	if cur_turn >= max_turns and not PuzzleSettings.get_value("disable_maximum_turns"): return
	
	cur_turn = clampi(cur_turn, 0, max_turns - 1)
	set_state_turn(StateTurn.PICKING_PIECE)
	
	# in case this is called by an undo or something, this resets us to the proper visual/interactive state
	unselect_piece()
	
	# if the game picks the piece for us, fake a click on the right one
	if not PuzzleSettings.get_value("player_selects_piece"):
		var correct_piece := generator.solution[cur_turn].piece
		var current_cell := correct_piece.get_cell()
		if not current_cell:
			fail("Piece to move is not on the board anymore.")
			return
		
		execute_cell_click(current_cell, true)
		return
	
	# if we have QOL feature turned on of keeping same piece selected
	if keep_same_piece_selected and piece_chosen_previous:
		var current_cell :=  piece_chosen_previous.get_cell()
		if not current_cell: return
		execute_cell_click(current_cell, true)
		return

func fail(err:String) -> void:
	print("PuzzleVisualizer | GameOver | " + err)
	PuzzleFramework.finish_puzzle(false)

func _on_cell_clicked(area:AreaClickable) -> void:
	if commands.is_busy(): return
	execute_cell_click((area.get_target() as Cell).data)

func execute_cell_click(cell_data:CellData, auto_click := false) -> void:
	if state_turn == StateTurn.EXECUTING: return
	
	if state_turn == StateTurn.PICKING_PIECE:
		select_piece_at(cell_data, auto_click)
		return
	
	if state_turn == StateTurn.PICKING_TARGET:
		select_target_at(cell_data)
		return

func select_piece_at(cell_data:CellData, auto_select := false) -> void:
	if not cell_data.has_piece():
		get_cell_from_data(cell_data).on_error()
		print("PuzzleVisualizer | Error | Can't pick cell without piece to move.")
		return

	unselect_piece()
	piece_chosen = cell_data.piece

	valid_targets.assign(piece_chosen.get_possible_moves(generator).map(func(cmd:CommandMove): return cmd.cell_to))
	
	# If the piece is selected for us, and we have no other feedback (e.g. highlighting), then being out of moves is an instant fail because there's no way out
	var should_highlight_moves : bool = PuzzleSettings.get_value("highlight_moves")
	var should_highlight_homes : bool = PuzzleSettings.get_value("highlight_homes")
	
	if valid_targets.size() <= 0 and (not should_highlight_moves) and (not PuzzleSettings.get_value("player_selects_piece")):
		fail("This piece has no valid moves (and moves are not highlighted or pickable by player)")
		return
	
	for cell in cells:
		cell.set_critter_highlighted(cell.data.piece == piece_chosen)
		if should_highlight_moves:
			cell.set_move_highlighted(valid_targets.has(cell.data))
		if should_highlight_homes:
			cell.set_home_highlighted(cell.data.is_home_for(piece_chosen.type))
	
	if not auto_select:
		play_audio_tap(get_cell_from_data(cell_data))
	set_state_turn(StateTurn.PICKING_TARGET)

func unselect_piece(auto_unselect := false) -> void:
	if piece_chosen == null: return
	
	if not auto_unselect:
		play_audio_tap(get_cell_from_data(piece_chosen.get_cell()))
	
	piece_chosen = null
	
	for cell in cells:
		cell.reset_critter_highlighted()
		cell.reset_move_highlighted()
		cell.reset_home_highlighted()
	
	set_state_turn(StateTurn.PICKING_PIECE)

func select_target_at(cell_data:CellData) -> void:
	var can_switch_piece : bool = PuzzleSettings.get_value("player_selects_piece")

	if cell_data.has_piece():
		if can_switch_piece:
			if cell_data.piece == piece_chosen:
				unselect_piece()
			else:
				select_piece_at(cell_data)
		#get_cell_from_data(cell_data).on_error()
		#print("PuzzleVisualizer | Error | Can't move into cell that already contains a piece")
		return
	
	if not valid_targets.has(cell_data):
		get_cell_from_data(cell_data).on_error()
		print("PuzzleVisualizer | Error | This piece's movement type does not allow moving into that cell")
		return
	
	piece_chosen_previous = piece_chosen
	target_chosen = cell_data
	play_audio_tap(get_cell_from_data(target_chosen))
	set_state_turn(StateTurn.EXECUTING)

func play_audio_tap(c:Cell) -> void:
	audio_tap.set_position(c.get_position())
	PuzzleAudio.play_audio_nice(audio_tap)

func execute_turn() -> void:
	var start_cell := piece_chosen.get_cell()
	var cmd := CommandMove.new(piece_chosen, start_cell, target_chosen)
	unselect_piece(true)
	await commands.execute_command(cmd)

func animate_move_command(cmd:CommandMove) -> void:
	var dir := PuzzleGrid.get_direction_between(cmd.cell_from, cmd.cell_to)
	cmd.piece.last_move_dir = dir
	
	if dir != PuzzleGrid.Direction.NONE:
		PuzzleAudio.play_voice(PuzzleGrid.direction_to_audio[dir], audio_direction, "ui/tutorial/directions")
	
	var start_pos := get_cell_from_data(cmd.cell_from).global_position

	critter_double.set_position(start_pos)
	critter_double.show()
	critter_double.sync_to_data(cmd.piece)
	critter_double.z_index = 512
	critter_double.on_landed_on_square()
	
	var cells_between : Array[CellData]
	cells_between.assign( generator.grid.get_cells_between(cmd.cell_from, cmd.cell_to))
	cells_between.append(cmd.cell_to) # always add the target cell too; especially if there is no straight line between, because then this is the ONLY step it takes
	
	var dur := randf_range(0.15, 0.175)
	var tw := get_tree().create_tween()
	var cur_pos := start_pos
	var counter := 0
	for cell in cells_between:
		var target_rot = signf((counter % 2) - 0.5) * randf_range(0.05, 0.1) * PI
		var target_pos := get_cell_from_data(cell).global_position
		var mid_pos := 0.5 * (cur_pos + target_pos) # jump UP a bit instead of going in a straight line
		mid_pos.y -= 128.0
		tw.tween_property(critter_double, "position", mid_pos, dur)
		tw.parallel().tween_property(critter_double, "rotation", target_rot, dur)
		tw.tween_property(critter_double, "position", target_pos, dur)
		tw.parallel().tween_property(critter_double, "rotation", 0.0, dur)
		tw.tween_callback(critter_double.on_landed_on_square)
		cur_pos = target_pos
		counter += 1
	
	tw.tween_callback(critter_double.hide)
	await tw.finished

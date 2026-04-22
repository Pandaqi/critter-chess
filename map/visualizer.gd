extends Node2D
class_name PuzzleVisualizer

var generator : PuzzleGenerator
var commands : PuzzleCommands

@export var cell_scene : PackedScene
var cells : Array[Cell] = []

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

func get_cell_from_data(cell_data:CellData) -> Cell:
	return cells[PuzzleGrid.get_index_from_grid_pos(cell_data.pos, generator.grid.size)]

func set_state_turn(st:StateTurn) -> void:
	state_turn = st
	state_turn_changed.emit(state_turn)
	
	if state_turn == StateTurn.EXECUTING:
		execute_turn()

func _on_turns_changed(cur_turn:int, max_turns:int) -> void:
	if cur_turn >= max_turns: return
	
	set_state_turn(StateTurn.PICKING_PIECE)
	
	# if the game picks the piece for us, fake a click on the right one
	if not PuzzleSettings.get_value("player_selects_piece"):
		var correct_piece := generator.solution[cur_turn].piece
		var current_cell := correct_piece.get_cell()
		if not current_cell:
			fail("Piece to move is not on the board anymore.")
			return
		
		execute_cell_click(current_cell)

func fail(err:String) -> void:
	print("PuzzleVisualizer | GameOver | " + err)
	PuzzleFramework.finish_puzzle(false)

func _on_cell_clicked(area:AreaClickable) -> void:
	if commands.is_busy(): return
	execute_cell_click((area.get_target() as Cell).data)

func execute_cell_click(cell_data:CellData) -> void:
	if state_turn == StateTurn.EXECUTING: return
	
	if state_turn == StateTurn.PICKING_PIECE:
		select_piece_at(cell_data)
		return
	
	if state_turn == StateTurn.PICKING_TARGET:
		select_target_at(cell_data)
		return

func select_piece_at(cell_data:CellData) -> void:
	if not cell_data.has_piece():
		get_cell_from_data(cell_data).on_error()
		print("PuzzleVisualizer | Error | Can't pick cell without piece to move.")
		return
	
	piece_chosen = cell_data.piece

	valid_targets.assign(piece_chosen.get_possible_moves(generator).map(func(cmd:CommandMove): return cmd.cell_to))
	
	# If the piece is selected for us, and we have no other feedback (e.g. highlighting), then being out of moves is an instant fail because there's no way out
	var should_highlight_moves = PuzzleSettings.get_value("highlight_moves")
	if valid_targets.size() <= 0 and (not should_highlight_moves) and (not PuzzleSettings.get_value("player_selects_piece")):
		fail("This piece has no valid moves (and moves are not highlighted or pickable by player)")
		return

	for cell in cells:
		cell.set_critter_highlighted(cell.data.piece == piece_chosen)
		if should_highlight_moves:
			cell.set_move_highlighted(valid_targets.has(cell.data))
	
	set_state_turn(StateTurn.PICKING_TARGET)

func unselect_piece() -> void:
	piece_chosen = null
	
	for cell in cells:
		cell.reset_critter_highlighted()
		cell.reset_move_highlighted()
	
	set_state_turn(StateTurn.PICKING_PIECE)

func select_target_at(cell_data:CellData) -> void:
	if cell_data.has_piece():
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
	
	target_chosen = cell_data
	set_state_turn(StateTurn.EXECUTING)

func execute_turn() -> void:
	var start_cell := piece_chosen.get_cell()
	var cmd := CommandMove.new(piece_chosen, start_cell, target_chosen)
	unselect_piece()
	await commands.execute_command(cmd)

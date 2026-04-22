extends Node2D
class_name Main

var generator : PuzzleGenerator

@export var visualizer : PuzzleVisualizer
@export var cam : PuzzleCamera
@export var ui : UI

func _ready() -> void:
	generator = PuzzleGenerator.new()
	generator.generate()
	
	visualizer.visualize(generator)
	visualizer.commands.turns_exhausted.connect(_on_turns_exhausted)
	visualizer.commands.turns_changed.connect(_on_turns_changed)
	visualizer.commands.turns_changed.connect(ui._on_turns_changed)
	
	cam.set_target(generator.grid.get_real_bounds(visualizer.cell_size))
	
	PuzzleFramework.start_puzzle()

func _on_turns_changed(_cur_turn:int, _max_turns:int) -> void:
	check_game_over()

func _on_turns_exhausted() -> void:
	check_game_over(true)

func check_game_over(forced_end := false) -> void:
	var winning_state := generator.is_in_winning_state()
	if not winning_state and not forced_end: return
	PuzzleFramework.finish_puzzle(winning_state)

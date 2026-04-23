extends CanvasLayer
class_name UI

@export var visualizer : PuzzleVisualizer
@export var label : Label
@export var turn_icon_scene : PackedScene
@export var turn_list_container : Node2D
var turn_icons : Array[TurnIcon] = []
var icon_size := 64.0

func _ready() -> void:
	label.hide()
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()
	
	if PuzzleSettings.get_value("disable_maximum_turns"):
		turn_list_container.hide()

func _on_size_changed() -> void:
	var vp := get_viewport().get_visible_rect().size
	turn_list_container.set_position(Vector2(0.5*vp.x, 16 + 0.5 * icon_size))

func _on_turns_changed(cur_turn:int, max_turns:int) -> void:
	label.set_text("Turn: " + str(cur_turn + 1) + "/" + str(max_turns))
	refresh_turns(cur_turn, max_turns)

func refresh_turns(cur_turn:int, max_turns:int) -> void:
	# create more if needed
	while turn_icons.size() < max_turns:
		var turn_icon : TurnIcon = turn_icon_scene.instantiate()
		turn_list_container.add_child(turn_icon)
		turn_icons.append(turn_icon)
	
	# display properly
	var temp_icon_size : float = icon_size if (max_turns <= 12) else 0.5*icon_size
	var list_offset := -0.5 * (max_turns - 1) * temp_icon_size * Vector2.RIGHT
	for i in range(turn_icons.size()):
		var icon := turn_icons[i]
		var should_display := i < max_turns
		icon.set_visible(should_display)
		if not should_display: continue
		
		var pos := list_offset + i * temp_icon_size * Vector2.RIGHT
		icon.set_position(pos)
		icon.set_size(temp_icon_size)
		
		var type := visualizer.generator.solution[i].piece.type
		if PuzzleSettings.get_value("player_selects_piece"): type = CritterData.Type.NONE
		icon.set_type(type)
		
		var should_highlight := i == cur_turn
		icon.set_focused(should_highlight)
		
		
		
	

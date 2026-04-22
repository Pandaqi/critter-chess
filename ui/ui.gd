extends CanvasLayer
class_name UI

@export var label : Label

func _on_turns_changed(cur_turn:int, max_turns:int) -> void:
	label.set_text("Turn: " + str(cur_turn + 1) + "/" + str(max_turns))

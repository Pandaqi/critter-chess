extends Node2D
class_name TurnIcon

@export var sprite : Sprite2D

var focused := false
var tween_active : Tween

const NON_TYPE_FRAME := 23 # @TODO: update in Affinity

func set_size(s:float) -> void:
	sprite.set_scale(Vector2.ONE * s / 256.0)

func set_type(tp:CritterData.Type) -> void:
	var frm := NON_TYPE_FRAME
	if tp != CritterData.Type.NONE:
		frm = CritterData.get_type_resource_for(tp).frame
	sprite.set_frame(frm)

func set_focused(f:bool) -> void:
	focused = f
	
	if tween_active and tween_active.is_running():
		PuzzleTween.force_tween_completion(tween_active)
		tween_active = null
	
	if focused:
		set_scale(Vector2.ONE)
		modulate.a = 1.0
		tween_active = PuzzleTween.play_popup_tween(self)
	else:
		set_scale(Vector2.ONE * 0.8)
		modulate.a = 0.66

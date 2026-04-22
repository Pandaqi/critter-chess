extends Node2D
class_name Cell

var data : CellData

@export var sprite_tile : Sprite2D
@export var home : Node2D
@export var critter : Critter
@export var area_clickable : AreaClickable

@export var audio_error : AudioStreamPlayer2D

var unhighlight_color := Color(0.5, 0.4, 0.3)

func sync_to_data(cd:CellData) -> void:
	data = cd
	data.changed.connect(_on_data_changed)
	_on_data_changed()

func _on_data_changed() -> void:
	var is_black_tile := (data.pos.x % 2) + (data.pos.y % 2) == 1 
	var tile_frame := 1 if is_black_tile else 0
	sprite_tile.set_frame(tile_frame)
	
	home.hide()
	if data.is_home():
		home.show()
		home.set_type(data.home_for)
	
	critter.hide()
	if data.has_piece():
		critter.show()
		critter.sync_to_data(data.piece)

func on_error() -> void:
	PuzzleAudio.play_audio_nice(audio_error)
	PuzzleTween.play_shake_tween(self)

func set_critter_highlighted(val:bool) -> void:
	critter.modulate = Color.WHITE if val else unhighlight_color
	critter.set_scale(Vector2.ONE * 1.2 if val else Vector2.ONE * 0.8)

func reset_critter_highlighted() -> void:
	critter.modulate = Color.WHITE
	critter.set_scale(Vector2.ONE)

func set_move_highlighted(val:bool) -> void:
	sprite_tile.modulate = Color.WHITE if val else unhighlight_color

func reset_move_highlighted() -> void:
	sprite_tile.modulate = Color.WHITE

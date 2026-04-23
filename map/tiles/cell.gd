extends Node2D
class_name Cell

var data : CellData

@export var sprite_tile : Sprite2D
@export var sprite_outline : Sprite2D
@export var sprite_home_option : Sprite2D
@export var home : Home
@export var critter : Critter
@export var collectible : Collectible
@export var corners : CornerIcons
@export var area_clickable : AreaClickable

@export_group("Effects")
@export var anim_player : AnimationPlayer
@export var anim_player_collectible : AnimationPlayer
@export var particles_collectible : PackedScene

@export_group("Audio")
@export var audio_error : AudioStreamPlayer2D
@export var audio_collectible : AudioStreamPlayer2D
@export var audio_home : AudioStreamPlayer2D
@export var audio_hover : AudioStreamPlayer2D

var unhighlight_color := Color(0.5, 0.4, 0.3)
var tween_active : Tween
var tween_active_critter : Tween
var tween_active_home : Tween

var was_home := false
var had_collectible := false

func _ready() -> void:
	reset_move_highlighted()
	reset_home_highlighted()
	audio_error.bus = "UI"
	audio_hover.bus = "UI"
	area_clickable.hover_changed.connect(_on_hover_changed)

func _on_hover_changed(hovering:bool) -> void:
	if hovering:
		PuzzleAudio.play_audio_nice(audio_hover)

func _process(dt:float) -> void:
	var animation_speed := 17*dt
	
	var target_scale := Vector2.ONE*1.075 if area_clickable.hovering else Vector2.ONE
	set_scale(get_scale().lerp(target_scale, animation_speed))
	
	var target_z := 64 if area_clickable.hovering else 0
	z_index = floori(lerpf(z_index, target_z, animation_speed))
	
	var critter_alpha := 1.0 
	if data.is_home() or data.has_collectible():
		critter_alpha = 0.275 if area_clickable.hovering else 1.0
	critter.modulate.a = lerpf(critter.modulate.a, critter_alpha, animation_speed)

func sync_to_data(cd:CellData) -> void:
	data = cd
	data.changed.connect(_on_data_changed)
	_on_data_changed()

func _on_data_changed() -> void:
	## base tile visuals
	var is_black_tile := (data.pos.x % 2) + (data.pos.y % 2) == 1 
	var tile_frame := 1 if is_black_tile else 0
	if data.home_is_filled(): tile_frame = 2
	sprite_tile.set_frame(tile_frame)
	
	## home visuals
	home.hide()
	var is_home := data.is_home()
	if is_home:
		home.show()
		home.set_type(data.home_for)
	
	if tween_active_home:
		PuzzleTween.force_tween_completion(tween_active_home)
	
	if not is_home and was_home:
		tween_active_home = PuzzleTween.play_popdown_tween(home)
	if is_home and (not was_home):
		tween_active_home = PuzzleTween.play_popup_tween(home)
	
	was_home = is_home
	
	## corner helper visuals
	corners.set_tile_bg(is_black_tile)
	corners.set_data(data)
	
	## critter visuals
	critter.hide()
	if data.has_piece():
		critter.show()
		critter.sync_to_data(data.piece)
	
	## collectible visuals
	var has_collectible := data.has_collectible()
	if has_collectible:
		collectible.set_direction(data.collectible_dir)
	
	if (not has_collectible) and had_collectible:
		anim_player_collectible.play_backwards("collectible_reveal")
		on_collectible_collected()
	if has_collectible and (not had_collectible):
		anim_player_collectible.play("collectible_reveal")
	
	had_collectible = has_collectible

func on_collectible_collected() -> void:
	PuzzleAudio.play_audio_nice(audio_collectible)
	var p : ParticlesTreasure = particles_collectible.instantiate()
	p.set_position(position)
	p.z_index = 512
	get_parent().add_child(p)

func on_error() -> void:
	PuzzleAudio.play_audio_nice(audio_error)
	if tween_active and tween_active.is_running(): PuzzleTween.force_tween_completion(tween_active)
	tween_active = PuzzleTween.play_shake_tween(self)

func set_critter_highlighted(val:bool) -> void:
	critter.modulate = Color.WHITE if val else unhighlight_color
	critter.set_scale(Vector2.ONE * 1.2 if val else Vector2.ONE * 0.8)

func reset_critter_highlighted() -> void:
	critter.modulate = Color.WHITE
	critter.set_scale(Vector2.ONE)

func set_move_highlighted(val:bool) -> void:
	sprite_outline.set_visible(val)
	sprite_tile.modulate = Color.WHITE if val else unhighlight_color

func set_home_highlighted(val:bool) -> void:
	if val: anim_player.play("home_highlight")
	sprite_home_option.set_visible(val)

func reset_move_highlighted() -> void:
	sprite_outline.hide()
	sprite_tile.modulate = Color.WHITE

func reset_home_highlighted() -> void:
	anim_player.stop()
	sprite_home_option.hide()

func play_appear_animation() -> void:
	PuzzleTween.play_popup_tween(self)

func do_happy_jump() -> void:
	PuzzleAudio.play_audio_nice(audio_home)
	if tween_active_critter: PuzzleTween.force_tween_completion(tween_active_critter)
	tween_active_critter = PuzzleTween.play_jump_tween(critter, Vector2(64,92), Vector2(0.2, 0.4))
	await tween_active_critter.finished

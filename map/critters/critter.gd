extends Node2D
class_name Critter

var data : CritterData

@export var sprite : Sprite2D

@export var arrow_container : Node2D
@export var arrow_scene : PackedScene
var arrows : Array[Arrow]

@export var audio_thud : AudioStreamPlayer2D
@export var particles_thud : CPUParticles2D

func sync_to_data(cd:CritterData) -> void:
	data = cd
	_on_data_changed()

func _on_data_changed() -> void:
	sprite.set_frame(data.get_type_resource().frame)
	
	var vec := PuzzleGrid.convert_direction_to_vector(data.last_move_dir)
	sprite.flip_h = (vec.x < 0)
	
	# filter out any "duplicate" directions (opposites of other ones)
	# because that just looks messy visually and is not needed because backwards movement is enabled
	var dirs_all := data.get_movement_resource().directions
	var dirs : Array[PuzzleGrid.Direction] = []
	for dir in dirs_all:
		var dir_opposite := PuzzleGrid.get_opposite_direction_of(dir)
		if dirs.has(dir_opposite): continue
		dirs.append(dir)
	
	# create more arrows if needed
	while arrows.size() < dirs.size():
		var new_arrow : Arrow = arrow_scene.instantiate()
		arrow_container.add_child(new_arrow)
		arrows.append(new_arrow)
	
	# display/hide the right ones (with right directions)
	for i in range(arrows.size()):
		var should_display := i < dirs.size()
		arrows[i].set_visible(should_display)
		if not should_display: continue
		arrows[i].set_dir(dirs[i])

func set_type(tp:CritterData.Type) -> void:
	sprite.set_frame(CritterData.get_type_resource_for(tp).frame)

func on_landed_on_square() -> void:
	# to ensure it keeps existing even when the fake double critter is hidden
	if particles_thud.get_parent() == self:
		remove_child(particles_thud)
		get_parent().add_child(particles_thud)
	
	particles_thud.global_position = global_position
	particles_thud.restart()
	particles_thud.set_emitting(true)
	PuzzleAudio.play_audio_nice(audio_thud)

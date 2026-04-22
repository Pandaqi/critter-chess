extends Node2D
class_name Collectible

@export var sprite_arrow : Sprite2D

func set_direction(dir:PuzzleGrid.Direction) -> void:
	var rot := Vector2(PuzzleGrid.convert_direction_to_vector(dir)).angle()
	sprite_arrow.set_rotation(rot)

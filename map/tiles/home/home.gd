extends Node2D
class_name Home

@export var sprite_shadow : Sprite2D
@export var sprite_base : Sprite2D
@export var critter : Critter

func set_type(tp:CritterData.Type) -> void:
	if PuzzleSettings.get_difficulty_property("allow_anonymous_homes"): 
		critter.hide()
	critter.set_type(tp)

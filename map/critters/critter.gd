extends Node2D
class_name Critter

var data : CritterData

@export var sprite : Sprite2D

func sync_to_data(cd:CritterData) -> void:
	data = cd
	_on_data_changed()

func _on_data_changed() -> void:
	sprite.set_frame(data.get_type_resource().frame)

func set_type(tp:CritterData.Type) -> void:
	sprite.set_frame(CritterData.get_type_resource_for(tp).frame)

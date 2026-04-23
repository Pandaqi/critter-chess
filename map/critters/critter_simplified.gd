extends Sprite2D
class_name CritterSimplified

func set_type(tp:CritterData.Type) -> void:
	set_frame(CritterData.get_type_resource_for(tp).frame)

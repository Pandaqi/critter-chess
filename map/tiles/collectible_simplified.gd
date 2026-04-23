extends Sprite2D
class_name CollectibleSimplified

func set_direction(dir:PuzzleGrid.Direction) -> void:
	set_rotation(Vector2(PuzzleGrid.convert_direction_to_vector(dir)).angle())

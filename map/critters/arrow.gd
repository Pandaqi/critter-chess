extends Node2D
class_name Arrow

func set_dir(dir:PuzzleGrid.Direction) -> void:
	if dir == PuzzleGrid.Direction.NONE: return
	var rot := Vector2(PuzzleGrid.convert_direction_to_vector(dir)).angle()
	set_rotation(rot)

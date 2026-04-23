extends CanvasLayer
class_name Background

@export var texture_rect : TextureRect
@export var textures : Array[Texture2D] = []
@export var seeded := false

func _ready() -> void:
	var tex_index : int = PuzzleFramework.puzzle_seed % textures.size()
	if not seeded: tex_index = randi() % textures.size()
	texture_rect.texture = textures[tex_index]

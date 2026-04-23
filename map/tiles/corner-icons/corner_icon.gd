extends Node2D
class_name CornerIcon

@export var critter : CritterSimplified
@export var collectible : CollectibleSimplified

var shader_white_tile : ShaderMaterial = preload("res://map/tiles/corner-icons/corner_icon_white_tile.tres")
var shader_black_tile : ShaderMaterial = preload("res://map/tiles/corner-icons/corner_icon_black_tile.tres")

func set_tile_bg(black_tile:bool) -> void:
	var mat := shader_black_tile if black_tile else shader_white_tile
	critter.material = mat
	collectible.material = mat

func set_critter(tp:CritterData.Type) -> void:
	critter.set_type(tp)

func set_collectible(dir:PuzzleGrid.Direction) -> void:
	collectible.set_direction(dir)

func show_type() -> void:
	critter.show()
	collectible.hide()

func show_collectible() -> void:
	critter.hide()
	collectible.show()

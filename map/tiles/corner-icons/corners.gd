extends Node2D
class_name CornerIcons

@export var corner_icons : Array[CornerIcon] = []
@export var sprite_flowers : Sprite2D

var showing_type := false
var showing_collectible := false

func set_tile_bg(black_tile:bool) -> void:
	for corner_icon in corner_icons:
		corner_icon.set_tile_bg(black_tile)

func set_data(data:CellData) -> void:
	set_completed(data.home_is_filled())
	set_home_type(data)
	set_collectible(data.collectible_dir)
	
	# if we don't have a piece obscuring stuff, no need to show reminders at all
	var must_show := showing_collectible or showing_type
	if not data.has_piece() and not data.has_collectible(): must_show = false
	set_visible(must_show)

func set_home_type(data:CellData) -> void:
	showing_type = false
	
	if not data.is_home(): return
	if PuzzleSettings.get_difficulty_property("allow_anonymous_homes"): return
	
	var tp := data.home_for
	for corner_icon in corner_icons:
		corner_icon.set_critter(tp)
		corner_icon.show_type()
	
	showing_type = true
	
func set_collectible(dir:PuzzleGrid.Direction) -> void:
	showing_collectible = false
	
	if dir == PuzzleGrid.Direction.NONE: return
	
	var counter := 0
	for corner_icon in corner_icons:
		corner_icon.set_collectible(dir)
		if not showing_type or (counter % 2) == 1: corner_icon.show_collectible()
		counter += 1
	
	showing_collectible = true

func set_completed(val:bool) -> void:
	sprite_flowers.set_visible(val)
	for corner_icon in corner_icons:
		corner_icon.set_visible(not val)

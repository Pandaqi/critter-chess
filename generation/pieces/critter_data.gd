extends RefCounted
class_name CritterData

enum Type
{
	NONE,
	GOAT,
	FOX,
	OWL,
	LADYBUG,
	BUNNY,
	SNAIL,
	HORSE,
	SQUIRREL,
	BEAR,
	HEDGEHOG,
	MOUSE,
	DEER,
	FROG,
	DONKEY,
	RACCOON,
	BEAVER,
	BUTTERFLY,
	WHALE,
	BIRD,
	CAT,
	OWL_ALT,
	BUNNY_ALT,
	CHICK
}

var type : CritterData.Type
var cell : CellData
var path : Array[CellData]
var last_move_dir := PuzzleGrid.Direction.NONE

# @TODO: a better place to put this? Global autoload?
static var type_library : Dictionary[CritterData.Type, CritterResource] = {
	CritterData.Type.GOAT: load("res://generation/pieces/critter_goat.tres"),
	CritterData.Type.FOX: load("res://generation/pieces/critter_fox.tres"),
	CritterData.Type.OWL: load("res://generation/pieces/critter_owl.tres"),
	CritterData.Type.LADYBUG: load("res://generation/pieces/critter_ladybug.tres"),
	CritterData.Type.BEAR: load("res://generation/pieces/critter_bear.tres"),
	CritterData.Type.CAT: load("res://generation/pieces/critter_cat.tres"),
	CritterData.Type.DEER: load("res://generation/pieces/critter_deer.tres"),
	CritterData.Type.HEDGEHOG: load("res://generation/pieces/critter_hedgehog.tres"),
	CritterData.Type.RACCOON: load("res://generation/pieces/critter_raccoon.tres"),
	CritterData.Type.SQUIRREL: load("res://generation/pieces/critter_squirrel.tres"),
	CritterData.Type.BEAVER: load("res://generation/pieces/critter_beaver.tres"),
	CritterData.Type.FROG: load("res://generation/pieces/critter_frog.tres"),
	CritterData.Type.MOUSE: load("res://generation/pieces/critter_mouse.tres"),
	CritterData.Type.SNAIL: load("res://generation/pieces/critter_snail.tres"),
	CritterData.Type.WHALE: load("res://generation/pieces/critter_whale.tres"),
	CritterData.Type.CHICK: load("res://generation/pieces/critter_chick.tres"),
	CritterData.Type.HORSE: load("res://generation/pieces/critter_horse.tres"),
	CritterData.Type.BUTTERFLY: load("res://generation/pieces/critter_butterfly.tres"),
	CritterData.Type.BUNNY: load("res://generation/pieces/critter_bunny.tres"),
}

signal changed()

func _init(tp:CritterData.Type) -> void:
	type = tp

#region (Current) Cell Management

func add_to_cell(c:CellData) -> void:
	cell = c
	path.append(cell)
	changed.emit()

func remove_from_cell() -> void:
	cell = null
	changed.emit()

func get_cell() -> CellData:
	return cell

func is_at_home() -> bool:
	if not cell: return true # if we're removed from the board, we're considered at home
	return cell.is_home_for(type)

#endregion

#region Path

func reset() -> void:
	path = [get_cell()]
	last_move_dir = PuzzleGrid.Direction.NONE

func get_start_cell() -> CellData:
	return path.front()

func get_end_cell() -> CellData:
	return path.back()

func count_path() -> int:
	return path.size()

func count_moves() -> int:
	return count_path() - 1 # first element is just initialization, not a move, hence the difference

func is_in_path(c:CellData) -> bool:
	return path.has(c)

func get_path_from_start(idx_off:int) -> CellData:
	var idx := mini(idx_off, count_path() - 1)
	return path[idx]

func get_path_from_end(idx_off:int) -> CellData:
	var idx := maxi(count_path() - 1 - idx_off, 0)
	return path[idx]

#endregion

#region Type/Movement Modules

static func convert_string_to_type(string:String) -> CritterData.Type:
	var type_keys := CritterData.Type.keys()
	return type_keys.find(string.to_upper()) as CritterData.Type

static func convert_type_to_string(tp:CritterData.Type) -> String:
	var type_keys := CritterData.Type.keys()
	return type_keys[tp]

static func get_mystery_types() -> Array[CritterData.Type]:
	var arr : Array[CritterData.Type] = []
	for type_key in type_library:
		if not get_type_resource_for(type_key).movement.mystery: continue
		arr.append(type_key)
	return arr

static func get_type_resource_for(tp:Type) -> CritterResource:
	return type_library[tp]

func is_mystery_critter() -> bool:
	return get_movement_resource().mystery

func get_type_resource() -> CritterResource:
	return get_type_resource_for(type)

func get_movement_resource() -> MovementResource:
	return get_type_resource().movement

# @NOTE: This function should be the only thing we need to call while PLAYING the game (to know exactly, without exception, where a piece can go)
# The PuzzleGenerator, though, can do further filtering/checking on top just to make the algorithm nicer
func get_possible_moves(gen:PuzzleGenerator) -> Array[CommandMove]:
	var all_moves := get_movement_resource().get_possible_moves(self, gen)
	var valid_moves := all_moves.filter(func(cmd:CommandMove): return cmd.is_valid())
	return valid_moves

#endregion

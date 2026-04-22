extends RefCounted
class_name CritterData

enum Type
{
	NONE,
	GOAT,
	FOX,
	OWL,
	LADYBUG
}

var type : CritterData.Type
var cell : CellData
var path : Array[CellData]

# @TODO: a better place to put this? Static var? Global autoload?
static var type_library : Dictionary[CritterData.Type, CritterResource] = {
	CritterData.Type.GOAT: preload("res://generation/pieces/critter_goat.tres"),
	CritterData.Type.FOX: preload("res://generation/pieces/critter_fox.tres"),
	CritterData.Type.OWL: preload("res://generation/pieces/critter_owl.tres"),
	CritterData.Type.LADYBUG: preload("res://generation/pieces/critter_ladybug.tres")
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

func get_start_cell() -> CellData:
	return path.front()

func get_end_cell() -> CellData:
	return path.back()

func count_path() -> int:
	return path.size()

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

static func get_mystery_types() -> Array[CritterData.Type]:
	var arr : Array[CritterData.Type] = []
	for type in type_library:
		if not get_type_resource_for(type).movement.mystery: continue
		arr.append(type)
	return arr

static func get_type_resource_for(tp:Type) -> CritterResource:
	return type_library[tp]

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

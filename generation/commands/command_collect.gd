extends PuzzleCommand
class_name CommandCollect

var cell : CellData
var coll_dir_removed : PuzzleGrid.Direction

func _init(c:CellData):
	cell = c

func do(_cmds:PuzzleCommands) -> bool:
	coll_dir_removed = cell.collectible_dir
	cell.remove_collectible()
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	cell.add_collectible(coll_dir_removed)
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandCollect): return false
	return cell == cmd.cell

func is_valid() -> bool:
	if not cell.has_collectible(): return false
	return true

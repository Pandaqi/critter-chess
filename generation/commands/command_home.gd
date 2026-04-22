extends PuzzleCommand
class_name CommandHome

var piece : CritterData
var cell : CellData

func _init(pc:CritterData, c:CellData):
	piece = pc
	cell = c

func do(_cmds:PuzzleCommands) -> bool:
	cell.unmark_as_home()
	cell.remove_piece(piece)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	cell.add_piece(piece)
	cell.mark_as_home_for(piece.type)
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandHome): return false
	return cell == cmd.cell

func is_valid() -> bool:
	if not cell.has_piece() or cell.piece != piece: return false
	return true

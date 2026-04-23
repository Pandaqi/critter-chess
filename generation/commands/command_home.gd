extends PuzzleCommand
class_name CommandHome

var piece : CritterData
var cell : CellData
var removed := false

func _init(pc:CritterData, c:CellData):
	piece = pc
	cell = c

func do(cmds:PuzzleCommands) -> bool:
	
	if cmds.visualizer:
		await cmds.visualizer.get_cell_from_data(cell).do_happy_jump()
		if not cmds.visualizer.generator.remove_home_upon_completion: return true
	
	removed = true
	cell.unmark_as_home()
	cell.remove_piece(piece)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	if not removed: return true
	cell.add_piece(piece)
	cell.mark_as_home_for(piece.type)
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandHome): return false
	return cell == cmd.cell

func is_valid() -> bool:
	if not cell.has_piece() or cell.piece != piece: return false
	return true

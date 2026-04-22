extends PuzzleCommand
class_name CommandMove

# this `piece` data is only a sanity check; IS the piece we want to move STILL IN THAT CELL?
var piece : CritterData 
var cell_from : CellData
var cell_to : CellData

func _init(pc:CritterData, sc:CellData, tc:CellData):
	starts_new_turn = true
	
	piece = pc
	cell_from = sc
	cell_to = tc

func do(cmds:PuzzleCommands) -> bool:
	cell_from.remove_piece(piece)
	cell_to.add_piece(piece)
	
	if cmds.generating: return true
	
	if cell_to.is_home_for(piece.type) and cmds.visualizer.generator.remove_home_upon_completion:
		await cmds.execute_command(CommandHome.new(piece, cell_to))

	return true

func undo(_cmds:PuzzleCommands) -> bool:
	cell_to.remove_piece(piece)
	cell_from.add_piece(piece)
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandMove): return false
	return piece == cmd.piece and cell_from == cmd.cell_from and cell_to == cmd.cell_to

func is_valid() -> bool:
	if cell_to.has_piece(): return false
	if not piece.get_movement_resource().is_valid(self): return false
	return true

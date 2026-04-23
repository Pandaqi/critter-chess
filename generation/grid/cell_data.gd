extends PuzzleCell
class_name CellData

var piece : CritterData = null
var start_for : CritterData
var home_for := CritterData.Type.NONE
var collectible_dir := PuzzleGrid.Direction.NONE
var piece_history : Array[CritterData] = []

#region PiecesInside

func reset() -> void:
	piece_history = []

func has_piece() -> bool:
	return piece != null

func add_piece(p:CritterData) -> void:
	if has_piece(): 
		print("CellData | Error | Can't add piece to cell already occupied -> ", pos)
		return
	piece = p
	piece.add_to_cell(self)
	piece_history.append(p)
	changed.emit()

func remove_piece(p:CritterData) -> void:
	if piece != p: 
		print("CellData | Error | Can't remove piece from cell that does not have it -> ", pos)
		return
	piece.remove_from_cell()
	piece = null
	changed.emit()

func count_pieces_in_history() -> int:
	return piece_history.size()

#endregion

#region Collectibles

func has_collectible() -> bool:
	return collectible_dir != PuzzleGrid.Direction.NONE

func collectible_matches(dir:PuzzleGrid.Direction) -> bool:
	return collectible_dir == dir

func add_collectible(cd:PuzzleGrid.Direction) -> void:
	collectible_dir = cd
	changed.emit()

func remove_collectible() -> void:
	collectible_dir = PuzzleGrid.Direction.NONE
	changed.emit()

func can_receive_collectible() -> bool:
	return (not is_home()) and (not has_collectible())

#endregion

#region Start/End (Home/Target)

func mark_as_start_for(cd:CritterData) -> void:
	start_for = cd
	changed.emit()

func unmark_as_start() -> void:
	start_for = null
	changed.emit()

func is_start() -> bool:
	return start_for != null

func is_start_for(cd:CritterData) -> bool:
	return start_for == cd

func mark_as_home_for(tp:CritterData.Type) -> void:
	home_for = tp
	changed.emit()

func unmark_as_home() -> void:
	home_for = CritterData.Type.NONE
	changed.emit()

func is_home() -> bool:
	return home_for != CritterData.Type.NONE

func is_home_for(tp:CritterData.Type) -> bool:
	return home_for == tp

func home_is_filled() -> bool:
	return has_piece() and piece.type == home_for

#endregion

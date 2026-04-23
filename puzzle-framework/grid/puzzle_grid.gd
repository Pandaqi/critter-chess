class_name PuzzleGrid

var grid : Array
var cells : Array[PuzzleCell]
var size : Vector2i

var creation_callback : Callable = func(pos:Vector2i): return PuzzleCell.new(pos)

enum NeighborMode
{
	NONE,
	HORIZONTAL,
	VERTICAL,
	DIAGONAL,
	ORTHOGONAL,
	ALL
}

enum Direction
{
	NONE,
	RIGHT,
	BOTTOM_RIGHT,
	DOWN,
	BOTTOM_LEFT,
	LEFT,
	TOP_LEFT,
	UP,
	TOP_RIGHT
}

var neighbor_mode := NeighborMode.ORTHOGONAL
var neighbor_directions : Dictionary[NeighborMode, Array] = {
	NeighborMode.NONE: [],
	NeighborMode.HORIZONTAL: [Vector2i.LEFT, Vector2i.RIGHT],
	NeighborMode.VERTICAL: [Vector2i.UP, Vector2i.DOWN],
	NeighborMode.DIAGONAL: [Vector2i(-1,-1), Vector2i(1,-1), Vector2i(1,1), Vector2i(-1,1)],
	NeighborMode.ORTHOGONAL: [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP],
	NeighborMode.ALL: [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN, Vector2i(-1,-1), Vector2i(1,-1), Vector2i(1,1), Vector2i(-1,1)],
}

static var direction_to_vector : Dictionary[Direction, Vector2i] = {
	Direction.NONE: Vector2i.ZERO,
	Direction.RIGHT: Vector2i.RIGHT,
	Direction.BOTTOM_RIGHT: Vector2i(1,1),
	Direction.DOWN: Vector2i.DOWN,
	Direction.BOTTOM_LEFT: Vector2i(-1,1),
	Direction.LEFT: Vector2i.LEFT,
	Direction.TOP_LEFT: Vector2i(-1,-1),
	Direction.UP: Vector2i.UP,
	Direction.TOP_RIGHT: Vector2i(1,-1)
}

static var vector_to_direction : Dictionary[String, Direction] = {
	"00": Direction.NONE,
	"10": Direction.RIGHT,
	"11": Direction.BOTTOM_RIGHT,
	"01": Direction.DOWN,
	"-11": Direction.BOTTOM_LEFT,
	"-10": Direction.LEFT,
	"-1-1": Direction.TOP_LEFT,
	"0-1": Direction.UP,
	"1-1": Direction.TOP_RIGHT
}

static var direction_to_audio : Dictionary[Direction, String] = {
	Direction.RIGHT: "direction-right.ogg",
	Direction.BOTTOM_RIGHT: "direction-bottom-right.ogg",
	Direction.DOWN: "direction-down.ogg",
	Direction.BOTTOM_LEFT: "direction-bottom-left.ogg",
	Direction.LEFT: "direction-left.ogg",
	Direction.TOP_LEFT: "direction-top-left.ogg",
	Direction.UP: "direction-up.ogg",
	Direction.TOP_RIGHT: "direction-top-right.ogg"
}

static func convert_direction_to_vector(dir:Direction) -> Vector2i:
	if not (dir in direction_to_vector): return Vector2i.ZERO
	return direction_to_vector[dir]

static func convert_vector_to_direction(vec:Vector2i) -> Direction:
	var key := str(vec.x) + str(vec.y)
	if not (key in vector_to_direction): return Direction.NONE
	return vector_to_direction[key]

static func get_opposite_direction_of(dir:Direction) -> Direction:
	return convert_vector_to_direction( -1 * convert_direction_to_vector(dir) )

static func get_orthogonal_directions() -> Array[Direction]:
	return [Direction.RIGHT, Direction.DOWN, Direction.LEFT, Direction.UP]

static func get_diagonal_directions() -> Array[Direction]:
	return [Direction.BOTTOM_RIGHT, Direction.BOTTOM_LEFT, Direction.TOP_LEFT, Direction.TOP_RIGHT]

static func is_horizontal(dir:Direction) -> bool:
	return [Direction.RIGHT, Direction.LEFT].has(dir)

static func is_vertical(dir:Direction) -> bool:
	return [Direction.UP, Direction.DOWN].has(dir)

static func get_distance_between(c1:PuzzleCell, c2:PuzzleCell) -> int:
	return absi(c1.pos.x - c2.pos.x) + absi(c1.pos.y - c2.pos.y)

static func convert_grid_pos_to_real_pos(pos:Vector2i, cell_size:Vector2) -> Vector2:
	return Vector2(pos) * cell_size + Vector2(0.5, 0.5) * cell_size

static func convert_real_pos_to_grid_pos(pos:Vector2, cell_size:Vector2) -> Vector2i:
	return Vector2i((pos / cell_size).floor())

static func get_index_from_grid_pos(pos:Vector2i, grid_size:Vector2i) -> int:
	return pos.x * grid_size.y + pos.y

static func get_grid_pos_from_index(idx:int, grid_size:Vector2i) -> Vector2i:
	return Vector2i(floori(idx / float(grid_size.y)), (idx % grid_size.y))

static func get_direction_between(cell_from:CellData, cell_to:CellData) -> Direction:
	var vec := cell_to.pos - cell_from.pos
	
	var non_uniform_vector := vec.x != 0 and vec.y != 0 and absi(vec.x) != absi(vec.y)
	if non_uniform_vector: return Direction.NONE
	
	var vec_norm := Vector2i(signi(vec.x), signi(vec.y))
	return convert_vector_to_direction(vec_norm)

func create(new_size:Vector2i) -> void:
	size = new_size
	
	grid = []
	cells = []
	
	grid.resize(size.x)
	for x in range(size.x):
		grid[x] = []
		grid[x].resize(size.y)
		for y in range(size.y):
			var new_cell = creation_callback.call(Vector2i(x,y))
			grid[x][y] = new_cell
			cells.append(new_cell)
	
	create_neighbors()

func create_neighbors() -> void:
	if neighbor_mode == NeighborMode.NONE: return
	
	var dirs := get_neighbor_directions() 
	for cell in cells:
		cell.clear_neighbors()
		for dir in dirs:
			var pos := cell.pos + dir
			if is_out_of_bounds(pos): continue
			cell.add_neighbor(get_at(pos))

func get_neighbor_directions() -> Array[Vector2i]:
	var arr : Array[Vector2i] = []
	arr.assign(neighbor_directions[neighbor_mode])
	return arr

func get_at(pos:Vector2i) -> PuzzleCell:
	if is_out_of_bounds(pos): return null
	return grid[pos.x][pos.y]

func is_out_of_bounds(pos:Vector2i) -> bool:
	return pos.x < 0 or pos.x >= size.x or pos.y < 0 or pos.y >= size.y

func get_row(idx:int) -> Array[PuzzleCell]:
	var arr : Array[PuzzleCell] = []
	for x in range(size.x):
		arr.append(grid[x][idx])
	return arr

func get_column(idx:int) -> Array[PuzzleCell]:
	var arr : Array[PuzzleCell] = []
	arr.assign(grid[idx])
	return arr

func get_random_cell() -> PuzzleCell:
	return cells.pick_random()

func get_cells() -> Array[PuzzleCell]:
	return cells

func get_cells_in_direction(start:PuzzleCell, dir := Direction.RIGHT, max_dist := -1) -> Array[PuzzleCell]:
	var cell_to_check := start
	var arr : Array[PuzzleCell] = []
	while cell_to_check:
		cell_to_check = cell_to_check.get_neighbor_at(dir)
		if not cell_to_check: break
		arr.append(cell_to_check)
		if max_dist != -1 and arr.size() >= max_dist: break
	return arr

func get_cells_between(start:PuzzleCell, end:PuzzleCell) -> Array[PuzzleCell]:
	var dir := get_direction_between(start, end)
	if dir == Direction.NONE: return []
	
	var cell_to_check := start
	var arr : Array[PuzzleCell] = []
	while true:
		cell_to_check = cell_to_check.get_neighbor_at(dir)
		if cell_to_check == end: break
		arr.append(cell_to_check)
	
	return arr

func get_real_bounds(cell_size:Vector2) -> Rect2:
	return Rect2(Vector2.ZERO, cell_size * Vector2(size))

func is_edge(cell:CellData) -> bool:
	var pos := cell.pos
	return pos.x == 0 or pos.x == (size.x - 1) or pos.y == 0 or pos.y == (size.y - 1)

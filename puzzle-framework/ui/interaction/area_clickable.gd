extends Area2D
class_name AreaClickable

@export var target : Node2D
@export var size := Vector2.ZERO
@export var col_shape : CollisionShape2D

var hovering := false

signal clicked()
signal hover_changed(h:bool)

func _ready() -> void:
	refresh_size()
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(_vp:Node, ev:InputEvent, _sidx:int) -> void:
	if not (ev is InputEventMouseButton) or (ev is InputEventScreenTouch): return
	if ev.is_pressed(): return
	clicked.emit()

func _on_mouse_entered() -> void:
	hovering = true
	hover_changed.emit(hovering)

func _on_mouse_exited() -> void:
	hovering = false
	hover_changed.emit(hovering)

func refresh_size() -> void:
	if size.length() <= 0.0003: return
	
	var shp := RectangleShape2D.new()
	shp.size = size
	col_shape.shape = shp

func set_size(s:Vector2) -> void:
	size = s
	refresh_size()

func get_target() -> Node2D:
	return target

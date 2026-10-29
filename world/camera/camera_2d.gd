extends Camera2D

@export var zoom_speed := 0.1
@export var min_zoom := 0.25
@export var max_zoom := 10.0

var dragging := false
var last_mouse_pos := Vector2.ZERO
var focus: Node2D
var bounds: Rect2


func _ready():
	make_current()


func _process(_delta: float) -> void:
	refocus()


func _input(event):
	# Zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = (zoom * (1.0 - zoom_speed)).clamp(
				Vector2(min_zoom, min_zoom),
				Vector2(max_zoom, max_zoom),
			)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = (zoom * (1.0 + zoom_speed)).clamp(
				Vector2(min_zoom, min_zoom),
				Vector2(max_zoom, max_zoom),
			)

		# Begin / end drag
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_pos = event.position

	# Drag pan
	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		position -= delta / zoom
		last_mouse_pos = event.position


func refocus() -> void:
	if not focus:
		return

	var focus_position := focus.global_position

	if not bounds:
		global_position = focus_position
		return


	var next_position := global_position
	var viewport_size := get_viewport_rect().size / zoom
	var x_rect := Rect2(
		Vector2(focus_position.x - viewport_size.x / 2.0, next_position.y - viewport_size.y / 2.0),
		viewport_size,
	)

	if bounds.encloses(x_rect):
		next_position.x = focus_position.x

	var y_rect := Rect2(
		Vector2(next_position.x - viewport_size.x / 2.0, focus_position.y - viewport_size.y / 2.0),
		viewport_size,
	)

	if bounds.encloses(y_rect):
		next_position.y = focus_position.y

	global_position = next_position

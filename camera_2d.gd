extends Camera2D

@export var zoom_speed := 0.1
@export var min_zoom := 0.25
@export var max_zoom := 10.0

var dragging := false
var last_mouse_pos := Vector2.ZERO


func _ready():
	make_current()


func _input(event):
	# --- Zoom ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = (zoom * (1.0 - zoom_speed)).clamp(
				Vector2(min_zoom, min_zoom),
				Vector2(max_zoom, max_zoom)
			)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = (zoom * (1.0 + zoom_speed)).clamp(
				Vector2(min_zoom, min_zoom),
				Vector2(max_zoom, max_zoom)
			)

		# --- Begin / end drag ---
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_pos = event.position

	# --- Drag pan ---
	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		position -= delta / zoom
		last_mouse_pos = event.position

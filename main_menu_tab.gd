class_name MainMenuTab extends NinePatchRect

signal activated(tab: MainMenuTab)

const active_texture := preload('res://assets/ui/tab_active.png')
const inactive_texture := preload('res://assets/ui/tab_inactive.png')

@export var is_active := _is_active:
	set(value):
		if value != _is_active:
			_is_active = value
			texture = active_texture if _is_active else inactive_texture
			if is_active:
				activated.emit(self)
	get:
		return _is_active

var _is_active := false


func _ready() -> void:
	is_active = _is_active


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not is_active:
				is_active = true

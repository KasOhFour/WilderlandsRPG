class_name Cursor extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(_delta: float) -> void:
	global_position = get_tree().root.get_viewport().get_mouse_position()

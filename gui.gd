# gui.gd
class_name GUI
extends CanvasLayer

@onready var cursor := $Cursor

var map := {
	WoodChest: WoodChestUI,
}
var lock := false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(_delta: float) -> void:
	cursor.global_position = get_tree().root.get_viewport().get_mouse_position()



func open_ui(node: Node) -> void:
	if lock:
		return

	var maybe_ui: GDScript = map[node.get_script()]
	if not maybe_ui:
		return

	var ui = maybe_ui.from_tscn(node)

	ui_lock(ui)
	add_child(ui)


func ui_lock(ui: Control) -> void:
	lock = true
	ui.tree_exited.connect(func(): lock = false)

class_name InventorySlot extends NinePatchRect


const HIGHLIGHT_ALPHA := 1.00
const NORMAL_ALPHA := 0.52
const LOWLIGHT_ALPHA := 0.45
const HOVERED_SCALE := 1.05
const NORMAL_SCALE := 1.0
const LERP_SPEED := 30.0
const HOVER_ITEM := preload('res://item_ui.tscn')

@onready var item_ui := $ItemUI

var is_hovered := false
var hover_item: ItemUI


func _process(delta: float) -> void:
	if hover_item:
		hover_item.global_position = get_global_mouse_position() + Vector2(-8, -8)
	var alpha_to := NORMAL_ALPHA
	var scale_to := NORMAL_SCALE
	if is_hovered:
		alpha_to = HIGHLIGHT_ALPHA
		scale_to = HOVERED_SCALE
	self_modulate.a = lerp(self_modulate.a, alpha_to, LERP_SPEED * delta)
	item_ui.item_scale = lerp(item_ui.item_scale, scale_to, LERP_SPEED * delta)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not hover_item:
				hover_item = HOVER_ITEM.instantiate()
				add_child(hover_item)
				item_ui.visible = false


func _on_mouse_entered() -> void:
	is_hovered = true


func _on_mouse_exited() -> void:
	is_hovered = false

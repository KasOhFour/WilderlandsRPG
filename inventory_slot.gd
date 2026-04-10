class_name InventorySlot extends NinePatchRect

signal slot_pressed(slot: InventorySlot)


const HIGHLIGHT_ALPHA := 1.00
const NORMAL_ALPHA := 0.52
const LOWLIGHT_ALPHA := 0.45
const HOVERED_SCALE := 1.05
const NORMAL_SCALE := 1.0
const LERP_SPEED := 30.0

var item_ui := _item_ui:
	set(value):
		var orphan: ItemUI = _item_ui
		_item_ui = value
		call_deferred('_reparent', orphan)
	get:
		return _item_ui

var is_hovered := false

@onready var _item_ui := $ItemUI


func _ready() -> void:
	item_ui = _item_ui


func _process(delta: float) -> void:
	var alpha_to := NORMAL_ALPHA
	var scale_to := NORMAL_SCALE
	if is_hovered:
		alpha_to = HIGHLIGHT_ALPHA
		scale_to = HOVERED_SCALE
	self_modulate.a = lerp(self_modulate.a, alpha_to, LERP_SPEED * delta)
	if item_ui:
		item_ui.item_scale = lerp(item_ui.item_scale, scale_to, LERP_SPEED * delta)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			slot_pressed.emit(self)
			call_deferred('_swap_in_hover_item')


func _reparent(orphan: ItemUI):
	if not item_ui:
		if orphan and orphan.get_parent() == self:
			orphan.queue_free()
		return

	if not is_inside_tree():
		return

	if item_ui.get_parent() != self:
		item_ui.reparent(self)
		item_ui.position = Vector2.ZERO


func _swap_in_hover_item():
	var hover_item: ItemUI = GlobalHoverItemManager.hover_item
	GlobalHoverItemManager.hover_item = item_ui
	item_ui = hover_item


func _on_mouse_entered() -> void:
	is_hovered = true


func _on_mouse_exited() -> void:
	is_hovered = false

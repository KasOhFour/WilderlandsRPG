class_name CursorItemManager
extends Node

signal drag_ended()

var isui := _isui:
	set(value):
		var orphan := _isui
		_isui = value
		call_deferred('_reparent', orphan)
	get:
		return _isui
var item_stack: ItemStack:
	set(value):
		isui.item_stack = value
	get:
		return isui.item_stack
var drag := StackDrag.new()
var _isui: ItemStackUI = preload('res://inventory/ui/item_stack_ui.tscn').instantiate()


func is_dragging() -> bool:
	var left_mouse_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	return left_mouse_down and drag.is_active()


func drag_over(stack: ItemStack) -> void:
	if not drag.can_enter(stack):
		return

	item_stack = drag.split_into(stack)
	if drag.is_complete:
		end_drag()


func end_drag() -> void:
	drag.clear()
	drag_ended.emit()


func _ready() -> void:
	isui = _isui
	item_stack = ItemStack.new(null, 0)


func _process(_delta: float) -> void:
	if isui:
		isui.global_position = get_tree().root.get_viewport().get_mouse_position()
		if item_stack:
			isui.visible = not item_stack.is_empty()
	if is_dragging():
		drag.start(item_stack)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			drag.clear()
			drag_ended.emit()


func _reparent(orphan: ItemStackUI) -> void:
	if not isui:
		if orphan and orphan.get_parent() == self:
			orphan.queue_free()
		return

	var cursor_layer := get_tree().get_first_node_in_group('cursor_layer')
	if not cursor_layer:
		Game.gui.add_child(isui)
		return

	cursor_layer.add_child(isui)

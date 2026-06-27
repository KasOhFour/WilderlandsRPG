class_name CursorItemManager
extends Node


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
var hovered_stacks: Dictionary[ItemStack, bool] = {}
var dragging_stack := ItemStack.new(null, 0)
var _isui: ItemStackUI = preload('res://item_stack_ui.tscn').instantiate()


func is_dragging() -> bool:
	var left_mouse_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	return left_mouse_down and not hovered_stacks.is_empty()


func _ready() -> void:
	isui = _isui
	item_stack = ItemStack.new(null, 0)


func _process(_delta: float) -> void:
	if isui:
		isui.global_position = get_tree().root.get_viewport().get_mouse_position()
		if item_stack:
			isui.visible = not item_stack.is_empty()
	if is_dragging():
		if dragging_stack.is_empty():
			var hovered_stack: ItemStack = hovered_stacks.keys()[0]
			dragging_stack = hovered_stack.copy()
			if not item_stack.is_empty():
				item_stack.pop_to(dragging_stack, item_stack.count)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			hovered_stacks.clear()
			dragging_stack.clear()


func _reparent(orphan: ItemStackUI) -> void:
	if not isui:
		if orphan and orphan.get_parent() == self:
			orphan.queue_free()
		return

	var cursor_layer := get_tree().get_first_node_in_group('cursor_layer')
	if not cursor_layer:
		return

	cursor_layer.add_child(isui)

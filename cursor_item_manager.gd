class_name CursorItemManager
extends Node


var cursor_item_ui := _cursor_item_ui:
	set(value):
		var orphan := _cursor_item_ui
		_cursor_item_ui = value
		call_deferred('_reparent', orphan)
	get:
		return _cursor_item_ui
var hovered_stacks: Dictionary[ItemStack, bool] = {}
var dragging_stack := ItemStack.new(null, 0)
var _cursor_item_ui: ItemUI = preload('res://item_ui.tscn').instantiate()


func is_dragging() -> bool:
	var left_mouse_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	return left_mouse_down and not hovered_stacks.is_empty()


func _ready() -> void:
	cursor_item_ui = _cursor_item_ui
	var item_stack := ItemStack.new(Item.new(), 0)
	cursor_item_ui.item_stack = item_stack


func _process(_delta: float) -> void:
	if cursor_item_ui:
		cursor_item_ui.global_position = get_tree().root.get_viewport().get_mouse_position()
		var item_stack: ItemStack = cursor_item_ui.item_stack
		if item_stack:
			cursor_item_ui.visible = not item_stack.is_empty()
	if is_dragging():
		if dragging_stack.is_empty():
			var hovered_stack: ItemStack = hovered_stacks.keys()[0]
			dragging_stack = hovered_stack.copy()
			print(dragging_stack.count)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			hovered_stacks.clear()
			dragging_stack.clear()


func _reparent(orphan: ItemUI) -> void:
	if not cursor_item_ui:
		if orphan and orphan.get_parent() == self:
			orphan.queue_free()
		return

	var cursor_layer := get_tree().get_first_node_in_group('cursor_layer')
	if not cursor_layer:
		return

	cursor_layer.add_child(cursor_item_ui)

class_name InventorySlot2
extends NinePatchRect

const HIGHLIGHT_ALPHA := 1.0
const NORMAL_ALPHA := 0.52
const HOVERED_SCALE := 1.05
const NORMAL_SCALE := 1.0
const LERP_SPEED := 30.0

var is_hovered := false
var is_pressed := false

@onready var item_ui: ItemUI = $ItemUI


func _process(delta: float) -> void:
	var target_alpha: float = HIGHLIGHT_ALPHA if is_hovered else NORMAL_ALPHA
	var target_scale: float = HOVERED_SCALE if is_hovered else NORMAL_SCALE

	self_modulate.a = lerp(self_modulate.a, target_alpha, LERP_SPEED * delta)

	if item_ui:
		item_ui.item_scale = lerp(item_ui.item_scale, target_scale, LERP_SPEED * delta)


func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton

	# Reset press state on release
	if not mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		is_pressed = false
		return

	if not mouse_event.pressed:
		return

	if item_ui == null or item_ui.item_stack == null:
		return

	var cursor := GlobalCursorItemManager.cursor_item_ui
	if cursor == null:
		return

	match mouse_event.button_index:

		MOUSE_BUTTON_LEFT:
			is_pressed = true

			if mouse_event.shift_pressed:
				_split_half_to_cursor()
			else:
				item_ui.item_stack.stack_or_swap_with(cursor.item_stack)

		MOUSE_BUTTON_RIGHT:
			if mouse_event.shift_pressed:
				cursor.item_stack.pop_to(item_ui.item_stack, _half(cursor.item_stack.count))
			else:
				cursor.item_stack.pop_to(item_ui.item_stack, 1)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if not mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			is_hovered = false
			is_pressed = false


func _on_mouse_entered() -> void:
	is_hovered = true

	var gcim := GlobalCursorItemManager
	if not gcim.is_dragging():
		return

	var stack := item_ui.item_stack
	if stack == null:
		return

	if gcim.hovered_stacks.has(stack):
		return

	var dragging := gcim.dragging_stack
	if dragging.is_empty():
		return

	if not stack.is_empty() and not stack.can_stack_with(dragging):
		return

	_register_hover_split(stack, gcim)


func _on_mouse_exited() -> void:
	if item_ui.item_stack not in GlobalCursorItemManager.hovered_stacks:
		is_hovered = false

	if not is_pressed:
		return

	if item_ui.item_stack.count <= 1:
		return

	if GlobalCursorItemManager.dragging_stack.is_empty():
		is_hovered = true
		GlobalCursorItemManager.hovered_stacks[item_ui.item_stack] = true


func _half(value: int) -> int:
	return int(ceil(value / 2.0))


func _split_half_to_cursor() -> void:
	var gcim := GlobalCursorItemManager
	var cursor := gcim.cursor_item_ui
	if cursor == null or cursor.item_stack == null:
		return

	var stack := item_ui.item_stack
	if stack.is_empty():
		return

	stack.pop_to(cursor.item_stack, _half(stack.count))


func _register_hover_split(stack: ItemStack, gcim: CursorItemManager) -> void:
	var dragging := gcim.dragging_stack
	var hovered := gcim.hovered_stacks

	var hovered_count := hovered.size()
	var dragging_count := dragging.count

	if hovered_count <= 0 or dragging_count <= 0:
		return

	hovered[stack] = true

	var total_targets := hovered_count + 1
	var split_count := int(dragging_count / total_targets)

	var remaining := dragging.copy()
	var null_stack := ItemStack.new(null, 0)

	for s: ItemStack in hovered.keys():
		if s == stack:
			continue

		s.pop_to(null_stack, int(dragging_count / hovered_count))
		remaining.pop_to(s, split_count)

	gcim.cursor_item_ui.item_stack = remaining

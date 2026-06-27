class_name InventorySlot
extends NinePatchRect

signal left_pressed()
signal left_doubled_pressed(inventory_slot: InventorySlot)

const ITEM_TOOLTIP := preload('res://item_tool_tip.tscn')
const HIGHLIGHT_ALPHA := 1.00
const NORMAL_ALPHA := 0.52
const LOWLIGHT_ALPHA := 0.45
const HOVERED_SCALE := 1.05
const NORMAL_SCALE := 1.0
const LERP_SPEED := 30.0

var is_hovered := false
var is_left_pressed := false
var item_stack: ItemStack:
	set(value):
		isui.item_stack = value
	get:
		return isui.item_stack

@onready var isui: ItemStackUI = $ItemStackUI


func _process(delta: float) -> void:
	var alpha_to := NORMAL_ALPHA
	var scale_to := NORMAL_SCALE

	if is_hovered:
		alpha_to = HIGHLIGHT_ALPHA
		scale_to = HOVERED_SCALE
	self_modulate.a = lerp(self_modulate.a, alpha_to, LERP_SPEED * delta)
	if isui:
		isui.item_scale = lerp(isui.item_scale, scale_to, LERP_SPEED * delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_hovered = false
			is_left_pressed = false


func _gui_input(event):
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_left_pressed = false

		if event.pressed and isui and isui.item_stack:
			var gcim := GlobalCursorItemManager

			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if event.double_click:
						left_doubled_pressed.emit(self)
						return

					left_pressed.emit()
					is_left_pressed = true

					if event.shift_pressed:
						if item_stack.is_empty():
							return

						_half_split_item_stack(item_stack, gcim.item_stack)
						is_left_pressed = false
					else:
						if gcim.item_stack.stack_or_swap_with(isui.item_stack) < 1:
							is_left_pressed = false
						#if not gcim.item_stack.equals(isui.item_stack):
						#is_left_pressed = false
				MOUSE_BUTTON_RIGHT:
					if gcim.item_stack.is_empty():
						return

					if event.shift_pressed:
						_half_split_item_stack(gcim.item_stack, item_stack)
					else:
						gcim.item_stack.pop_to(item_stack, 1)


func _show_tooltip() -> void:
	if not item_stack.is_empty():
		var cursor_layer := get_tree().get_first_node_in_group('cursor_layer')

		if not cursor_layer:
			return

		var item_tooltip := ITEM_TOOLTIP.instantiate()
		var ref: WeakRef = weakref(item_tooltip)
		var free := func(_arg = null):
			var tooltip = ref.get_ref()

			if tooltip:
				tooltip.queue_free()

		left_pressed.connect(free, CONNECT_ONE_SHOT)
		mouse_exited.connect(free, CONNECT_ONE_SHOT)
		item_tooltip.display(item_stack.item, cursor_layer)


func _drag_split_item_stack() -> void:
	var gcim := GlobalCursorItemManager
	var null_stack := ItemStack.new(null, 0)
	var dragging_stack_count: float = gcim.dragging_stack.count
	var hovered_stacks_size: float = gcim.hovered_stacks.size()
	var rollback_count: int = int(dragging_stack_count / hovered_stacks_size)
	var split_stack: ItemStack = gcim.dragging_stack.copy()
	var split_count: int = int(dragging_stack_count / (hovered_stacks_size + 1.0))

	gcim.hovered_stacks[item_stack] = true

	for hovered_stack: ItemStack in gcim.hovered_stacks:
		if hovered_stack != item_stack:
			hovered_stack.pop_to(null_stack, rollback_count)
		split_stack.pop_to(hovered_stack, split_count)

	gcim.item_stack = split_stack

	if hovered_stacks_size == dragging_stack_count - 1:
		var click := InputEventMouseButton.new()

		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = false

		Input.parse_input_event(click)


func _half_split_item_stack(to_split: ItemStack, to_stack: ItemStack) -> void:
	var half := int(ceil(to_split.count / 2.0))

	to_split.pop_to(to_stack, half)


func _on_mouse_entered() -> void:
	var gcim := GlobalCursorItemManager

	is_hovered = true

	if not gcim.is_dragging():
		_show_tooltip()
		return
	if item_stack in gcim.hovered_stacks:
		return
	if not item_stack.is_empty() and not item_stack.can_stack_with(gcim.dragging_stack):
		return

	_drag_split_item_stack()


func _on_mouse_exited() -> void:
	var gcim := GlobalCursorItemManager

	if item_stack not in gcim.hovered_stacks:
		is_hovered = false
	if not is_left_pressed:
		return
	if item_stack.is_empty():
		return
	if gcim.dragging_stack.is_empty():
		is_hovered = true
		gcim.hovered_stacks[item_stack] = true

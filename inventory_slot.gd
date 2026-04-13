class_name InventorySlot
extends NinePatchRect

signal pressed()

const ITEM_TOOLTIP := preload('res://item_tool_tip.tscn')
const HIGHLIGHT_ALPHA := 1.00
const NORMAL_ALPHA := 0.52
const LOWLIGHT_ALPHA := 0.45
const HOVERED_SCALE := 1.05
const NORMAL_SCALE := 1.0
const LERP_SPEED := 30.0

var is_hovered := false
var is_pressed := false

@onready var item_ui: ItemUI = $ItemUI


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
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_pressed = false
		if event.pressed and item_ui and item_ui.item_stack:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					pressed.emit()
					is_pressed = true
					if event.shift_pressed:
						var cursor_item_ui: ItemUI = GlobalCursorItemManager.cursor_item_ui
						if not cursor_item_ui or not cursor_item_ui.item_stack:
							return

						var item_stack := item_ui.item_stack
						if item_stack.is_empty():
							return

						var half := int(ceil(item_stack.count / 2.0))
						item_stack.pop_to(cursor_item_ui.item_stack, half)
					else:
						var cursor_item_ui: ItemUI = GlobalCursorItemManager.cursor_item_ui
						item_ui.item_stack.stack_or_swap_with(cursor_item_ui.item_stack)
				MOUSE_BUTTON_RIGHT:
					var cursor_item_ui: ItemUI = GlobalCursorItemManager.cursor_item_ui
					if event.shift_pressed:
						var half := int(ceil(cursor_item_ui.item_stack.count / 2.0))
						cursor_item_ui.item_stack.pop_to(item_ui.item_stack, half)
					else:
						cursor_item_ui.item_stack.pop_to(item_ui.item_stack, 1)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_hovered = false
			is_pressed = false


func _on_mouse_entered() -> void:
	is_hovered = true

	if not GlobalCursorItemManager.is_dragging():
		if not item_ui.item_stack.is_empty():
			var cursor_layer := get_tree().get_first_node_in_group('cursor_layer')
			if not cursor_layer:
				return

			var item_tooltip := ITEM_TOOLTIP.instantiate()
			var ref: WeakRef = weakref(item_tooltip)
			var free := func(_arg = null):
					var tooltip = ref.get_ref()
					if tooltip:
						tooltip.queue_free()

			pressed.connect(free, CONNECT_ONE_SHOT)
			mouse_exited.connect(free, CONNECT_ONE_SHOT)
			item_tooltip.display(item_ui.item_stack.item, cursor_layer)
		return
	if item_ui.item_stack in GlobalCursorItemManager.hovered_stacks:
		return
	if not item_ui.item_stack.is_empty() and not item_ui.item_stack.can_stack_with(GlobalCursorItemManager.dragging_stack):
		return

	var null_stack := ItemStack.new(null, 0)
	var dragging_stack_count: float = GlobalCursorItemManager.dragging_stack.count
	var hovered_stacks_size: float = GlobalCursorItemManager.hovered_stacks.size()
	var rollback_count: int = int(dragging_stack_count / hovered_stacks_size)

	GlobalCursorItemManager.hovered_stacks[item_ui.item_stack] = true
	var split_stack: ItemStack = GlobalCursorItemManager.dragging_stack.copy()
	var split_count: int = int(dragging_stack_count / (hovered_stacks_size + 1.0))
	for hovered_stack: ItemStack in GlobalCursorItemManager.hovered_stacks:
		if hovered_stack != item_ui.item_stack:
			hovered_stack.pop_to(null_stack, rollback_count)
		split_stack.pop_to(hovered_stack, split_count)

	GlobalCursorItemManager.cursor_item_ui.item_stack = split_stack

	if hovered_stacks_size == dragging_stack_count - 1:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = false
		Input.parse_input_event(click)


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

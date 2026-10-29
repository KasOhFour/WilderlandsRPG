# inventory_ui.gd
class_name InventoryUI
extends GridContainer

var inventory: Inventory:
	set = _set_inventory
var item_slots: Array[ItemSlot]
var cursor: CursorItemManager = GlobalCursorItemManager
var _tooltip := ItemTooltipPresenter.new()


@warning_ignore("shadowed_variable")
func _init(inventory := Inventory.new()) -> void:
	self.inventory = inventory


func _ready() -> void:
	cursor.drag_ended.connect(_on_drag_ended)
	_bind_slots()


func _exit_tree() -> void:
	_tooltip.dismiss()


func _on_drag_ended() -> void:
	for item_slot: ItemSlot in item_slots:
		item_slot.is_highlighted = false


func _set_inventory(value: Inventory) -> void:
	if inventory and inventory.changed.is_connected(_bind_slots):
		inventory.changed.disconnect(_bind_slots)

	inventory = value
	if inventory and not inventory.changed.is_connected(_bind_slots):
		inventory.changed.connect(_bind_slots)
	_bind_slots()


func _bind_slots() -> void:
	for item_slot: ItemSlot in item_slots:
		_disconnect_slot(item_slot)

	item_slots.clear()
	for child in get_children():
		if child is ItemSlot:
			item_slots.append(child)

	if not inventory:
		return

	var inventory_size: int = min(inventory.size(), item_slots.size())

	for i in range(inventory_size):
		item_slots[i].item_stack = inventory.get_stack_at(i)
		_connect_slot(item_slots[i])

	for i in range(inventory_size, item_slots.size()):
		item_slots[i].item_stack = ItemStack.new()


func _slot_handlers(item_slot: ItemSlot) -> Array[Array]:
	return [
		[item_slot.primary_pressed, _on_primary_pressed.bind(item_slot)],
		[item_slot.secondary_pressed, _on_secondary_pressed.bind(item_slot)],
		[item_slot.double_pressed, _on_double_pressed.bind(item_slot)],
		[item_slot.hover_entered, _on_hover_entered.bind(item_slot)],
		[item_slot.hover_exited, _on_hover_exited.bind(item_slot)],
	]


func _connect_slot(item_slot: ItemSlot) -> void:
	for pair in _slot_handlers(item_slot):
		var slot_signal: Signal = pair[0]
		var handler: Callable = pair[1]
		if not slot_signal.is_connected(handler):
			slot_signal.connect(handler)


func _disconnect_slot(item_slot: ItemSlot) -> void:
	for pair in _slot_handlers(item_slot):
		var slot_signal: Signal = pair[0]
		var handler: Callable = pair[1]
		if slot_signal.is_connected(handler):
			slot_signal.disconnect(handler)


func _stack_of(item_slot: ItemSlot) -> ItemStack:
	return inventory.get_stack_at(item_slots.find(item_slot))


func _on_primary_pressed(shift: bool, item_slot: ItemSlot) -> void:
	var stack := _stack_of(item_slot)

	_tooltip.dismiss()
	if InventoryInteraction.primary_click(cursor.item_stack, stack, shift):
		cursor.drag.arm(stack)
	else:
		cursor.drag.arm(null)


func _on_secondary_pressed(shift: bool, item_slot: ItemSlot) -> void:
	InventoryInteraction.secondary_click(
		cursor.item_stack, _stack_of(item_slot), shift
	)


func _on_double_pressed(item_slot: ItemSlot) -> void:
	InventoryInteraction.double_click(
		inventory, cursor.item_stack, _stack_of(item_slot)
	)


func _on_hover_entered(item_slot: ItemSlot) -> void:
	var stack := _stack_of(item_slot)

	if cursor.is_dragging():
		cursor.drag_over(stack)
	else:
		_tooltip.show_for(stack, self)


func _on_hover_exited(item_slot: ItemSlot) -> void:
	var drag := cursor.drag
	var stack := _stack_of(item_slot)

	_tooltip.dismiss()
	drag.begin_from(stack)
	if drag.has_hovered(stack):
		item_slot.is_highlighted = true

# inventory_ui.gd
class_name InventoryUI
extends GridContainer

const SLOT_SIGNALS := {
	&'primary_pressed': &'_on_primary_pressed',
	&'secondary_pressed': &'_on_secondary_pressed',
	&'double_pressed': &'_on_double_pressed',
	&'hover_entered': &'_on_hover_entered',
	&'hover_exited': &'_on_hover_exited',
}

var inventory: Inventory:
	set = _set_inventory
var item_slots: Array[ItemSlot]
var _tooltip := ItemTooltipPresenter.new()


@warning_ignore('shadowed_variable')
func _init(inventory := Inventory.new()) -> void:
	self.inventory = inventory


func _ready() -> void:
	_bind_slots()


func _exit_tree() -> void:
	_tooltip.dismiss()


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


func _connect_slot(item_slot: ItemSlot) -> void:
	for slot_signal: StringName in SLOT_SIGNALS:
		var handler := Callable(self, SLOT_SIGNALS[slot_signal]).bind(item_slot)
		item_slot.connect(slot_signal, handler)


func _disconnect_slot(item_slot: ItemSlot) -> void:
	for slot_signal: StringName in SLOT_SIGNALS:
		for connection in item_slot.get_signal_connection_list(slot_signal):
			if connection.callable.get_object() == self:
				item_slot.disconnect(slot_signal, connection.callable)


func _stack_of(item_slot: ItemSlot) -> ItemStack:
	return inventory.get_stack_at(item_slots.find(item_slot))


func _on_primary_pressed(shift: bool, item_slot: ItemSlot) -> void:
	var gcim := GlobalCursorItemManager
	var stack := _stack_of(item_slot)

	_tooltip.dismiss()
	if InventoryInteraction.primary_click(gcim.item_stack, stack, shift):
		gcim.drag.arm(stack)
	else:
		gcim.drag.arm(null)


func _on_secondary_pressed(shift: bool, item_slot: ItemSlot) -> void:
	InventoryInteraction.secondary_click(
		GlobalCursorItemManager.item_stack, _stack_of(item_slot), shift
	)


func _on_double_pressed(item_slot: ItemSlot) -> void:
	InventoryInteraction.double_click(
		inventory, GlobalCursorItemManager.item_stack, _stack_of(item_slot)
	)


func _on_hover_entered(item_slot: ItemSlot) -> void:
	var gcim := GlobalCursorItemManager
	var stack := _stack_of(item_slot)

	if gcim.is_dragging():
		gcim.drag_over(stack)
	else:
		_tooltip.show_for(stack, self)


func _on_hover_exited(item_slot: ItemSlot) -> void:
	var drag := GlobalCursorItemManager.drag
	var stack := _stack_of(item_slot)

	_tooltip.dismiss()
	drag.begin_from(stack)
	if drag.has_hovered(stack):
		item_slot.is_highlighted = true

# inventory_ui.gd
class_name InventoryUI
extends GridContainer

var inventory: Inventory:
	set = _set_inventory
var item_slots: Array[ItemSlot]


@warning_ignore('shadowed_variable')
func _init(inventory := Inventory.new()) -> void:
	self.inventory = inventory


func _set_inventory(value: Inventory) -> void:
	if item_slots:
		for item_slot: ItemSlot in item_slots:
			if item_slot.left_doubled_pressed.is_connected(_on_left_double_pressed):
				item_slot.left_doubled_pressed.disconnect(_on_left_double_pressed)

	inventory = value
	item_slots.clear()
	for child in get_children():
		if child is ItemSlot:
			item_slots.append(child)

	var inventory_size: int = min(inventory.size(), item_slots.size())

	for i in range(inventory_size):
		item_slots[i].item_stack = inventory.get_stack_at(i)
		item_slots[i].left_doubled_pressed.connect(_on_left_double_pressed)


func _on_left_double_pressed(item_slot: ItemSlot) -> void:
	var gcim := GlobalCursorItemManager
	if item_slot.item_stack.is_empty():
		inventory.fill_stack(gcim.item_stack)
	else:
		inventory.fill_stack(item_slot.item_stack)

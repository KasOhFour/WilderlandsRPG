class_name InventoryGrid
extends GridContainer

var inventory: Inventory:
	set = _set_inventory
var inventory_slots: Array[InventorySlot]


func _set_inventory(value: Inventory) -> void:
	if inventory_slots:
		for inventory_slot: InventorySlot in inventory_slots:
			if inventory_slot.left_doubled_pressed.is_connected(_on_left_double_pressed):
				inventory_slot.left_doubled_pressed.disconnect(_on_left_double_pressed)

	inventory = value
	inventory_slots.clear()
	for child in get_children():
		if child is InventorySlot:
			inventory_slots.append(child)

	var inventory_size: int = min(inventory.size(), inventory_slots.size())

	for i in range(inventory_size):
		inventory_slots[i].item_stack = inventory.get_stack_at(i)
		inventory_slots[i].left_doubled_pressed.connect(_on_left_double_pressed)


func _on_left_double_pressed(inventory_slot: InventorySlot) -> void:
	var gcim := GlobalCursorItemManager
	if inventory_slot.item_stack.is_empty():
		inventory.fill_stack(gcim.item_stack)
	else:
		inventory.fill_stack(inventory_slot.item_stack)

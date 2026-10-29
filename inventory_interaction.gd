class_name InventoryInteraction
extends RefCounted
## Stack-manipulation rules for slot interactions. Operates only on data
## (ItemStack / Inventory) so it has no dependency on any UI node.


## Returns true if the press should be treated as the start of a possible drag.
static func primary_click(cursor_stack: ItemStack, slot_stack: ItemStack, shift: bool) -> bool:
	if shift:
		if slot_stack.is_empty():
			return true

		half_split(slot_stack, cursor_stack)
		return false

	return cursor_stack.stack_or_swap_with(slot_stack) >= 1


static func secondary_click(cursor_stack: ItemStack, slot_stack: ItemStack, shift: bool) -> void:
	if cursor_stack.is_empty():
		return

	if shift:
		half_split(cursor_stack, slot_stack)
	else:
		cursor_stack.pop_to(slot_stack, 1)


static func double_click(inventory: Inventory, cursor_stack: ItemStack, slot_stack: ItemStack) -> void:
	if slot_stack.is_empty():
		inventory.fill_stack(cursor_stack)
	else:
		inventory.fill_stack(slot_stack)


static func half_split(to_split: ItemStack, to_stack: ItemStack) -> void:
	var half := int(ceil(to_split.count / 2.0))

	to_split.pop_to(to_stack, half)

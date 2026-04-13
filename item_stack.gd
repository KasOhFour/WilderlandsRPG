# item_stack.gd
class_name ItemStack
extends Resource

signal sanitized()

enum Status { 
	UNCHANGED,
	STACKED,
	SWAPPED_STACKS,
	SWAPPED_EMPTY,
	SWAPPED_STACK_WITH_EMPTY,
	SWAPPED_EMPTY_WITH_STACK,
	POPPED,
}

var item: Item
var count: int


func _init(_item: Item, _count: int) -> void:
	item = _item
	count = _count
	sanitize(true)


func copy() -> ItemStack:
	var item_stack := ItemStack.new(item, count)
	return item_stack


func clear() -> void:
	item = null
	count = 0
	sanitize()


func sanitize(force_count: bool = false) -> void:
	if item == null or (count <= 0 and not force_count):
		item = null
		count = 0
	sanitized.emit()


func equals(other: ItemStack) -> bool:
	if not other:
		return false
	if not item or not other.item:
		return false
	return item.equals(other.item)


func can_stack_with(other: ItemStack) -> bool:
	return equals(other)


func is_empty() -> bool:
	return item == null or count <= 0


func stack_or_swap_with(other: ItemStack) -> ItemStack.Status:
	if not other:
		return ItemStack.Status.UNCHANGED

	if can_stack_with(other):
		var capacity := item.max_stack_count - count
		if capacity > 0:
			var to_stack: int = min(capacity, other.count)

			count += to_stack
			other.count -= to_stack

			other.sanitize()
			sanitize()
			return ItemStack.Status.STACKED

	var status := ItemStack.Status.SWAPPED_STACKS
	if is_empty() and other.is_empty():
		status = ItemStack.Status.SWAPPED_EMPTY
	elif is_empty() and not other.is_empty():
		status = ItemStack.Status.SWAPPED_EMPTY_WITH_STACK
	elif not is_empty() and other.is_empty():
		status = ItemStack.Status.SWAPPED_STACK_WITH_EMPTY

	var new_item := other.item
	var new_count := other.count

	other.item = item
	other.count = count

	item = new_item
	count = new_count

	sanitize()
	other.sanitize()
	return status


func pop_to(other: ItemStack, by_count: int) -> ItemStack.Status:
	if is_empty() or by_count <= 0 or not other:
		return ItemStack.Status.UNCHANGED

	by_count = min(by_count, count)

	if other.is_empty():
		other.item = item
		other.count = by_count
		count -= by_count
	elif can_stack_with(other):
		var capacity := other.item.max_stack_count - other.count
		var to_stack: int = min(capacity, by_count)

		other.count += to_stack
		count -= to_stack
	else:
		return ItemStack.Status.UNCHANGED

	sanitize()
	other.sanitize()
	return ItemStack.Status.POPPED

# item_stack.gd
class_name ItemStack
extends Resource

@export var item: Item
@export var count: int
@export var max_stack_count_override: Item.MaxStackCount


func _init(_item: Item = null, _count: int = 0, _max_stack_count_override: Item.MaxStackCount = Item.MaxStackCount.UNDEFINED) -> void:
	item = _item
	count = _count
	max_stack_count_override = _max_stack_count_override
	emit_changed()


func copy() -> ItemStack:
	var item_stack := ItemStack.new(item, count, max_stack_count_override)

	return item_stack


func clear() -> void:
	item = null
	count = 0
	emit_changed()


func equals(other: ItemStack) -> bool:
	if not other or not item or not other.item:
		return false
	return item.equals(other.item)


func is_empty() -> bool:
	return item == null or count <= 0


func is_full() -> bool:
	return item and count >= get_max_stack_count()


func get_max_stack_count() -> int:
	var use_override := max_stack_count_override != Item.MaxStackCount.UNDEFINED

	return max_stack_count_override if use_override else item.max_stack_count


func get_capacity() -> int:
	if is_empty():
		return get_max_stack_count()
	return max(get_max_stack_count() - count, 0)


func safe_add(this_much: int) -> int:
	if this_much <= 0:
		return this_much

	var to_add: int = min(this_much, get_capacity())

	if to_add > 0:
		count += to_add
		emit_changed()

	return this_much - to_add


func safe_sub(this_much: int) -> int:
	if this_much <= 0:
		return this_much

	var to_sub: int = min(this_much, count)

	if to_sub > 0:
		count -= to_sub
		if count == 0:
			item = null
		emit_changed()

	return this_much - to_sub


func stack_or_swap_with(other: ItemStack) -> int:
	if not other:
		return -1

	var status := pop_to(other, count)

	if status > 0:
		return status

	var swap_item := other.item
	var swap_count := other.count

	other.item = item
	other.count = count

	item = swap_item
	count = swap_count

	other.emit_changed()
	emit_changed()
	return 0


func pop_to(other: ItemStack, by_count: int) -> int:
	if is_empty() or not other or by_count <= 0:
		return -1

	if other.is_empty():
		other.item = item

	if equals(other):
		var overflow := other.safe_add(by_count)
		var added := by_count - overflow

		safe_sub(added)

		return added

	return -1

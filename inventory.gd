class_name Inventory
extends Resource

@export var item_stacks: Array[ItemStack]


func _init(_size: int) -> void:
	while item_stacks.size() < _size:
		var item_stack := ItemStack.new()
		item_stacks.append(item_stack)


func count_of(item: Item) -> int:
	var count := 0
	if not item:
		return 0
	for item_stack: ItemStack in item_stacks:
		if item.equals(item_stack.item):
			count += item_stack.count
	return count


func find(item: Item) -> ItemStack:
	if not item:
		return null

	for item_stack: ItemStack in item_stacks:
		if item.equals(item_stack.item):
			return item_stack

	return null


func find_all(item: Item) -> Array[ItemStack]:
	var all: Array[ItemStack] = []

	if not item:
		return all

	for item_stack: ItemStack in item_stacks:
		if item.equals(item_stack.item):
			all.append(item_stack)

	return all


func get_stack_at(index: int) -> ItemStack:
	return null if index >= size() else item_stacks[index]


func set_stack_at(index: int, item_stack: ItemStack) -> void:
	if index >= size() or not item_stack:
		return
	item_stacks[index] = item_stack


func has(item: Item) -> bool:
	return find(item) != null


func fill_inventory(item: Item, count: int) -> int:
	if not item or count < 0:
		return count

	var filler := ItemStack.new(item, count, Item.MaxStackCount.UNLIMITED)
	for fillee: ItemStack in find_all(item):
		if filler.is_empty():
			break
		filler.pop_to(fillee, filler.count)

	for fillee: ItemStack in item_stacks:
		if filler.is_empty():
			break
		filler.pop_to(fillee, filler.count)

	return filler.count


func fill_stack(fillee: ItemStack) -> void:
	if not fillee or fillee.is_empty():
		return

	var temp_item_stacks := item_stacks.duplicate()
	temp_item_stacks.sort_custom(func(a: ItemStack, b: ItemStack): return a.count < b.count)
	for filler: ItemStack in temp_item_stacks:
		if fillee.is_full():
			break
		filler.pop_to(fillee, filler.count)


func is_empty() -> bool:
	for item_stack: ItemStack in item_stacks:
		if not item_stack.is_empty():
			return false
	return true


func resize(to_size: int) -> Array[ItemStack]:
	var ejected_item_stacks: Array[ItemStack]
	if to_size < size():
		ejected_item_stacks = item_stacks.slice(to_size, size())
	item_stacks.resize(to_size)
	return ejected_item_stacks


func size() -> int:
	return item_stacks.size()

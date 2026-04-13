class_name InventorySystem extends GridContainer


func _ready() -> void:
	var i := 0
	for child: InventorySlot in get_children():
		child.item_ui.item_stack.clear()
		if i == 0 or i == 9:
			child.item_ui.item_stack = ItemStack.new(
				preload('res://gold_coin.tres'),
				99
			)
		if i == 4:
			child.item_ui.item_stack = ItemStack.new(
				preload('res://nullcore.tres'),
				10
			)
		i += 1

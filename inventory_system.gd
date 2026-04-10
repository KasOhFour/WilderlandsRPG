class_name InventorySystem extends GridContainer


func _ready() -> void:
	var is_first_child := true
	for child: InventorySlot in get_children():
		if not is_first_child:
			child.item_ui = null
		is_first_child = false

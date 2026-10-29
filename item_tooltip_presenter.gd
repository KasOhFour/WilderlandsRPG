class_name ItemTooltipPresenter
extends RefCounted
## Shows and dismisses the item tooltip on the cursor layer.

const ITEM_TOOLTIP := preload('res://item_tool_tip.tscn')

var _tooltip: Node


func show_for(item_stack: ItemStack, context: Node) -> void:
	dismiss()

	if not item_stack or item_stack.is_empty():
		return

	var cursor_layer := context.get_tree().get_first_node_in_group('cursor_layer')

	if not cursor_layer:
		return

	_tooltip = ITEM_TOOLTIP.instantiate()
	_tooltip.display(item_stack.item, cursor_layer)


func dismiss() -> void:
	if is_instance_valid(_tooltip):
		_tooltip.queue_free()
	_tooltip = null

class_name HoverItemManager extends Node

var hover_item := _hover_item:
	set(value):
		var orphan: ItemUI = value
		_hover_item = value
		call_deferred('_reparent', orphan)
	get:
		return _hover_item
var _hover_item: ItemUI


func _ready() -> void:
	hover_item = _hover_item


func _process(_delta: float) -> void:
	if hover_item:
		hover_item.global_position = get_tree().root.get_viewport().get_mouse_position() + Vector2(-8, -8)


func _reparent(orphan: ItemUI) -> void:
	if not hover_item:
		if orphan and orphan.get_parent() == self:
			orphan.queue_free()
		return

	var hover_layer := get_tree().get_first_node_in_group('hover_layer')
	if not hover_layer:
		return

	if hover_item.get_parent() != hover_layer:
		hover_item.reparent(hover_layer)

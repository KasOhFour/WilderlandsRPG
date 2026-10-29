class_name ItemStackUI
extends Control

const LAYER_PATHS: Array[NodePath] = [^'Shadow', ^'Item']
const SIDES: Array[String] = ['left', 'top', 'right', 'bottom']

var item_stack: ItemStack:
	set = _set_item_stack
var item_scale: float:
	set = _set_item_scale

var _layers: Array[Dictionary] = []


func _ready() -> void:
	for path in LAYER_PATHS:
		var layer: Node = get_node(path)

		_layers.append({
			margins = layer.get_node('Margins') as MarginContainer,
			texture = layer.get_node('Margins/Texture') as TextureRect,
			count = layer.get_node('Count') as Label,
		})

	if not item_stack:
		item_stack = ItemStack.new()
	item_scale = _layers[0].margins.scale.x
	_update()


func _set_item_stack(value: ItemStack) -> void:
	if item_stack and item_stack.changed.is_connected(_update):
		item_stack.changed.disconnect(_update)

	item_stack = value
	if item_stack and not item_stack.changed.is_connected(_update):
		item_stack.changed.connect(_update)
	_update()


func _set_item_scale(value: float) -> void:
	item_scale = value
	for layer in _layers:
		layer.margins.scale = Vector2.ONE * item_scale


func _update() -> void:
	if _layers.is_empty() or not item_stack:
		return

	var item_texture: Texture2D = Item.default_texture()
	var item_margins := 0

	if item_stack.item:
		item_texture = item_stack.item.texture
		item_margins = item_stack.item.margins

	for layer in _layers:
		layer.texture.texture = item_texture
		layer.count.text = str(item_stack.count)
		layer.count.visible = item_stack.count not in [0, 1]

		for side in SIDES:
			layer.margins.add_theme_constant_override('margin_%s' % side, item_margins)

class_name ItemUI
extends Control

var item_stack := _item_stack:
	set(value):
		if item_stack and item_stack.is_connected('sanitized', _update):
			item_stack.disconnect('sanitized', _update)
		_item_stack = value
		if _item_stack and not _item_stack.is_connected('sanitized', _update):
			_item_stack.sanitized.connect(_update)
		_update()
	get:
		return _item_stack
var item_scale := _item_scale:
	set(value):
		_item_scale = value
		for margin: MarginContainer in margins:
			margin.scale = Vector2(_item_scale, _item_scale)
	get:
		return _item_scale
var _item_stack := ItemStack.new(Item.new(), 0)
var _item_scale := 1.0

@onready var items := [
	$ItemShadow/Margin/Item,
	$ItemView/Margin/Item,
]
@onready var margins := [
	$ItemShadow/Margin,
	$ItemView/Margin,
]
@onready var counts := [
	$ItemShadow/Count,
	$ItemView/Count,
]


func _ready() -> void:
	var margin: MarginContainer = margins[0]

	item_stack = _item_stack
	item_scale = margin.scale.x


func _update() -> void:
	var item_texture: Texture2D = Item.default_texture()
	var item_margins := 0

	if item_stack.item:
		item_texture = item_stack.item.texture
		item_margins = item_stack.item.margins

	for item: TextureRect in items:
		item.texture = item_texture

	for count: Label in counts:
		count.text = str(item_stack.count)
		if item_stack.count == 0:
			count.visible = false
		else:
			count.visible = true

	for margin: MarginContainer in margins:
		for side in ['left', 'top', 'right', 'bottom']:
			margin.add_theme_constant_override('margin_%s' % side, item_margins)

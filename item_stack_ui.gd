class_name ItemStackUI
extends Control

var item_stack: ItemStack:
	set = _set_item_stack
var item_scale: float:
	set = _set_item_scale

@onready var items := [
	$Shadow/Margins/Texture,
	$Item/Margins/Texture,
]
@onready var margins := [
	$Shadow/Margins,
	$Item/Margins,
]
@onready var counts := [
	$Shadow/Count,
	$Item/Count,
]


func _ready() -> void:
	var margin: MarginContainer = margins[0]

	item_stack = ItemStack.new()
	item_scale = margin.scale.x


func _set_item_stack(value: ItemStack) -> void:
	if item_stack and item_stack.is_connected('changed', _update):
		item_stack.disconnect('changed', _update)

	item_stack = value
	if item_stack and not item_stack.is_connected('changed', _update):
		item_stack.changed.connect(_update)
	_update()


func _set_item_scale(value: float) -> void:
	item_scale = value
	for margin: MarginContainer in margins:
		margin.scale = Vector2(1.00, 1.00) * item_scale


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
		if item_stack.count in [0, 1]:
			count.visible = false
		else:
			count.visible = true

	for margin: MarginContainer in margins:
		for side in ['left', 'top', 'right', 'bottom']:
			margin.add_theme_constant_override('margin_%s' % side, item_margins)

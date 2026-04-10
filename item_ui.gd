class_name ItemUI extends Control

@onready var margins := [
	$ItemShadow/Margin,
	$ItemView/Margin,
]
@onready var items := [
	$ItemShadow/Margin/Item,
	$ItemView/Margin/Item,
]
@onready var counts := [
	$ItemShadow/Count,
	$ItemView/Count,
]

var item_scale := _item_scale:
	set(value):
		_item_scale = value
		for margin: MarginContainer in margins:
			margin.scale = Vector2(_item_scale, _item_scale)
	get:
		return _item_scale

var item_texture := _item_texture:
	set(value):
		_item_texture = value
		for item: TextureRect in items:
			item.texture = _item_texture
	get:
		return _item_texture

var item_count := _item_count:
	set(value):
		_item_count = value
		for count: Label in counts:
			count.text = str(_item_count)
			if _item_count == 0:
				count.visible = false
			else:
				count.visible = true
	get:
		return _item_count

var _item_scale := 1.0
var _item_texture := Texture2D.new()
var _item_count := 0

func _ready() -> void:
	var margin: MarginContainer = margins[0]
	var item: TextureRect = items[0]
	var count: Label = counts[0]

	item_scale = margin.scale.x
	item_texture = item.texture
	item_count = int(count.text)

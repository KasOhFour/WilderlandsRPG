class_name ItemTooltip
extends Control

@onready var label := $RichTextLabel


func _ready() -> void:
	visible = false


func _process(_delta) -> void:
	global_position = get_tree().root.get_viewport().get_mouse_position() + Vector2(24, 4)


func display(item: Item, cursor_layer: CanvasLayer) -> void:
	var color := '#%06x' % item.rarity

	cursor_layer.add_child(self)

	label.text = '[color=%s]%s[/color]' % [color, item.name]
	visible = true

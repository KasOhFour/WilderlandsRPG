class_name DropdownPalette extends VBoxContainer

signal color_pressed(index: int)

@onready var button: Button = $Button
@onready var grid_container: GridContainer = $GridContainer

var text: String:
	set(value):
		_text = value
		if button:
			button.text = _text
	get:
		return _text

var colors: PackedColorArray:
	set(value):
		_colors = value
		if grid_container:
			for color_button in grid_container.get_children():
				color_button.queue_free()
			for i in len(_colors):
				var color_button := ColorButton.new()
				grid_container.add_child(color_button)
				color_button.custom_minimum_size = Vector2(16, 16)
				color_button.color = _colors[i]
				color_button.pressed.connect(_on_color_pressed.bind(i))
	get:
		return _colors

var _text: String
var _colors: PackedColorArray


func _ready() -> void:
	text = text
	colors = colors
	grid_container.visible = false
	button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	grid_container.visible = !grid_container.visible


func _on_color_pressed(index: int) -> void:
	color_pressed.emit(index)

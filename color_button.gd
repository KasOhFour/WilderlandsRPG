class_name ColorButton extends Button

const BUTTON_HOVER_COLOR_OFFSET := Color(0.05, 0.05, 0.05)

var color: Color:
	set(value):
		_color = value

		var normal_style := get_theme_stylebox('normal')
		normal_style.bg_color = _color

		var hover_style := get_theme_stylebox('hover')
		hover_style.bg_color = _color + BUTTON_HOVER_COLOR_OFFSET

		var pressed_style := get_theme_stylebox('pressed')
		pressed_style.bg_color = _color

		var focus_style := get_theme_stylebox('focus')
		focus_style.bg_color = _color

var _color: Color


func _ready() -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.set_corner_radius_all(0)

	var hover_style := StyleBoxFlat.new()
	hover_style.set_corner_radius_all(0)

	var pressed_style := StyleBoxFlat.new()
	pressed_style.border_color = Color.WHITE
	pressed_style.set_border_width_all(2)
	pressed_style.set_corner_radius_all(0)

	var focus_style := StyleBoxFlat.new()
	pressed_style.border_color = Color.WHITE
	focus_style.set_border_width_all(2)
	focus_style.set_corner_radius_all(0)

	add_theme_stylebox_override('normal', normal_style)
	add_theme_stylebox_override('hover', hover_style)
	add_theme_stylebox_override('pressed', pressed_style)
	add_theme_stylebox_override('focus', focus_style)

	color = Color.BLACK

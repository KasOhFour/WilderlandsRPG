class_name PaletteContainer extends VBoxContainer

signal colors_chosen(colors: PackedColorArray)

const dropdown_palette_tscn := preload('res://dropdown_palette.tscn')

@export var palettes: Array[Palette]

var colors: PackedColorArray
var thumbnail_color: Color


func _ready() -> void:
	var is_ready := false

	for palette: Palette in palettes:
		var dropdown_palette := dropdown_palette_tscn.instantiate()
		add_child(dropdown_palette)
		dropdown_palette.text = palette.name
		dropdown_palette.colors = palette.get_column_colors(Palette.PLAYER_SKIN_THUMBNAIL_INDEX)
		dropdown_palette.color_pressed.connect(_on_color_pressed.bind(palette))

		if not is_ready:
			_on_color_pressed(0, palette)
			is_ready = true


func _on_color_pressed(index: int, palette: Palette) -> void:
	colors = palette.get_row_colors(index)
	thumbnail_color = colors[Palette.PLAYER_SKIN_THUMBNAIL_INDEX]
	colors_chosen.emit(colors)

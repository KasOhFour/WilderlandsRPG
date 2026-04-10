class_name Palette extends Resource

const PLAYER_PALETTE_WIDTH := 7
const PLAYER_SCLERA_INDICES := [6]
const PLAYER_IRIS_INDICES := [0, 2]
const PLAYER_IRIS_COLOR_OFFSET := Color(0.15, 0.15, 0.15)
const PLAYER_SKIN_INDICES := [1, 3, 4, 5]
const PLAYER_SKIN_THUMBNAIL_INDEX := 2

@export var name := ''
@export var palette_texture: Texture2D


static func player_palette_texture(
	sclera: PackedColorArray,
	iris: PackedColorArray,
	skin: PackedColorArray
) -> Texture2D:
	var palette_image := Image.create(
		PLAYER_PALETTE_WIDTH,
		1,
		false,
		Image.FORMAT_RGB8
	)
	var indices_colors_map: Dictionary[Array, PackedColorArray] = {
		PLAYER_SCLERA_INDICES: sclera,
		PLAYER_IRIS_INDICES: iris,
		PLAYER_SKIN_INDICES: skin,
	}
	for indices in indices_colors_map:
		var colors := indices_colors_map[indices]

		for i in len(indices):
			var color := colors[i]
			palette_image.set_pixel(indices[i], 0, color)
	var out_palette_texture := ImageTexture.create_from_image(palette_image)
	return out_palette_texture


func width() -> int:
	if palette_texture:
		return palette_texture.get_width()
	return 0


func height() -> int:
	if palette_texture:
		return palette_texture.get_height()
	return 0


func get_row_colors(row: int) -> PackedColorArray:
	var row_colors := PackedColorArray()
	var palette_image := palette_texture.get_image()
	for x in width():
		row_colors.append(palette_image.get_pixel(x, row))
	return row_colors


func get_column_colors(column: int) -> PackedColorArray:
	var column_colors := PackedColorArray()
	var palette_image := palette_texture.get_image()
	for y in height():
		column_colors.append(palette_image.get_pixel(column, y))
	return column_colors

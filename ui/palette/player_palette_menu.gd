class_name PlayerPaletteMenu extends VBoxContainer

signal palette_set(palette_texture: Texture2D)

@onready var sclera_picker: ColorPickerButton = $ScleraPicker/ColorPickerButton
@onready var iris_picker: ColorPickerButton = $IrisPicker/ColorPickerButton
@onready var skin_preview: ColorButton = $SkinPickerPreview/Button
@onready var skin_picker: PaletteContainer = $SkinPicker


func update() -> void:
	_on_palette_set(null)


func _ready() -> void:
	sclera_picker.color_changed.connect(_on_palette_set)
	iris_picker.color_changed.connect(_on_palette_set)
	skin_picker.colors_chosen.connect(_on_palette_set)


func _get_sclera() -> PackedColorArray:
	var sclera: PackedColorArray = [
		sclera_picker.color,
	]
	return sclera


func _get_iris() -> PackedColorArray:
	var iris: PackedColorArray = [
		iris_picker.color,
		iris_picker.color + Palette.PLAYER_IRIS_COLOR_OFFSET,
	]
	return iris


func _get_skin() -> PackedColorArray:
	return skin_picker.colors


func _on_palette_set(_any: Variant) -> void:
	var sclera: PackedColorArray = _get_sclera()
	var iris: PackedColorArray = _get_iris()
	var skin: PackedColorArray = _get_skin()

	skin_preview.color = skin_picker.thumbnail_color

	var palette_texture = Palette.player_palette_texture(sclera, iris, skin)
	palette_set.emit(palette_texture)


func _on_skin_picker_preview_pressed() -> void:
	skin_picker.visible = not skin_picker.visible
	skin_preview.release_focus()

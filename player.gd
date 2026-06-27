class_name Player
extends Resource

const DEFAULT_PALETTE := preload('res://player/assets/default_palette.png')
const DEFAULT_INVENTORY_SIZE := 40
const PLAYER_MASK := preload('res://player/assets/default_mask.tres')
const PLAYER_MATERIAL := preload('res://player/assets/default_material.tres')

var palette: Texture2D:
	set = _set_palette
var inventory: Inventory


func _init(
		_palette := DEFAULT_PALETTE,
		_inventory := Inventory.new(DEFAULT_INVENTORY_SIZE),
) -> void:
	palette = _palette
	inventory = _inventory


func update_mask(animation: String, frame: int) -> void:
	var mask := PLAYER_MASK.get_frame_texture(animation, frame)

	PLAYER_MATERIAL.set_shader_parameter('mask', mask)


func _set_palette(value: Texture2D) -> void:
	palette = value
	PLAYER_MATERIAL.set_shader_parameter('palette', palette)
	PLAYER_MATERIAL.set_shader_parameter('palette_width', palette.get_width())

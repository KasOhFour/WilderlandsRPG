extends Node2D

@onready var player: Player = $Player
@onready var player_palette_menu: PlayerPaletteMenu = $CanvasLayer/PlayerPaletteMenu


func _ready() -> void:
	player_palette_menu.palette_set.connect(_on_palette_set)
	player_palette_menu.update()


func _on_palette_set(palette_texture: Texture2D) -> void:
	player.palette_texture = palette_texture

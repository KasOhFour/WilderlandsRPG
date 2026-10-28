extends Node2D

@onready var player: Player = $Player
@onready var player_palette_menu: PlayerPaletteMenu = $CanvasLayer/PlayerPaletteMenu


func _ready() -> void:
	player_palette_menu.palette_set.connect(_on_palette_set)
	player_palette_menu.update()
	$CanvasLayer/MainMenu/PlayerSheet/InventorySlotDisplay/InventoryUI.inventory = player.inventory


func _on_palette_set(palette: Texture2D) -> void:
	player.palette = palette

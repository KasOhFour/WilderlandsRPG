extends Node2D

@onready var player_body_2d: PlayerBody2D = $Player
@onready var player_palette_menu: PlayerPaletteMenu = $CanvasLayer/PlayerPaletteMenu


func _ready() -> void:
	player_palette_menu.palette_set.connect(_on_palette_set)
	player_palette_menu.update()
	$CanvasLayer/MainMenu/PlayerSheet/InventorySlotDisplay/Inventory.inventory = player_body_2d.player.inventory


func _on_palette_set(palette: Texture2D) -> void:
	player_body_2d.player.palette = palette

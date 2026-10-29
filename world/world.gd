extends Node2D

@onready var player_palette_menu: PlayerPaletteMenu = %PlayerPaletteMenu
@onready var main_menu: MainMenu = %MainMenu


func _ready() -> void:
	player_palette_menu.palette_set.connect(_on_palette_set)
	player_palette_menu.update()
	Game.add_or_parent_player(self)
	main_menu.set_inventory(Game.player.inventory)


func _on_palette_set(palette: Texture2D) -> void:
	Game.player.palette = palette

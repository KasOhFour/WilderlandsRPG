# wood_chest_ui.gd
class_name WoodChestUI
extends Control

var wood_chest := WoodChest.new()
var player_inventory: Inventory

@onready var wood_chest_inventory_ui: InventoryUI = %WoodChestGrid
@onready var player_inventory_ui: InventoryUI = %PlayerGrid


@warning_ignore("shadowed_variable")
static func from_tscn(wood_chest: WoodChest, player_inventory: Inventory) -> WoodChestUI:
	const TSCN := preload("res://interactables/storage/wood_chest/wood_chest_ui.tscn")
	var ui: WoodChestUI = TSCN.instantiate()
	ui.visible = false
	ui.wood_chest = wood_chest
	ui.player_inventory = player_inventory
	return ui


func _ready() -> void:
	if wood_chest.is_visible_in_tree():
		wood_chest_inventory_ui.inventory = wood_chest.inventory
		player_inventory_ui.inventory = player_inventory
		wood_chest.opened.connect(func(): visible = true)
		wood_chest.open()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		wood_chest.close()
		queue_free()

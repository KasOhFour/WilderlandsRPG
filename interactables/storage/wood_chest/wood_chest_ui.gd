# wood_chest_ui.gd
class_name WoodChestUI
extends Control

@onready var wci_ui := $VBoxContainer/WoodChestInventory/VBoxContainer/MarginContainer/InventoryUI
@onready var pi_ui := $VBoxContainer/PlayerInventory/VBoxContainer/MarginContainer/InventoryUI

var wood_chest := WoodChest.new()


@warning_ignore('shadowed_variable')
static func from_tscn(wood_chest: WoodChest) -> WoodChestUI:
	const TSCN := preload('res://interactables/storage/wood_chest/wood_chest_ui.tscn')
	var ui: WoodChestUI = TSCN.instantiate()
	ui.visible = false
	ui.wood_chest = wood_chest
	return ui


func _ready() -> void:
	if wood_chest.is_visible_in_tree():
		const ITEM := preload('res://gold_coin.tres')
		const COUNT := 99
		wood_chest.inventory.fill_inventory(ITEM, COUNT)
		wci_ui.inventory = wood_chest.inventory
		pi_ui.inventory = Game.player.inventory
		wood_chest.opened.connect(func(): visible = true)
		wood_chest.open()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact'):
		wood_chest.close()
		queue_free()

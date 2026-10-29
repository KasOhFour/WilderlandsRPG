# wood_chest.gd
class_name WoodChest
extends Area2D

signal closed()
signal opened()

var is_open := false
var inventory := Inventory.new(30)

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D


@warning_ignore("shadowed_variable")
static func from_tscn(inventory: Inventory) -> WoodChest:
	const TSCN := preload("res://interactables/storage/wood_chest/wood_chest.tscn")
	var wood_chest: WoodChest = TSCN.instantiate()
	wood_chest.inventory = inventory
	return wood_chest


func open() -> Inventory:
	if is_open:
		return null

	is_open = true
	animation.play("open")
	return inventory


func close() -> bool:
	if not is_open:
		return false

	is_open = false
	animation.play("close")
	return true


func _on_animation_finished() -> void:
	if is_open:
		opened.emit()
	else:
		closed.emit()

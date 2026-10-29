# game.gd
extends Node

const GUI_SCENE := preload("res://ui/gui.tscn")
const PLAYER_SCENE := preload("res://entities/player/player.tscn")

var date_time := DateTime.new()
var gui: GUI
var player: Player


func add_or_parent_player(parent: Node2D) -> void:
	if player.is_inside_tree():
		player.reparent(parent)
	else:
		parent.add_child(player)


func _ready() -> void:
	gui = GUI_SCENE.instantiate()
	player = PLAYER_SCENE.instantiate()
	add_child(gui)
	player.interacted.connect(_on_player_interacted)
	date_time.minute_ticked.connect(_on_minute_ticked)
	date_time.hour_ticked.connect(_on_hour_ticked)
	add_child(date_time)


func _on_player_interacted(interactable: Area2D) -> void:
	gui.open_ui(interactable, player.inventory)


func _on_minute_ticked(_minute: int) -> void:
	# print(get_string_time())
	pass


func _on_hour_ticked(hour: int) -> void:
	if DateTime.is_save_hour(hour):
		date_time.skip_hours_from_save()

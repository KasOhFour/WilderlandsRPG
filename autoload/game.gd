# game.gd
extends Node

var date_time := DateTime.new()
var gui: GUI
var player: Player


func add_or_parent_player(parent: Node2D) -> void:
	if player.is_inside_tree():
		player.reparent(parent)
	else:
		parent.add_child(player)


func _ready() -> void:
	gui = load("res://ui/gui.tscn").instantiate()
	player = load("res://entities/player/player.tscn").instantiate()
	add_child(gui)
	date_time.minute_ticked.connect(_on_minute_ticked)
	date_time.hour_ticked.connect(_on_hour_ticked)
	add_child(date_time)


func _on_minute_ticked(_minute: int) -> void:
	# print(get_string_time())
	pass


func _on_hour_ticked(hour: int) -> void:
	if DateTime.is_save_hour(hour):
		date_time.skip_hours_from_save()

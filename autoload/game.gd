# game.gd
extends Node

var date_time := DateTime.new()
var gui: GUI
var player: Player
#var gui := preload('res://ui/gui.tscn').instantiate()
#var player := preload('res://entities/player/player.tscn').instantiate()


func get_string_time(format: String = '$Se $DD, Year $Y, $HH:$MM $Me') -> String:
	var result := format
	var year := date_time.year
	var season := date_time.season
	var season_name := Util.enum_string(DateTime.Season, season)
	var day := date_time.day
	var hour := date_time.hour
	var standard_hour := Util.standard_hour(hour)
	var minute := date_time.minute
	var meridiem := 'AM' if hour < 12 else 'PM'

	result = result.replace('$Y', str(year))
	result = result.replace('$Se', season_name.capitalize())
	result = result.replace('$SE', season_name.to_upper())
	result = result.replace('$SN', str(date_time.season))
	result = result.replace('$DD', '%02d' % day)
	result = result.replace('$D', str(day))
	result = result.replace('$HH', '%02d' % standard_hour)
	result = result.replace('$H', str(standard_hour))
	result = result.replace('$hh', '%02d' % date_time.hour)
	result = result.replace('$h', str(date_time.hour))
	result = result.replace('$MM', '%02d' % minute)
	result = result.replace('$Me', meridiem)

	return result


func get_normal_time() -> float:
	return date_time.normal_delta


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

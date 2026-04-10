# IslandRegionStruct.gd defines a class for aggregating noise and tile map information
# for generating island-level features.
class_name IslandRegionStruct
extends Node

var tile_vector_list: PackedVector2Array
var size: int:
	get:
		return len(tile_vector_list)
var average_elevation: float:
	get:
		return _total_elevation / size
var center_vector: Vector2:
	get:
		return Vector2((_min_x + _max_x) / 2, (_min_y + _max_y) / 2)
var _total_elevation: float
var _min_x: float = +INF
var _max_x: float = -INF
var _min_y: float = +INF
var _max_y: float = -INF
var _tile_types_present: Dictionary[IslandGenerator.TileType, bool]


func add(elevation: float, x: int, y: int, tile_type: IslandGenerator.TileType) -> void:
	tile_vector_list.append(Vector2(x, y))
	_total_elevation += elevation
	_max_x = max(x, _max_x)
	_min_x = min(x, _min_x)
	_max_y = max(y, _max_y)
	_min_y = min(y, _min_y)
	_tile_types_present[tile_type] = true


func all_tile_types_match(tile_type: IslandGenerator.TileType) -> bool:
	return len(_tile_types_present) == 1 and tile_type in _tile_types_present


func any_tile_types_match(tile_type: IslandGenerator.TileType) -> bool:
	return tile_type in _tile_types_present

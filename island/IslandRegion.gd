class_name IslandRegion
extends Node

var positions: Dictionary[Vector2i, int] = {}
var supermin := Vector2i(+INF, +INF)
var supermax := Vector2i(-INF, -INF)


func add(x: int, y: int) -> void:
	positions[Vector2i(x, y)] = 0
	supermin = Vector2i(min(supermin.x, x), min(supermin.y, y))
	supermax = Vector2i(max(supermax.x, x), max(supermax.y, y))


func size() -> int:
	return positions.size()


func superposition() -> Vector2i:
	return (supermin + supermax) / 2

class_name WfcTileData
extends Resource

@export var id: int
@export var allowed: PackedInt64Array = [0, 0, 0, 0, 0, 0, 0, 0]
@export var atlas_coords: Vector2i


func _init(_id: int, _atlas_coords: Vector2i):
	id = _id
	atlas_coords = _atlas_coords

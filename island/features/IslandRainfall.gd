class_name IslandRainfall
extends IslandFeature


func apply(island: Island) -> void:
	var width := island.width()
	var height := island.height()
	var rainfall_map: Array[PackedInt32Array] = []
	for y in height:
		var row := PackedInt32Array()
		row.resize(width)
		row.fill(0)
		rainfall_map.append(row)

	var queue: Array[Vector3i] = []
	for y in height:
		for x in width:
			var tile: Island.Tile = island.get_data(x, y, 'island_map')
			if tile in island.RAINFALL_WEIGHTS:
				var rainfall_weight: int = island.RAINFALL_WEIGHTS[tile]
				queue.append(Vector3i(x, y, rainfall_weight))

	while queue.size() > 0:
		var rainfall := queue.pop_front() as Vector3i
		var x: int = rainfall.x
		var y: int = rainfall.y
		var rainfall_weight := rainfall.z

		if rainfall_weight <= 0:
			continue

		for d in Directions.CARDINAL:
			var dx = x + d.x
			var dy = y + d.y

			if dx < 0 or dy < 0 or dx >= width or dy >= height:
				continue

			var _rainfall_weight = rainfall_weight - 1

			if _rainfall_weight > rainfall_map[dy][dx]:
				rainfall_map[dy][dx] = _rainfall_weight
				queue.append(Vector3i(dx, dy, _rainfall_weight))

	for y in height:
		for x in width:
			var rainfall_weight := rainfall_map[y][x]
			island.set_data(x, y, Island.Layer.RAINFALL, rainfall_weight)

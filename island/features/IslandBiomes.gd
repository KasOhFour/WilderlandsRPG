class_name IslandBiomes
extends IslandFeature


func apply(island: Island) -> void:
	var width := island.width()
	var height := island.height()
	var biome_map: Array[PackedInt32Array] = []
	var biomes := island.get_parameter('biomes') as Array[Island.Biome]
	if biomes.is_empty():
		return

	for y in height:
		var row := PackedInt32Array()
		row.resize(width)
		row.fill(biomes[0])
		biome_map.append(row)

	if biomes.size() == 1:
		_set_data(island, biome_map)
		return

	var mid_width := width / 2.0
	var mid_height := height / 2.0
	var maybe_biomes := island.get_region_map().values()
	for maybe_biome: IslandRegion in maybe_biomes:
		var x := maybe_biome.superposition().x
		var y := maybe_biome.superposition().y
		match island.get_parameter('axis'):
			Island.Axis.NORTHEASTWARD:
				if (x / float(width)) + (y / float(height)) > 1.0:
					for position in maybe_biome.positions:
						biome_map[position.y][position.x] = biomes[1]
			Island.Axis.EASTWARD:
				if y > mid_height:
					for position in maybe_biome.positions:
						biome_map[position.y][position.x] = biomes[1]
			Island.Axis.SOUTHEASTWARD:
				if (x / float(width)) < (y / float(height)):
					for position in maybe_biome.positions:
						biome_map[position.y][position.x] = biomes[1]
			Island.Axis.SOUTHWARD:
				if x > mid_width:
					for position in maybe_biome.positions:
						biome_map[position.y][position.x] = biomes[1]


func _set_data(island: Island, biome_map: Array[PackedInt32Array]) -> void:
	var width := island.width()
	var height := island.height()
	for y in height:
		for x in width:
			island.set_data(x, y, Island.Layer.BIOME, biome_map[y][x])

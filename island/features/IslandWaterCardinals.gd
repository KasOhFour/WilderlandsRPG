class_name IslandWaterCardinals
extends IslandFeature


func apply(island: Island) -> void:
	var width := island.width()
	var height := island.height()
	var water_cardinals := PackedVector3Array()
	for y in height:
		for x in width:
			var tile: Island.Tile = island.get_data(x, y, 'island_map')
			if !island.is_tile_water(tile) or tile == Island.Tile.DEEP_OCEAN:
				continue

			var has_cardinal := false
			for d in Directions.CARDINAL:
				var dx = x + d.x
				var dy = y + d.y

				if dx < 0 or dy < 0 or dx >= width or dy >= height:
					continue

				var cardinal_tile: Island.Tile = island.get_data(dx, dy, 'island_map')
				if island.is_tile_water(cardinal_tile) and cardinal_tile != Island.Tile.DEEP_OCEAN:
					has_cardinal = true
					break

			if has_cardinal:
				continue

			var cardinal: Vector2i = Directions.CARDINAL[Random.seeded_randi(
				island.input_seed,
				['cardinals[%d][%d]' % [x, y], island.position()],
			) % Directions.CARDINAL.size()]
			var water_cardinal: Vector3i = Vector3i(cardinal.x, cardinal.y, tile)

			water_cardinals.append(Vector3i(x, y, 0) + water_cardinal)

	for water_cardinal in water_cardinals:
		var x := water_cardinal.x
		var y := water_cardinal.y
		var tile := Island.Tile.values()[water_cardinal.z] as Island.Tile
		island.set_data(int(x), int(y), Island.Layer.TILE, tile)

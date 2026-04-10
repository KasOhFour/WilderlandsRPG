class_name IslandForests
extends IslandFeature


func apply(island: Island) -> void:
	if island.get_parameter('forest_frequency') <= 0.0:
		return

	var maybe_forests: Array[IslandRegion] = []
	var max_rainfall_weight: int = island.RAINFALL_WEIGHTS.values().reduce(
		func(accum: int, w: int): return max(accum, w)
	)
	for region: IslandRegion in island.get_region_map().values():
		var is_valid_forest := true
		var cumulative_rainfall_weight := 0
		for position in region.positions:
			var tile := island.get_data(
				int(position.x),
				int(position.y),
				'island_map',
			) as Island.Tile
			if !island.is_tile_valid_forest(tile):
				is_valid_forest = false
				break
			cumulative_rainfall_weight += island.get_data(
				int(position.x),
				int(position.y),
				'rainfall_map',
			)
		var mean_rainfall_weight := float(cumulative_rainfall_weight) / region.size()
		if !is_valid_forest or mean_rainfall_weight / max_rainfall_weight < 0.05:
			continue
		maybe_forests.append(region)
	Random.shuffle(island.input_seed, ['island_forests', island.position()], maybe_forests)

	var forest_cap: int = ceil(island.size() * (island.get_parameter('forest_frequency') * 0.05))
	for maybe_forest: IslandRegion in maybe_forests:
		if maybe_forest.size() > forest_cap:
			continue
		forest_cap -= maybe_forest.size()
		for position in maybe_forest.positions:
			island.set_data(
				int(position.x),
				int(position.y),
				Island.Layer.TILE,
				Island.Tile.FOREST,
			)

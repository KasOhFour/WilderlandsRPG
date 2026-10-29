class_name IslandLakes
extends IslandFeature


func apply(island: Island) -> void:
	if island.get_parameter('lake_frequency') <= 0.0:
		return

	var maybe_lakes: Array[IslandRegion] = []
	for region: IslandRegion in island.get_region_map().values():
		var has_nonland := false
		var cumulative_depth := 0.0
		for position in region.positions:
			var tile := island.get_data(
				int(position.x),
				int(position.y),
				'island_map',
			) as Island.Tile
			if tile != Island.Tile.LAND:
				has_nonland = true
				break
			cumulative_depth += island.get_data(
				int(position.x),
				int(position.y),
				'depth_map',
			)
		if has_nonland or cumulative_depth / region.size() > 0.10:
			continue
		maybe_lakes.append(region)
	Random.shuffle(island.input_seed, ['island_lakes', island.position()], maybe_lakes)

	var lake_cap: int = ceil(
		island.size() * island.get_parameter('lake_frequency') * 0.03,
	)
	for maybe_lake: IslandRegion in maybe_lakes:
		if maybe_lake.size() > lake_cap:
			continue
		lake_cap -= maybe_lake.size()
		for position in maybe_lake.positions:
			island.set_data(
				int(position.x),
				int(position.y),
				Island.Layer.TILE,
				Island.Tile.LAKE,
			)

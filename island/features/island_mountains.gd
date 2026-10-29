class_name IslandMountains
extends IslandFeature


func apply(island: Island) -> void:
	if island.get_parameter('mountain_frequency') <= 0.0:
		return

	var maybe_mountains: Array[IslandRegion] = []
	for region: IslandRegion in island.get_region_map().values():
		var has_water := false
		var cumulative_depth := 0.0
		for position in region.positions:
			var tile := island.get_data(
				int(position.x),
				int(position.y),
				'island_map',
			) as Island.Tile
			if island.is_tile_water(tile):
				has_water = true
				break
			cumulative_depth += island.get_data(
				int(position.x),
				int(position.y),
				'depth_map',
			)
		if has_water or cumulative_depth / region.size() < 0.05:
			continue
		maybe_mountains.append(region)
	Random.shuffle(island.input_seed, ['island_mountains', island.position()], maybe_mountains)

	var mountain_cap: int = ceil(
		island.size() * island.get_parameter('mountain_frequency') * 0.03,
	)
	for maybe_mountain: IslandRegion in maybe_mountains:
		if maybe_mountain.size() > mountain_cap:
			continue
		mountain_cap -= maybe_mountain.size()
		for position in maybe_mountain.positions:
			island.set_data(
				int(position.x),
				int(position.y),
				Island.Layer.TILE,
				Island.Tile.MOUNTAIN,
			)

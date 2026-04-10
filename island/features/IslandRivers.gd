class_name IslandRivers
extends IslandFeature


func apply(island: Island) -> void:
	if island.get_parameter('river_frequency') <= 0.0:
		return

	var river_depth_cap: float = 0.10 - island.get_parameter('river_frequency') * 0.13
	for maybe_river: IslandRegion in island.get_region_map().values():
		if river_depth_cap <= Island.COASTAL_OCEAN_MAX_DEPTH:
			break

		for position in maybe_river.positions:
			var tile := island.get_data(
				int(position.x),
				int(position.y),
				'island_map',
			) as Island.Tile
			var depth := island.get_data(int(position.x), int(position.y), 'depth_map') as float
			var noise := island.noise.river_noise.get_noise_2d(position.x, position.y) as float
			if noise > 0.70 and depth < river_depth_cap and !island.is_tile_water(tile):
				island.set_data(
					int(position.x),
					int(position.y),
					Island.Layer.TILE,
					Island.Tile.RIVER,
				)


func _apply(island: Island) -> void:
	if island.get_parameter('river_frequency') <= 0.0:
		return

	var maybe_rivers: Array[IslandRegion] = []
	for region: IslandRegion in island.get_region_map().values():
		var has_terrain := false
		for position in region.positions:
			var tile: Island.Tile = island.get_data(
				int(position.x),
				int(position.y),
				'island_map',
			)
			if !island.is_tile_water(tile) and !has_terrain:
				has_terrain = true
				break
		if !has_terrain:
			continue
		maybe_rivers.append(region)
	island.prioritize_regions(
		maybe_rivers,
		island.get_parameter('river_region_priority'),
	)

	var river_cap: int = ceil(
		island.size() * island.get_parameter('river_frequency') * 0.33,
	)
	for maybe_river: IslandRegion in maybe_rivers:
		if river_cap < 1:
			break

		for position in maybe_river.positions:
			var tile := island.get_data(
				int(position.x),
				int(position.y),
				'island_map',
			) as Island.Tile
			var depth := island.get_data(int(position.x), int(position.y), 'depth_map') as float
			var noise := island.noise.river_noise.get_noise_2d(position.x, position.y) as float
			if noise > 0.8 and depth < 0.2 and !island.is_tile_water(tile):
				island.set_data(
					int(position.x),
					int(position.y),
					Island.Layer.TILE,
					Island.Tile.RIVER,
				)
			river_cap -= 1

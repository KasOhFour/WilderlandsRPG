class_name IslandGenerator
extends Node2D

enum TileType {
	UNDEFINED,
	OCEAN_DEEP,
	OCEAN_COASTAL,
	COASTLINE,
	LAND,
	HILL,
	RIVER,
	LAKE,
	FOREST,
}
enum BiomeType {
	UNDEFINED,
	PALEIC,
	BOREAL,
	TEMPERATE,
	CANTED,
	TROPICAL,
	BASAL,
}
enum RegionDistribution {
	UNDEFINED,
	WEIGHTED_LARGE,
	WEIGHTED_SMALL,
	RANDOM,
}
enum BiomeSplit {
	UNDEFINED,
	NORTH_SOUTH,
	EAST_WEST,
	NORTHWEST_SOUTHEAST,
	NORTHEAST_SOUTHWEST,
}

const MAP_STEPS_MIN := 64
const MAP_STEPS_MAX := 96
const TILES_PER_STEP := 2
const HILL_FREQUENCY_MIN := 0.00
const HILL_FREQUENCY_MAX := 1.00
const RIVER_FREQUENCY_MIN := 0.00
const RIVER_FREQUENCY_MAX := 1.00
const LAKE_FREQUENCY_MIN := 0.00
const LAKE_FREQUENCY_MAX := 1.00
const FOREST_FREQUENCY_MIN := 0.00
const FOREST_FREQUENCY_MAX := 1.00
const BIOME_FREQUENCY_MIN := 0.00
const BIOME_FREQUENCY_MAX := 1.00

var elevation_noise: FastNoiseLite = preload('res://lib/resources/island_elevation_noise.tres')
var region_noise: FastNoiseLite = preload('res://lib/resources/island_region_noise.tres')
var river_noise: FastNoiseLite = preload('res://lib/resources/island_river_noise.tres')
var pass_hills_enabled := true
var pass_rivers_enabled := true
var pass_lakes_enabled := true
var pass_forests_enabled := true
var island_size := 0
var world_seed := _world_seed:
	get:
		return _world_seed
	set(value):
		elevation_noise.seed = value
		region_noise.seed = value
		river_noise.seed = value
		island_size = 0
		_world_seed = value
		_tile_map = []
		_width = 0
		_height = 0
		_hill_frequency = -0.01
		_river_frequency = -0.01
		_lake_frequency = -0.01
		_biome_frequency = -0.01
		_hill_distribution = RegionDistribution.UNDEFINED
		_river_distribution = RegionDistribution.UNDEFINED
		_lake_distribution = RegionDistribution.UNDEFINED
		_biome_split = BiomeSplit.UNDEFINED
var width := _width:
	get:
		if _width == 0:
			seed(_derive_seed('width'))
			_width = randi_range(MAP_STEPS_MIN, MAP_STEPS_MAX) * TILES_PER_STEP
		return _width
var height := _height:
	get:
		if _height == 0:
			seed(_derive_seed('height'))
			_height = randi_range(MAP_STEPS_MIN, MAP_STEPS_MAX) * TILES_PER_STEP
		return _height
var hill_frequency := _hill_frequency:
	get:
		if _hill_frequency < 0.00:
			seed(_derive_seed('hill_frequency'))
			_hill_frequency = randf_range(HILL_FREQUENCY_MIN, HILL_FREQUENCY_MAX)
		return _hill_frequency
var lake_frequency := _lake_frequency:
	get:
		if _lake_frequency < 0.00:
			seed(_derive_seed('lake_frequency'))
			_lake_frequency = randf_range(LAKE_FREQUENCY_MIN, LAKE_FREQUENCY_MAX)
		return _lake_frequency
var river_frequency := _river_frequency:
	get:
		if _river_frequency < 0.00:
			seed(_derive_seed('river_frequency'))
			_river_frequency = randf_range(RIVER_FREQUENCY_MIN, RIVER_FREQUENCY_MAX)
		return _river_frequency
var forest_frequency := _forest_frequency:
	get:
		if _forest_frequency < 0.00:
			seed(_derive_seed('forest_frequency'))
			_forest_frequency = randf_range(FOREST_FREQUENCY_MIN, FOREST_FREQUENCY_MAX)
		return _forest_frequency
var biome_frequency := _biome_frequency:
	get:
		if _biome_frequency < 0.00:
			seed(_derive_seed('biome_frequency'))
			_biome_frequency = randf_range(BIOME_FREQUENCY_MIN, BIOME_FREQUENCY_MAX)
		return _biome_frequency
var hill_distribution := _hill_distribution:
	get:
		if _hill_distribution == RegionDistribution.UNDEFINED:
			seed(_derive_seed('hill_distribution'))
			_hill_distribution = RegionDistribution.values()[randi() % RegionDistribution.values().size()]
		return _hill_distribution
var river_distribution := _river_distribution:
	get:
		if _river_distribution == RegionDistribution.UNDEFINED:
			seed(_derive_seed('river_distribution'))
			_river_distribution = RegionDistribution.values()[randi() % RegionDistribution.values().size()]
		return _river_distribution
var lake_distribution := _lake_distribution:
	get:
		if _lake_distribution == RegionDistribution.UNDEFINED:
			seed(_derive_seed('lake_distribution'))
			_lake_distribution = RegionDistribution.values()[randi() % RegionDistribution.values().size()]
		return _lake_distribution
var forest_distribution := _forest_distribution:
	get:
		if _forest_distribution == RegionDistribution.UNDEFINED:
			seed(_derive_seed('forest_distribution'))
			_forest_distribution = RegionDistribution.values()[randi() % RegionDistribution.values().size()]
		return _forest_distribution
var biome_split := _biome_split:
	get:
		if _biome_split == BiomeSplit.UNDEFINED:
			seed(_derive_seed('biome_distribution'))
			_biome_split = BiomeSplit.values()[clamp(randi() % BiomeSplit.values().size(), 1, BiomeSplit.values().size())]
		return _biome_split
var biomes := _biomes:
	get:
		if _biomes.is_empty():
			var biome_types := BiomeType.values().filter(func(biome_type: BiomeType): return biome_type != 0)
			seed(_derive_seed('biomes'))
			var biome_type_index := randi() % biome_types.size()
			_biomes = [biome_types[biome_type_index]]
			var biome_type_limit: float = max(ceil(biome_frequency * 2), 1)
			if biome_type_limit > 1:
				seed(_derive_seed('biome_adjacency_offset'))
				var adjacency_offset: int = [-1, 1][randi() % 2]
				_biomes.append(biome_types[(biome_type_index + adjacency_offset) % biome_types.size()])
		return _biomes
var _world_seed := 0
var _tile_map: Array[PackedInt32Array]
var _region_map: Dictionary[float, IslandRegionStruct]
var _moisture_map: Array[PackedInt32Array]
var _biome_map: Array[PackedInt32Array]
var _width := 0
var _height := 0
var _hill_frequency := -0.01
var _river_frequency := -0.01
var _lake_frequency := -0.01
var _forest_frequency := -0.01
var _biome_frequency := -0.01
var _hill_distribution := RegionDistribution.UNDEFINED
var _river_distribution := RegionDistribution.UNDEFINED
var _lake_distribution := RegionDistribution.UNDEFINED
var _forest_distribution := RegionDistribution.UNDEFINED
var _biome_split := BiomeSplit.UNDEFINED
var _biomes: Array[BiomeType] = []
var _tile_thresholds := {
	Vector2(-INF, -0.30): TileType.OCEAN_DEEP,
	Vector2(-0.30, -0.10): TileType.OCEAN_COASTAL,
	Vector2(-0.10, -0.03): TileType.COASTLINE,
	Vector2(-0.03, +INF): TileType.LAND,
}
var _moisture_weights := {
	TileType.OCEAN_COASTAL: 11,
	TileType.LAKE: 7,
	TileType.RIVER: 4,
}


func _ready() -> void:
	pass


func _derive_seed(salt: String) -> int:
	return [world_seed, salt].hash()


func _print_info() -> void:
	print('world seed: ', world_seed)
	print('hill_frequency: ', hill_frequency)
	print('lake_frequency: ', lake_frequency)
	print('river_frequency: ', river_frequency)
	print('forest_frequency: ', forest_frequency)
	print('hill_distribution: ', hill_distribution)
	print('lake_distribution: ', lake_distribution)
	print('river_distribution: ', river_distribution)
	print('forest_distribution: ', forest_distribution)
	print('biomes: ', biomes)
	print('biome_split: ', biome_split)


func _generate_island() -> Array[PackedInt32Array]:
	var tile_map: Array[PackedInt32Array]
	for y in height:
		var tiles := PackedInt32Array()
		tiles.resize(width)
		tiles.fill(-1)
		tile_map.append(tiles)
		for x in width:
			var erosion := _pass_erosion(x, y)
			var erosion_strength := 1.0
			var elevation_noise_value := elevation_noise.get_noise_2d(x, y)
			elevation_noise_value -= erosion * erosion_strength
			for threshold in _tile_thresholds.keys():
				if elevation_noise_value >= threshold.x and elevation_noise_value < threshold.y:
					var tile: TileType = _tile_thresholds[threshold]
					tile_map[y][x] = tile
					if tile == TileType.COASTLINE or tile == TileType.LAND:
						island_size += 1

	_tile_map = tile_map

	_generate_regions()
	_pass_hills()
	_pass_rivers()
	_pass_lakes()
	_pass_moisture()
	_pass_forests()
	_pass_biomes()
	_pass_cardinals()
	# _print_info()

	return _tile_map


func _pass_erosion(x: int, y: int) -> float:
	# normalize x,y
	var nx = (x / float(width)) * 2.0 - 1.0
	var ny = (y / float(height)) * 2.0 - 1.0

	# distance from center (0 = center, 1 = corner)
	var d = sqrt(nx * nx + ny * ny)

	# fall-off curve
	var erosion = pow(d, 4.0)

	return clamp(erosion, 0.0, 1.0)


func _generate_regions() -> void:
	var region_map: Dictionary[float, IslandRegionStruct]

	for y in height:
		for x in width:
			var tile_type := _tile_map[y][x]
			var region_noise_value := region_noise.get_noise_2d(x, y)
			var elevation_noise_value := elevation_noise.get_noise_2d(x, y)
			var region: IslandRegionStruct = region_map.get_or_add(region_noise_value, IslandRegionStruct.new())
			region.add(elevation_noise_value, x, y, tile_type)

	_region_map = region_map


func _pass_hills() -> void:
	var tile_map := _tile_map.duplicate()
	var hill_tile_limit: float = ceil(island_size * (hill_frequency * 0.10))

	var prehill_list := _region_map.values().filter(func(p: IslandRegionStruct): return p.all_tile_types_match(TileType.LAND) and p.average_elevation > 0.05)
	if hill_distribution == RegionDistribution.WEIGHTED_LARGE:
		# sort by decreasing hill size
		prehill_list.sort_custom(func(a: IslandRegionStruct, b: IslandRegionStruct): return a.size > b.size)
	elif hill_distribution == RegionDistribution.WEIGHTED_SMALL:
		# sort by increasing hill size
		prehill_list.sort_custom(func(a: IslandRegionStruct, b: IslandRegionStruct): return a.size < b.size)
	elif hill_distribution == RegionDistribution.RANDOM:
		# use random distribution of hill size
		prehill_list.shuffle()

	for prehill: IslandRegionStruct in prehill_list:
		if prehill.size > hill_tile_limit:
			continue
		hill_tile_limit -= prehill.size
		for vector in prehill.tile_vector_list:
			tile_map[vector.y][vector.x] = TileType.HILL

	_tile_map = tile_map


func _pass_rivers() -> void:
	var tile_map := _tile_map.duplicate()
	var river_tile_limit: float = ceil(island_size * river_frequency)
	var river_tile_vector_set: Dictionary[Vector2, int]

	var preriver_list := _region_map.values().filter(func(p: IslandRegionStruct): return p.any_tile_types_match(TileType.LAND))
	if river_distribution == RegionDistribution.WEIGHTED_LARGE:
		# sort by decreasing river size
		preriver_list.sort_custom(func(a: IslandRegionStruct, b: IslandRegionStruct): return a.size > b.size)
	elif hill_distribution == RegionDistribution.WEIGHTED_SMALL:
		# sort by increasing river size
		preriver_list.sort_custom(func(a: IslandRegionStruct, b: IslandRegionStruct): return a.size < b.size)
	elif hill_distribution == RegionDistribution.RANDOM:
		# use random distribution of river size
		preriver_list.shuffle()

	for preriver: IslandRegionStruct in preriver_list:
		if preriver.size > river_tile_limit:
			continue
		river_tile_limit -= preriver.size
		for vector in preriver.tile_vector_list:
			var x := vector.x
			var y := vector.y
			var elevation_noise_value := elevation_noise.get_noise_2d(x, y)
			var river_noise_value := river_noise.get_noise_2d(x, y)
			if river_noise_value > 0.8 and elevation_noise_value < 0.2 and (tile_map[y][x] == TileType.LAND or tile_map[y][x] == TileType.COASTLINE):
				river_tile_vector_set[Vector2(x, y)] = tile_map[y][x]
				tile_map[y][x] = TileType.RIVER

	#for vector in river_tile_vector_set.keys():
		#var has_adjacency := false
		#for d in Directions.ADJACENT:
			#if vector + Vector2(d) in river_tile_vector_set:
				#has_adjacency = true
				#break
		#if not has_adjacency:
			#tile_map[vector.y][vector.x] = river_tile_vector_set[vector]

	_tile_map = tile_map


func _pass_lakes() -> void:
	var tile_map := _tile_map
	var lake_tile_limit: float = ceil(island_size * (lake_frequency * 0.10))

	var prelake_list := _region_map.values().filter(func(p: IslandRegionStruct): return p.all_tile_types_match(TileType.LAND) and p.average_elevation < 0.1)
	if lake_distribution == RegionDistribution.WEIGHTED_LARGE:
		# sort by decreasing lake size
		prelake_list.sort_custom(func(a: IslandRegionStruct, b: IslandRegionStruct): return a.size > b.size)
	elif lake_distribution == RegionDistribution.WEIGHTED_SMALL:
		# sort by increasing lake size
		prelake_list.sort_custom(func(a: IslandRegionStruct, b: IslandRegionStruct): return a.size < b.size)
	elif lake_distribution == RegionDistribution.RANDOM:
		# use random distribution of lake size
		prelake_list.shuffle()

	for prelake: IslandRegionStruct in prelake_list:
		if prelake.size > lake_tile_limit:
			continue
		lake_tile_limit -= prelake.size
		for vector in prelake.tile_vector_list:
			tile_map[vector.y][vector.x] = TileType.LAKE

	_tile_map = tile_map


func _pass_moisture() -> void:
	var tile_map := _tile_map
	var moisture_map: Array[PackedInt32Array] = []

	# intitialize moisture map to 0
	for y in height:
		var row := PackedInt32Array()
		row.resize(width)
		row.fill(0)
		moisture_map.append(row)

	# moisture_weight_vector: (x, y, moisture_weight)
	var moisture_weight_vector_queue: Array[Vector3i] = []

	# water sources
	for y in height:
		for x in width:
			var tile_type := tile_map[y][x]
			if tile_type in _moisture_weights:
				var moisture_weight: int = _moisture_weights[tile_type]
				moisture_weight_vector_queue.append(Vector3i(x, y, moisture_weight))

	# BFS propagation
	while moisture_weight_vector_queue.size() > 0:
		var moisture_weight_vector = moisture_weight_vector_queue.pop_front()
		var x = moisture_weight_vector.x
		var y = moisture_weight_vector.y
		var moisture_weight = moisture_weight_vector.z

		if moisture_weight <= 0:
			continue

		for d in Directions.CARDINAL:
			var dx = x + d.x
			var dy = y + d.y

			if dx < 0 or dy < 0 or dx >= width or dy >= height:
				continue

			var next_moisture_weight = moisture_weight - 1

			# only overwrite if stronger influence
			if next_moisture_weight > moisture_map[dy][dx]:
				moisture_map[dy][dx] = next_moisture_weight
				moisture_weight_vector_queue.append(Vector3i(dx, dy, next_moisture_weight))

	_moisture_map = moisture_map


func _pass_forests() -> void:
	var tile_map := _tile_map.duplicate()
	var forest_tile_limit: float = ceil(island_size * (forest_frequency * 0.40))
	var max_moisture_weight: int = _moisture_weights.values().reduce(func(accum: int, w: int): return max(accum, w))

	var preforest_list := _region_map.values().filter(func(p: IslandRegionStruct): return not (p.any_tile_types_match(TileType.OCEAN_DEEP) or p.any_tile_types_match(TileType.OCEAN_COASTAL) or p.any_tile_types_match(TileType.COASTLINE)))
	if forest_distribution == RegionDistribution.WEIGHTED_LARGE:
		# sort by decreasing forest size
		preforest_list.sort_custom(func(a: IslandRegionStruct, b: IslandRegionStruct): return a.size > b.size)
	elif forest_distribution == RegionDistribution.WEIGHTED_SMALL:
		# sort by increasing forest size
		preforest_list.sort_custom(func(a: IslandRegionStruct, b: IslandRegionStruct): return a.size < b.size)
	elif forest_distribution == RegionDistribution.RANDOM:
		# use random distribution of forest size
		preforest_list.shuffle()

	for preforest: IslandRegionStruct in preforest_list:
		if preforest.size > forest_tile_limit:
			continue
		var total_moisture_weight := 0
		for vector in preforest.tile_vector_list:
			var moisture_weight := _moisture_map[vector.y][vector.x]
			total_moisture_weight += moisture_weight

		var average_moisture_weight: float = float(total_moisture_weight) / preforest.size
		var moisture_value := average_moisture_weight / max_moisture_weight
		if moisture_value > 0.05:
			for vector in preforest.tile_vector_list:
				var tile_type: TileType = tile_map[vector.y][vector.x]
				if tile_type == TileType.LAND:
					tile_map[vector.y][vector.x] = TileType.FOREST
					forest_tile_limit -= 1

	_tile_map = tile_map


func _pass_biomes() -> void:
	var biome_map: Array[PackedInt32Array] = []
	var primary_biome := biomes[0]

	# intitialize biome map to 0
	for y in height:
		var row := PackedInt32Array()
		row.resize(width)
		row.fill(primary_biome)
		biome_map.append(row)

	if biomes.size() == 1:
		_biome_map = biome_map
		return

	var secondary_biome := biomes[1]
	var mid_width := width / 2.0
	var mid_height := height / 2.0
	var prebiome_list := _region_map.values()
	for prebiome: IslandRegionStruct in prebiome_list:
		var x := prebiome.center_vector.x
		var y := prebiome.center_vector.y
		match biome_split:
			BiomeSplit.NORTH_SOUTH:
				if y > mid_height:
					for vector in prebiome.tile_vector_list:
						biome_map[vector.y][vector.x] = secondary_biome
			BiomeSplit.EAST_WEST:
				if x > mid_width:
					for vector in prebiome.tile_vector_list:
						biome_map[vector.y][vector.x] = secondary_biome
			BiomeSplit.NORTHWEST_SOUTHEAST:
				if (x / float(width)) + (y / float(height)) > 1.0:
					for vector in prebiome.tile_vector_list:
						biome_map[vector.y][vector.x] = secondary_biome
			BiomeSplit.NORTHEAST_SOUTHWEST:
				if (x / float(width)) < (y / float(height)):
					for vector in prebiome.tile_vector_list:
						biome_map[vector.y][vector.x] = secondary_biome

	_biome_map = biome_map


func _pass_cardinals() -> void:
	var tile_map := _tile_map.duplicate()
	var cardinal_tiles := PackedVector3Array()

	for y in height:
		for x in width:
			var tile_type: TileType = tile_map[y][x]

			if tile_type != TileType.OCEAN_COASTAL and tile_type != TileType.RIVER and tile_type != TileType.LAKE:
				continue

			var has_cardinal := false
			for d in Directions.CARDINAL:
				var dx = x + d.x
				var dy = y + d.y

				if dx < 0 or dy < 0 or dx >= width or dy >= height:
					continue

				var cardinal_tile_type: TileType = tile_map[dy][dx]
				if cardinal_tile_type == TileType.OCEAN_COASTAL or cardinal_tile_type == TileType.RIVER or cardinal_tile_type == TileType.LAKE:
					has_cardinal = true
					break

			if has_cardinal:
				continue

			_derive_seed('cardinals' + str(x) + str(y))
			var bridge_direction: Vector2i = Directions.CARDINAL[randi() % Directions.CARDINAL.size()]
			var tile_info: Vector3i = Vector3i(bridge_direction.x, bridge_direction.y, tile_type)

			cardinal_tiles.append(Vector3i(x, y, 0) + tile_info)

	for cardinal_tile in cardinal_tiles:
		var x := cardinal_tile.x
		var y := cardinal_tile.y
		var tile_type: TileType = TileType.values()[cardinal_tile.z]
		tile_map[y][x] = tile_type

		_tile_map = tile_map

class_name Island
extends Node

enum Tile {
	UNDEFINED,
	DEEP_OCEAN,
	COASTAL_OCEAN,
	COASTLINE,
	LAND,
	MOUNTAIN,
	RIVER,
	LAKE,
	FOREST,
}
enum Biome {
	UNDEFINED,
	PALEIC,
	BOREAL,
	TEMPERATE,
	TROPICAL,
	BASAL,
}
enum Axis {
	UNDEFINED,
	NORTHEASTWARD,
	EASTWARD,
	SOUTHEASTWARD,
	SOUTHWARD,
}
enum Layer {
	UNDEFINED,
	DEPTH,
	TILE,
	RAINFALL,
	BIOME,
}

const MIN_STEPS := 96
const MAX_STEPS := 128
const TILES_PER_STEP := 2
const DEEP_OCEAN_MAX_DEPTH = -0.30
const COASTAL_OCEAN_MAX_DEPTH = -0.10
const COASTLINE_MAX_DEPTH = -0.03
const LAND_MAX_DEPTH = INF
const TILE_THRESHOLDS := {
	DEEP_OCEAN_MAX_DEPTH: Tile.DEEP_OCEAN,
	COASTAL_OCEAN_MAX_DEPTH: Tile.COASTAL_OCEAN,
	COASTLINE_MAX_DEPTH: Tile.COASTLINE,
	LAND_MAX_DEPTH: Tile.LAND,
}
const RAINFALL_WEIGHTS := {
	Tile.COASTAL_OCEAN: 11,
	Tile.RIVER: 4,
	Tile.LAKE: 7,
}

var input_seed := 0
var noise := load('res://island/noise.tres')
var _parameters := Parameters.new()
var _overrides := Parameters.new()
var _force_generation := true
var _force_resolve_parameters := true
var _is_generating := false
var _data_map := DataMap.new()
var _region_map: Dictionary[float, IslandRegion] = { }
var _water_corner_map: CornerMap = CornerMap.new()
var _land_corner_map: CornerMap = CornerMap.new()
var _mountain_corner_map: CornerMap = CornerMap.new()


func set_input_seed(_input_seed: int) -> void:
	if input_seed == _input_seed:
		return
	input_seed = _input_seed
	noise.depth_noise.seed = _input_seed
	noise.region_noise.seed = _input_seed
	noise.river_noise.seed = _input_seed
	_force_resolve_parameters = true
	_force_generation = true


func set_override(key: String, value) -> void:
	if _overrides[key] == value:
		return
	_overrides[key] = value
	_force_resolve_parameters = true
	_force_generation = true


func clear_overrides() -> void:
	_overrides = Parameters.new()
	_force_resolve_parameters = true
	_force_generation = true


func width() -> int:
	_lazy_resolve_parameters()
	return _parameters.width


func height() -> int:
	_lazy_resolve_parameters()
	return _parameters.height


func position() -> Vector2i:
	_lazy_resolve_parameters()
	return _parameters.position


func size() -> int:
	_lazy_resolve_parameters()
	return width() * height()


func get_parameter(parameter: String) -> Variant:
	_lazy_resolve_parameters()
	return _parameters[parameter]


func generate() -> void:
	if _is_generating:
		return

	_is_generating = true
	_lazy_resolve_parameters()
	_data_map.resize(_parameters.width, _parameters.height)
	for y in _parameters.height:
		for x in _parameters.width:
			set_data(x, y, Layer.DEPTH, noise.depth_noise.get_noise_2d(x, y))
			var region: IslandRegion = _region_map.get_or_add(
				noise.region_noise.get_noise_2d(x, y),
				IslandRegion.new(),
			)
			region.add(x, y)

	var passes := [
		IslandFalloff.new(),
		IslandBase.new(),
		IslandMountains.new(),
		IslandLakes.new(),
		IslandRivers.new(),
		# IslandWaterCardinals.new(),
		IslandRainfall.new(),
		IslandForests.new(),
		IslandBiomes.new(),
	]
	for _pass in passes:
		_pass.apply(self)

	_water_corner_map.resize(_parameters.width, _parameters.height)
	for y in _parameters.height:
		for x in _parameters.width:
			var tile: Tile = get_data(x, y, 'island_map')
			if is_tile_water(tile):
				_water_corner_map.add_corners(x, y, tile)

	_land_corner_map.resize(_parameters.width, _parameters.height)
	for y in _parameters.height:
		for x in _parameters.width:
			var tile: Tile = get_data(x, y, 'island_map')
			if !is_tile_water(tile) and tile != Tile.COASTLINE:
				_land_corner_map.add_corners(x, y, tile)

	_mountain_corner_map.resize(_parameters.width, _parameters.height)
	for y in _parameters.height:
		for x in _parameters.width:
			var tile: Tile = get_data(x, y, 'island_map')
			if tile == Tile.MOUNTAIN:
				_mountain_corner_map.add_corners(x, y, tile)

	_is_generating = false


func get_data(x: int, y: int, map: String) -> Variant:
	_lazy_generate()
	return _data_map[map][y][x]


func set_data(x: int, y: int, layer: Layer, data: Variant) -> void:
	match layer:
		Layer.DEPTH:
			_data_map.depth_map[y][x] = data
		Layer.TILE:
			if is_tile_water(data):
				_data_map.water_map[y][x] = data
				_data_map.island_map[y][x] = data
			else:
				_data_map.terrain_map[y][x] = data
				if !is_tile_water(_data_map.island_map[y][x]):
					_data_map.island_map[y][x] = data
		Layer.RAINFALL:
			_data_map.rainfall_map[y][x] = data
		Layer.BIOME:
			_data_map.biome_map[y][x] = data


func get_region_map() -> Dictionary[float, IslandRegion]:
	_lazy_generate()
	return _region_map


func get_water_corner_map() -> CornerMap:
	_lazy_generate()
	return _water_corner_map


func get_land_corner_map() -> CornerMap:
	_lazy_generate()
	return _land_corner_map


func get_mountain_corner_map() -> CornerMap:
	_lazy_generate()
	return _mountain_corner_map


func is_tile_oceanic_water(tile: Tile) -> bool:
	match tile:
		Tile.DEEP_OCEAN:
			return true
		Tile.COASTAL_OCEAN:
			return true
	return false


func is_tile_continental_water(tile: Tile) -> bool:
	match tile:
		Tile.RIVER:
			return true
		Tile.LAKE:
			return true
	return false


func is_tile_water(tile: Tile) -> bool:
	return is_tile_oceanic_water(tile) or is_tile_continental_water(tile)


func has_downhill_neighbor(x: int, y: int) -> bool:
	var depth: float = get_data(x, y, 'depth_map')
	for oy in [-1, 0, 1]:
		for ox in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			var nx: int = x + ox
			var ny: int = y + oy
			if nx < 0 or nx >= width() or ny < 0 or ny >= height():
				continue
			if get_data(nx, ny, 'depth_map') < depth:
				return true
	return false


func is_tile_valid_forest(tile: Tile) -> bool:
	match tile:
		Tile.UNDEFINED:
			return false
		Tile.MOUNTAIN:
			return false
	return !is_tile_oceanic_water(tile)


func _lazy_generate() -> void:
	if !_force_generation:
		return

	generate()
	_force_generation = false


func _lazy_resolve_parameters() -> void:
	if !_force_resolve_parameters:
		return

	_resolve_parameters()
	_force_resolve_parameters = false


func _resolve_parameters() -> void:
	_parameters.position = (
		_overrides.position
		if !is_nan(_overrides.position.x) or !is_nan(_overrides.position.y)
		else Vector2i.ZERO
	)

	const dimensions := [
		'width',
		'height',
	]
	for dimension in dimensions:
		_parameters[dimension] = (
			_overrides[dimension]
			if _overrides[dimension] > -1
			else Random.seeded_randi(
				input_seed,
				[dimension, _parameters.position],
				MIN_STEPS,
				MAX_STEPS,
			) * TILES_PER_STEP
		)
		print(dimension, ': ', _parameters[dimension])

	_parameters.falloff_curve = (
		_overrides.falloff_curve
		if !is_nan(_overrides.falloff_curve)
		else 1.0
	)

	const frequencies := [
		'mountain',
		'river',
		'lake',
		'forest',
		'biome',
	]
	for frequency in frequencies:
		frequency += '_frequency'
		_parameters[frequency] = (
			_overrides[frequency]
			if !is_nan(_overrides[frequency])
			else Random.seeded_randf(input_seed, [frequency, _parameters.position], 0.0, 1.0)
		)

	_parameters.axis = (
		_overrides.axis
		if _overrides.axis != Axis.UNDEFINED
		else Random.seeded_randi(input_seed, ['axis', _parameters.position], 1, Axis.size() - 1)
	)

	if _overrides.biomes[0] != Biome.UNDEFINED:
		_parameters.biomes = _overrides.biomes
	else:
		var defined_biomes := Biome.values().slice(1)
		var i := Random.seeded_randi(
			input_seed,
			['biomes[0]', _parameters.position],
		) % defined_biomes.size()
		_parameters.biomes[0] = defined_biomes[i]
		if _parameters.biome_frequency > 0.5:
			var offset := (
				-1
				if Random.seeded_randf(
					input_seed,
					['biomes[1]', _parameters.position],
					0.0,
					1.0,
				) < 0.5
				else 1
			)
			var j := (i + offset + defined_biomes.size()) % defined_biomes.size()
			_parameters.biomes.append(defined_biomes[j])


class Parameters:
	var width: int = -1
	var height: int = -1
	var position: = Vector2i(NAN, NAN)
	var falloff_curve: float = NAN
	var mountain_frequency: float = NAN
	var river_frequency: float = NAN
	var lake_frequency: float = NAN
	var forest_frequency: float = NAN
	var biome_frequency: float = NAN
	var axis := Axis.UNDEFINED
	var biomes: Array[Biome] = [Biome.UNDEFINED]


class DataMap:
	var depth_map: Array[PackedFloat64Array] = []
	var water_map: Array[PackedInt32Array] = []
	var terrain_map: Array[PackedInt32Array] = []
	var island_map: Array[PackedInt32Array] = []
	var rainfall_map: Array[PackedInt32Array] = []
	var biome_map: Array[PackedInt32Array] = []


	func resize(width: int, height: int) -> void:
		depth_map.resize(height)
		for y in height:
			depth_map[y] = PackedFloat64Array()
			depth_map[y].resize(width)
			for x in width:
				depth_map[y][x] = 0.0

		var maps := [
			water_map,
			terrain_map,
			island_map,
			rainfall_map,
			biome_map,
		]
		for map: Array[PackedInt32Array] in maps:
			map.resize(height)
			for y in height:
				map[y] = PackedInt32Array()
				map[y].resize(width)
				map[y].fill(0)


class CornerMap:
	var map: Array[PackedByteArray] = []
	var dom: Array[Array] = []
	var width := 0
	var height := 0


	func resize(_width: int, _height: int) -> void:
		map.resize(_height + 1)
		dom.resize(_height + 1)
		for y in _height + 1:
			map[y] = PackedByteArray()
			dom[y] = []
			map[y].resize(_width + 1)
			dom[y].resize(_width + 1)
			for x in _width + 1:
				map[y][x] = 0
				dom[y][x] = { }
		width = _width + 1
		height = _height + 1


	func add_corners(x: int, y: int, tile: Tile) -> void:
		if x < 0 or x >= width - 1 or y < 0 or y >= height - 1:
			return

		const bits: PackedByteArray = [8, 4, 2, 1]
		var i := 0
		for dy: int in [0, 1]:
			for dx: int in [0, 1]:
				var tx := x + dx
				var ty := y + dy
				map[ty][tx] += bits[i]
				if tile not in dom[ty][tx]:
					dom[ty][tx][tile] = 0
				dom[ty][tx][tile] += 1
				i += 1

# region_2d.gd
class_name Region2D
extends Node2D

#const TILE_WEIGHTS := [
	#60.0,
	#0.0,
	#0.0,
	#0.0,
	#0.0,
	#0.0,
	#0.0,
	#0.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
#]
#const TILE_WEIGHTS := [
	#60.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
	#1.0,
#]
const TILE_WEIGHTS := [
	66.6,
	33.3,
	1.0,
	1.0,
	1.0,
	1.0,
	1.0,
	1.0,
	1.0,
	1.0,
]
const X := 100
const Y := 100

const GRASS_PATCH := preload('res://grass_patch_2d.tscn')


func _ready() -> void:
	var total_weight: float = TILE_WEIGHTS.reduce(
		func(accum, weight):
			return accum + weight,
		0,
	)
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	var corner_map := CornerMap.new(X, Y)
	var corner_map2 := CornerMap.new(X, Y)

	for y in Y:
		for x in X:
			var roll := randf() * total_weight

			for i: int in range(len(TILE_WEIGHTS)):
				roll -= TILE_WEIGHTS[i]
				if roll <= 0.0:
					$GroundTMLayer.set_cell(Vector2i(x, y), 0, Vector2(i, 0))
					break

			var noise_value := noise.get_noise_2d(x, y)

			if noise_value > -0.25:
				corner_map.add_corners(x, y)
				# $GrassTMLayer.set_cell(Vector2i(x, y), 0, Vector2(2, 5))

			if noise_value > -0.00:
				corner_map2.add_corners(x, y)


			const TINT_STRENGTH := 0.33
			var grass_gradient: GradientTexture1D = load('res://assets/grass_gradient.tres')
			if false and noise_value > 0.00 and noise_value <= 0.25:
				var tint := grass_gradient.gradient.sample(randf())
				for i in range(0, 8):
					var grass_patch := GRASS_PATCH.instantiate()
					var mat: Material = grass_patch.material.duplicate(true)
					grass_patch.material = mat
					mat.set_shader_parameter('tint_color', tint)
					mat.set_shader_parameter('tint_strength', TINT_STRENGTH)
					grass_patch.position = Vector2(x * 16 + randf_range(0, 15) + 8, y * 16 + randf_range(0, 15) + 8)
					$GrassPatches.add_child(grass_patch)

	for y in Y:
		for x in X:
			var mask = corner_map.map[y][x]
			var offset = 4 * randi_range(0, 3)
			var atlas = DualGrid.ATLAS[mask] + Vector2i(offset, 0)
			$GrassTMLayer.set_cell(Vector2i(x, y), 2, atlas)
			$GrassShader00TMLayer.set_cell(Vector2i(x, y), 3, atlas)
			$GrassShader01TMLayer.set_cell(Vector2i(x, y), 4, atlas)

			var mask2 = corner_map2.map[y][x]
			var offset2 = 4 * randi_range(0, 3)
			var atlas2 = DualGrid.ATLAS[mask2] + Vector2i(offset2, 0)
			$TopGrassTMLayer.set_cell(Vector2i(x, y), 5, atlas2)
			$TopGrassShader00TMLayer.set_cell(Vector2i(x, y), 6, atlas2)


class CornerMap:
	var map: Array[PackedByteArray] = []
	var width := 0
	var height := 0


	func _init(_width: int, _height: int) -> void:
		resize(_width, _height)


	func resize(_width: int, _height: int) -> void:
		map.resize(_height)
		for y in _height:
			map[y] = PackedByteArray()
			map[y].resize(_width)
			for x in _width:
				map[y][x] = 0
		width = _width
		height = _height


	func add_corners(x: int, y: int) -> void:
		if x < 0 or x >= width - 1 or y < 0 or y >= height - 1:
			return

		const bits: PackedByteArray = [8, 4, 2, 1]
		var i := 0
		for dy: int in [0, 1]:
			for dx: int in [0, 1]:
				var tx := x + dx
				var ty := y + dy
				map[ty][tx] += bits[i]
				i += 1

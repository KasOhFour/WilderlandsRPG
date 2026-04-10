extends Node2D

@onready var water_gradient_material: ShaderMaterial = preload('res://assets/shaders/water_gradient.tres')
@onready var shadow_material: ShaderMaterial = preload('res://assets/shaders/shadow.tres')
@onready var terrain_layer := $TerrainLayer
@onready var shadow_layer := $ShadowLayer
@onready var detail_layer := $DetailLayer
@onready var water_layer := $WaterLayer

# Colors for each tile type
const TILE_COLORS := {
	1: Color(0.0, 0.1, 0.4), # OCEAN_DEEP
	2: Color(0.1, 0.3, 0.7), # OCEAN_COASTAL
	3: Color('#f0d696'), # COASTLINE
	4: Color('#ad9d62'), # LAND
	5: Color('#594a45'), # HILL
	6: Color(0.1, 0.3, 0.7), # RIVER
	7: Color(0.0, 0.1, 0.4), # LAKE
	8: Color('#887c56'), # FOREST
}
# Colors for each biome type
const BIOME_COLORS := {
	1: Color(1.0, 1.0, 1.0, 0.5), # PALEIC
	2: Color(0.4, 0.2, 0.0, 0.4), # BOREAL
	3: Color(0.0, 0.0, 0.0, 0.0), # TEMPERATE
	4: Color(0.0, 0.0, 0.5, 0.4), # CANTED
	5: Color(0.4, 0.8, 0.1, 0.4), # TROPICAL
	6: Color(0.7, 0.2, 0.7, 0.4), # BASAL
}

@export var tile_size := 16 # how big each tile should appear onscreen
@export var island_generator := IslandGenerator.new() # drag your IslandGenerator node into this

var island_map: Array[PackedInt32Array] # will hold the generated result
var tile_set: TileSet = preload('res://assets/island/island.tres')
var island := Island.new()


func _ready():
	# Generate the map once the node is ready
	island.set_input_seed(randi())
	print(island.input_seed)
	island_map = island_generator._generate_island()
	_scale_to_fit()
	#terrain_layer.draw_func = Callable(self, '_draw_terrain_layer')
	#terrain_layer.draw_args = [terrain_layer, island]
	#water_layer.draw_func = Callable(self, '_draw_water_layer')
	#water_layer.draw_args = [water_layer, island]
	#detail_layer.draw_func = Callable(self, '_draw_detail_layer')
	#detail_layer.draw_args = [detail_layer, island]
	queue_redraw()
	terrain_layer.queue_redraw()
	water_layer.queue_redraw()
	detail_layer.queue_redraw()


func _draw_terrain_layer(child: Node2D, island: Island) -> void:
	# a58a62
	for y in island.height():
		for x in island.width():
			# var tile: Island.Tile = island.get_data(x, y, 'terrain_map')
			# var color := Color('#a58a62') if tile != Island.Tile.COASTLINE else TILE_COLORS[3]
			child.draw_rect(
				Rect2(
					Vector2(x * tile_size, y * tile_size),
					Vector2(tile_size, tile_size),
				),
				TILE_COLORS[3],
				true,
			)


func _draw_water_layer(child: Node2D, island: Island) -> void:
	#var img := Image.create(island.width(), island.height(), false, Image.FORMAT_RF)
#
	#for y in island.height():
		#for x in island.width():
			#var tile: Island.Tile = island.get_data(x, y, 'island_map')
			#var depth: float = island.get_data(x, y, 'depth_map')
			#depth = remap(depth, -1.0, 1.0, 0.0, 1.0)
			#img.set_pixel(x, y, Color(depth, 0, 0))
#
	#var depth_texture := ImageTexture.create_from_image(img)
	#child.material = water_gradient_material
	#child.material.set_shader_parameter('height_map', depth_texture)
	#child.material.set_shader_parameter('map_size', Vector2(island.width() * tile_size, island.height() * tile_size))

	var map := island.get_water_corner_map()
	# print(map.dom)
	for y in map.height:
		for x in map.width:
			var mask = map.map[y][x]
			if mask == 0:
				continue

			var tiles = map.dom[y][x].keys()
			tiles.sort_custom(func(a, b): return map.dom[y][x][a] > map.dom[y][x][b])
			var tile: Island.Tile = tiles[0]
			var source_id := 1 if island.is_tile_oceanic_water(tile) else 0
			var offset := 5 * randi_range(0, 4)
			var atlas_source = tile_set.get_source(source_id) # ocean
			var atlas = DualGrid.ATLAS[mask] + Vector2i(offset, 0)
			var region = atlas_source.get_tile_texture_region(atlas)
			# Draw at half-tile offset
			child.draw_texture_rect_region(
				atlas_source.texture,
				Rect2(Vector2((x - 0.5) * tile_size, (y - 0.5) * tile_size), Vector2(tile_size, tile_size)),
				region,
			)
			#atlas_source = tile_set.get_source(5)
			#region = atlas_source.get_tile_texture_region(atlas)
			#child.draw_texture_rect_region(
				#atlas_source.texture,
				#Rect2(Vector2((x - 0.5) * tile_size, (y - 0.5) * tile_size), Vector2(tile_size, tile_size)),
				#region,
			#)
			var layer: TileMapLayer = child
			layer.set_cell(
				Vector2((x - 0.5) * tile_size, (y - 0.5) * tile_size),   # cell coords
				5,                # tileset source id
				atlas             # atlas coords (frame 0)
			)


func _draw_detail_layer(child: Node2D, island: Island) -> void:
	for region: IslandRegion in island.get_region_map().values():
		RegionAnchor.set_anchors(region, island, Island.Tile.MOUNTAIN)
		for position in region.positions:
			var x := position.x
			var y := position.y
			var weight := region.positions[position]
			while weight > 0:
				var sprite := Sprite2D.new()

				var size: String = ['16x16', '32x32', '48x48'][weight - 1]
				sprite.texture = load('res://assets/island/mountain_%s.png' % size)

				var sprite_size := tile_size * weight
				var jitter_x := randi_range(-3, 3)
				var jitter_y := randf_range(-3, 3)

				# X: unchanged, still centered correctly
				var center_x := x * tile_size + (sprite_size * 0.5) + jitter_x

				# Y: move to foot instead of center
				var foot_y := y * tile_size + sprite_size + jitter_y

				sprite.position = Vector2(center_x, foot_y)

				# Lift sprite so its bottom touches the foot
				sprite.offset = Vector2(0, -sprite_size * 0.5)

				sprite.flip_h = randf() < 0.5

				detail_layer.add_child(sprite)

				var shadow := Sprite2D.new()
				shadow.texture = sprite.texture
				shadow.position = sprite.position
				shadow.offset = sprite.offset
				shadow.position += Vector2(0, 6 * weight)
				shadow.flip_h = sprite.flip_h
				shadow.flip_v = true
				# shadow.material = shadow_material
				shadow_layer.add_child(shadow)
				shadow.material = shadow_material

				weight -= 1

	var land_map := island.get_land_corner_map()
	# print(map.dom)
	for y in land_map.height:
		for x in land_map.width:
			var mask = land_map.map[y][x]
			if mask == 0:
				continue

			var source_id := 2
			var offset := 5 * randi_range(0, 3)
			var atlas_source = tile_set.get_source(source_id) # ocean
			var atlas = DualGrid.ATLAS[mask] + Vector2i(offset, 0)
			var region = atlas_source.get_tile_texture_region(atlas)
			# Draw at half-tile offset
			child.draw_texture_rect_region(
				atlas_source.texture,
				Rect2(Vector2((x - 0.5) * tile_size, (y - 0.5) * tile_size), Vector2(tile_size, tile_size)),
				region,
			)

	var mountain_map := island.get_mountain_corner_map()
	# print(map.dom)
	for y in mountain_map.height:
		for x in mountain_map.width:
			var mask = mountain_map.map[y][x]
			if mask == 0:
				continue

			var source_id := 3
			var offset := 5 * randi_range(0, 3)
			var atlas_source = tile_set.get_source(source_id) # ocean
			var atlas = DualGrid.ATLAS[mask] + Vector2i(offset, 0)
			var region = atlas_source.get_tile_texture_region(atlas)
			# Draw at half-tile offset
			child.draw_texture_rect_region(
				atlas_source.texture,
				Rect2(Vector2((x - 0.5) * tile_size, (y - 0.5) * tile_size), Vector2(tile_size, tile_size)),
				region,
			)


func _draw():
	pass
	#var width := island.width()
	#var height := island.height()
	#for y in height:
	#for x in width:
	#var tile: Island.Tile = island.get_data(x, y, 'island_map')

	#for y in island.height():
		#for x in island.width():
			#var tile: Island.Tile = island.get_data(x, y, 'terrain_map')
			#if tile == Island.Tile.UNDEFINED:
				#terrain_layer.draw_rect(
					#Rect2(
						#Vector2(x * tile_size, y * tile_size),
						#Vector2(tile_size, tile_size),
					#),
					#TILE_COLORS[3],
					#true,
				#)
				#continue
#
			#var color = TILE_COLORS.get(tile, Color.BLACK)
			#draw_rect(
				#Rect2(
					#Vector2(x * tile_size, y * tile_size),
					#Vector2(tile_size, tile_size),
				#),
				#TILE_COLORS[3],
				#true,
			#)

			#if tile == Island.Tile.MOUNTAIN:
				#var sprite := Sprite2D.new()
				#var size: String = ['16x16', '32x32', '48x48'][0]
				#sprite.texture = load('res://assets/island/mountain_%s.png' % size)
				#sprite.position = Vector2(x * tile_size + 8, y * tile_size + 8)
				#add_child(sprite)

	#var img := Image.create(island.width(), island.height(), false, Image.FORMAT_RF)
#
	#for y in island.height():
		#for x in island.width():
			#var depth: float = island.get_data(x, y, 'depth_map')
			#depth = remap(depth, -1.0, 1.0, 0.0, 1.0)
			#img.set_pixel(x, y, Color(depth, 0, 0))
#
	#var depth_texture := ImageTexture.create_from_image(img)
	#material = water_gradient_material
	#material.set_shader_parameter('height_map', depth_texture)
	#material.set_shader_parameter('map_size', Vector2(island.width() * tile_size, island.height() * tile_size))

	#for region: IslandRegion in island.get_region_map().values():
		#RegionAnchor.set_anchors(region, island, Island.Tile.MOUNTAIN)
		#for position in region.positions:
			#var x := position.x
			#var y := position.y
			#var weight := region.positions[position]
			#while weight > 0:
				#var sprite := Sprite2D.new()
#
				#var size: String = ['16x16', '32x32', '48x48'][weight - 1]
				#sprite.texture = load('res://assets/island/mountain_%s.png' % size)
#
				#var sprite_size := tile_size * weight
				#var jitter_x := randi_range(-3, 3)
				#var jitter_y := randf_range(-3, 3)
#
				## X: unchanged, still centered correctly
				#var center_x := x * tile_size + (sprite_size * 0.5) + jitter_x
#
				## Y: move to foot instead of center
				#var foot_y := y * tile_size + sprite_size + jitter_y
#
				#sprite.position = Vector2(center_x, foot_y)
#
				## Lift sprite so its bottom touches the foot
				#sprite.offset = Vector2(0, -sprite_size * 0.5)
#
				#sprite.flip_h = randf() < 0.5
#
				#detail_layer.add_child(sprite)
#
				#var shadow := Sprite2D.new()
				#shadow.texture = sprite.texture
				#shadow.position = sprite.position
				#shadow.offset = sprite.offset
				#shadow.position += Vector2(0, 6 * weight)
				#shadow.flip_h = sprite.flip_h
				#shadow.flip_v = true
				## shadow.material = shadow_material
				#shadow_layer.add_child(shadow)
				#shadow.material = shadow_material
#
				#weight -= 1
#
	#var land_map := island.get_land_corner_map()
	## print(map.dom)
	#for y in land_map.height:
		#for x in land_map.width:
			#var mask = land_map.map[y][x]
			#if mask == 0:
				#continue
#
			#var source_id := 2
			#var offset := 5 * randi_range(0, 3)
			#var atlas_source = tile_set.get_source(source_id) # ocean
			#var atlas = DualGrid.ATLAS[mask] + Vector2i(offset, 0)
			#var region = atlas_source.get_tile_texture_region(atlas)
			## Draw at half-tile offset
			#draw_texture_rect_region(
				#atlas_source.texture,
				#Rect2(Vector2((x - 0.5) * tile_size, (y - 0.5) * tile_size), Vector2(tile_size, tile_size)),
				#region,
			#)
#
	#var mountain_map := island.get_mountain_corner_map()
	## print(map.dom)
	#for y in mountain_map.height:
		#for x in mountain_map.width:
			#var mask = mountain_map.map[y][x]
			#if mask == 0:
				#continue
#
			#var source_id := 3
			#var offset := 5 * randi_range(0, 3)
			#var atlas_source = tile_set.get_source(source_id) # ocean
			#var atlas = DualGrid.ATLAS[mask] + Vector2i(offset, 0)
			#var region = atlas_source.get_tile_texture_region(atlas)
			## Draw at half-tile offset
			#draw_texture_rect_region(
				#atlas_source.texture,
				#Rect2(Vector2((x - 0.5) * tile_size, (y - 0.5) * tile_size), Vector2(tile_size, tile_size)),
				#region,
			#)

	#var map := island.get_water_corner_map()
	## print(map.dom)
	#for y in map.height:
		#for x in map.width:
			#var mask = map.map[y][x]
			#if mask == 0:
				#continue
#
			#var tiles = map.dom[y][x].keys()
			#tiles.sort_custom(func(a, b): return map.dom[y][x][a] > map.dom[y][x][b])
			#var tile: Island.Tile = tiles[0]
			#var source_id := 1 if island.is_tile_oceanic_water(tile) else 0
			#var offset := 5 * randi_range(0, 4)
			#var atlas_source = tile_set.get_source(source_id) # ocean
			#var atlas = DualGrid.ATLAS[mask] + Vector2i(offset, 0)
			#var region = atlas_source.get_tile_texture_region(atlas)
			## Draw at half-tile offset
			#draw_texture_rect_region(
				#atlas_source.texture,
				#Rect2(Vector2((x - 0.5) * tile_size, (y - 0.5) * tile_size), Vector2(tile_size, tile_size)),
				#region,
			#)

	#for y in island.height():
		#for x in island.width():
			#var tile: Island.Tile = island.get_data(x, y, 'island_map')
			#if tile == Island.Tile.FOREST:
				#draw_rect(
					#Rect2(
						#Vector2(x * tile_size, y * tile_size),
						#Vector2(tile_size, tile_size),
					#),
					#BIOME_COLORS[5],
					#true,
				#)
		#draw_string(
		#FontFile.new(),
		#Vector2(x * tile_size, y * tile_size),
		#str(mask),
		#HORIZONTAL_ALIGNMENT_LEFT,
		#-1,
		#8
		#)


func _scale_to_fit():
	return
	if island.size() < 1:
		return

	var map_tiles_x := island.width()
	var map_tiles_y := island.height()

	# Convert tile count → pixel size
	var map_pixel_width := map_tiles_x * tile_size
	var map_pixel_height := map_tiles_y * tile_size

	var viewport_size := get_viewport_rect().size

	var scale_x := viewport_size.x / map_pixel_width
	var scale_y := viewport_size.y / map_pixel_height

	var final_scale = min(scale_x, scale_y)

	scale = Vector2(final_scale, final_scale)

class_name IslandBase
extends IslandFeature


func apply(island: Island) -> void:
	var width := island.width()
	var height := island.height()
	for y in height:
		for x in width:
			for threshold in island.TILE_THRESHOLDS.keys():
				if island.get_data(x, y, 'depth_map') < threshold:
					var tile: Island.Tile = island.TILE_THRESHOLDS[threshold]
					island.set_data(x, y, Island.Layer.TILE, tile)
					break

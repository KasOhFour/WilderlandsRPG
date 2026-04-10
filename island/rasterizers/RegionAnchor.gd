class_name RegionAnchor
extends Node

const NEIGHBORS := {
	1: [],
	2: [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)],
	3: [
		Vector2i(2, 0),
		Vector2i(2, 1),
		Vector2i(2, 2),
		Vector2i(1, 2),
		Vector2i(0, 2),
	],
}


static func set_anchors(region: IslandRegion, island: Island, island_tile: Island.Tile) -> void:
	var starting_weight := 1
	for position in region.positions:
		for weight in NEIGHBORS:
			var tile: Island.Tile = island.get_data(position.x, position.y, 'island_map')
			var has_all_neighbors := tile == island_tile
			for neighbor in NEIGHBORS[weight]:
				var d: Vector2i = position + neighbor
				if d.x >= island.width() or d.y >= island.height():
					has_all_neighbors = false
					break

				tile = island.get_data(d.x, d.y, 'island_map')
				if d not in region.positions or tile != island_tile:
					has_all_neighbors = false
					break
			if has_all_neighbors and weight != starting_weight:
				region.positions[position] = weight

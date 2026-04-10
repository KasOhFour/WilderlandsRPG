class_name IslandFalloff
extends IslandFeature


func apply(island: Island) -> void:
	var width := island.width()
	var height := island.height()
	var falloff_curve: float = island.get_parameter('falloff_curve')
	for y in height:
		for x in width:
			var normal := (
				Vector2(x, y) / Vector2(width, height) * 2.0 - Vector2.ONE
			)
			var distance := sqrt(normal.x ** 2 + normal.y ** 2)
			var erosion = pow(distance, 1.0 + 3.0 * falloff_curve)
			var depth := island.get_data(x, y, 'depth_map') as float
			island.set_data(
				x,
				y,
				Island.Layer.DEPTH,
				depth - clamp(erosion, 0.0, 1.0),
			)

# interaction_area.gd
class_name InteractionArea
extends Area2D

const PROJECTIONS := {
	&"north": Vector4(0.0, 12.0, 16.0, 16.0),
	&"east": Vector4(4.0, 16.0, 16.0, 16.0),
	&"south": Vector4(0.0, 20.0, 16.0, 16.0),
	&"west": Vector4(-4.0, 16.0, 16.0, 16.0),
	&"none": Vector4(0.0, 16.0, 24.0, 24.0),
}

@onready var projection := $Projection


func project(towards: StringName) -> void:
	var new_projection: Vector4 = PROJECTIONS.get(towards, "none")
	projection.shape.size = Vector2(new_projection.z, new_projection.w)
	projection.position = Vector2(new_projection.x, new_projection.y)


func get_interactables() -> Array[Area2D]:
	return get_overlapping_areas().filter(
		func(area: Area2D): return area.is_in_group("interactable")
	)

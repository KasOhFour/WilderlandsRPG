# day_night_modulate.md
class_name DayNightModulate
extends CanvasModulate

@export var day_night_texture: GradientTexture1D

func _process(_delta: float) -> void:
	if day_night_texture:
		color = day_night_texture.gradient.sample(Game.date_time.normal_delta)

extends Node2D


var draw_func: Callable
var draw_args: Array = []

func _draw():
	if draw_func:
		draw_func.callv(draw_args)

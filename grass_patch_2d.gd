extends Sprite2D

const GRASS_PATCH_TEXTURES := [
	preload('res://assets/grass_patch_small.png'),
	preload('res://assets/grass_patch_medium.png'),
	preload('res://assets/grass_patch_large.png'),
]

func _ready() -> void:
	texture = GRASS_PATCH_TEXTURES.pick_random()

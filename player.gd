class_name Player extends CharacterBody2D

@onready var player_animation: AnimatedSprite2D = $PlayerAnimation
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var camera_2d: Camera2D = $Camera2D

@export var mask_frames: SpriteFrames

@export var player_material: ShaderMaterial:
	set(value):
		_player_material = value
		if player_animation:
			player_animation.material = _player_material
	get:
		return _player_material

@export var palette_texture: Texture2D:
	set(value):
		_palette_texture = value
		player_material.set_shader_parameter(
			'palette_texture',
			_palette_texture
		)

		var palette_width := _palette_texture.get_width()
		player_material.set_shader_parameter(
			'palette_width',
			palette_width
		)
	get:
		return _palette_texture

const ACCELERATION: float = 0.15
const MAXIMUM_SPEED: float = 1.9
const SHADOW_OSCILLATION_MAP = [0.99, 0.98, 0.97, 0.99, 0.98, 0.97]

var FACING: String = 'south'
var IS_IDLE: bool = false
var CURRENT_SPEED: float = 0.0

var _player_material: ShaderMaterial
var _palette_texture: Texture2D


func _ready() -> void:
	player_material = player_material
	palette_texture = palette_texture
	player_animation.play('idle_' + FACING)
	camera_2d.zoom = Vector2i(2, 2)


func _process(_delta) -> void:
	var anim := player_animation.animation
	var idx := player_animation.frame
	var mask_texture := mask_frames.get_frame_texture(anim, idx)
	player_material.set_shader_parameter('mask_texture', mask_texture)


func _physics_process(_delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x := Input.get_axis('move_w', 'move_e')
	var y := Input.get_axis('move_n', 'move_s')
	var to = 0
	if x or y:
		IS_IDLE = false
		to = MAXIMUM_SPEED
	CURRENT_SPEED = move_toward(CURRENT_SPEED, to, ACCELERATION)
	velocity = Vector2(x, y)
	if x:
		FACING = 'east' if x > 0 else 'west'
		player_animation.play('run_' + FACING)
		if CURRENT_SPEED < 0.25 * MAXIMUM_SPEED:
			player_animation.frame = 4
	elif y:
		FACING = 'south' if y > 0 else 'north'
		player_animation.play('run_' + FACING)
		if CURRENT_SPEED < 0.25 * MAXIMUM_SPEED:
			player_animation.frame = 1
	else:
		IS_IDLE = true
	move_and_collide(velocity.normalized() * CURRENT_SPEED)


func _on_player_animation_frame_changed() -> void:
	if IS_IDLE:
		shadow_sprite.scale = Vector2(1, 1)
		player_animation.play('idle_' + FACING)
	else:
		var shadow_scale = SHADOW_OSCILLATION_MAP[player_animation.frame]
		shadow_sprite.scale = Vector2(shadow_scale, shadow_scale)

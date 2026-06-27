# player_body_2d.gd
class_name PlayerBody2D
extends CharacterBody2D

const DEFAULT_PLAYER := preload('res://player.gd')
const DEFAULT_FACING := 'south'
const DEFAULT_IS_IDLE := true
const DEFAULT_SPEED := 0.00
const ACCELERATION: float = 7.50
const MAXIMUM_SPEED: float = 100.00
const SHADOW_FRAMES_MAP := [0, 0, 1, 0, 0, 1]

@export var mask_frames: SpriteFrames

var player: Player:
	set = _set_player
var facing: String
var is_idle: bool
var speed: float

@onready var frames: AnimatedSprite2D = $Frames
@onready var shadow: AnimatedSprite2D = $Shadow
@onready var camera: Camera2D = $Camera
@onready var collision: CollisionShape2D = $Collision
@onready var magnetic_field: MagneticField = $MagneticField


func _init(
		_player := DEFAULT_PLAYER.new(),
		_facing := DEFAULT_FACING,
		_is_idle := DEFAULT_IS_IDLE,
		_speed := DEFAULT_SPEED,
) -> void:
	player = _player
	facing = _facing
	is_idle = _is_idle
	speed = _speed


func _ready() -> void:
	player = player
	frames.play('idle_' + facing)
	camera.zoom = Vector2i(1.5, 1.5)


func _process(_delta) -> void:
	var shadow_scale := Vector2(1, 1) * (1.0 - (shadow.frame * 0.175))
	var shadow_modulate := Color('a6a6a6') if shadow.frame else Color('808080')

	if shadow.frame:
		shadow.scale = lerp(shadow.scale, shadow_scale, 0.175)
		shadow.modulate = lerp(shadow.modulate, shadow_modulate, 0.175)
	else:
		shadow.scale = shadow_scale
		shadow.modulate = shadow_modulate


func _physics_process(_delta: float) -> void:
	var x := Input.get_axis('move_w', 'move_e')
	var y := Input.get_axis('move_n', 'move_s')
	var to = 0
	if x or y:
		is_idle = false
		to = MAXIMUM_SPEED
	speed = move_toward(speed, to, ACCELERATION)
	if x:
		facing = 'east' if x > 0 else 'west'
		frames.play('run_' + facing)
		if speed < 0.25 * MAXIMUM_SPEED:
			frames.frame = 4
	elif y:
		facing = 'south' if y > 0 else 'north'
		frames.play('run_' + facing)
		if speed < 0.25 * MAXIMUM_SPEED:
			frames.frame = 1
	else:
		is_idle = true
	velocity = Vector2(x, y).normalized() * speed
	move_and_slide()


func _set_player(value: Player) -> void:
	player = value
	if frames:
		frames.material = player.PLAYER_MATERIAL


func _on_player_animation_frame_changed() -> void:
	player.update_mask(frames.animation, frames.frame)

	if is_idle:
		frames.play('idle_' + facing)
		shadow.frame = 0
	else:
		shadow.frame = SHADOW_FRAMES_MAP[frames.frame]

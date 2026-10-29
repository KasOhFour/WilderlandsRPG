# player.gd
class_name Player
extends CharacterBody2D

const DEFAULT_PALETTE := preload('res://entities/player/default_palette.png')
const DEFAULT_INVENTORY_SIZE := 40
const PLAYER_MASK := preload('res://entities/player/default_mask.tres')
const PLAYER_MATERIAL := preload('res://entities/player/default_material.tres')
const DEFAULT_FACING := 'south'
const DEFAULT_IS_IDLE := true
const DEFAULT_SPEED := 0.00
const ACCELERATION: float = 7.50
const MAXIMUM_SPEED: float = 100.00
const SHADOW_FRAMES_MAP := [0, 0, 1, 0, 0, 1]

@export var mask_frames: SpriteFrames

var palette: Texture2D:
	set = _set_palette
var inventory: Inventory
var facing: String
var is_idle: bool
var speed: float

@onready var frames: AnimatedSprite2D = $Frames
@onready var shadow: AnimatedSprite2D = $Shadow
@onready var collision: CollisionShape2D = $Collision
@onready var magnetic_field: MagneticField = $MagneticField
@onready var interaction_area := $InteractionArea


@warning_ignore('shadowed_variable')
func _init(
		palette := DEFAULT_PALETTE,
		inventory := Inventory.new(DEFAULT_INVENTORY_SIZE),
		facing := DEFAULT_FACING,
		is_idle := DEFAULT_IS_IDLE,
		speed := DEFAULT_SPEED,
) -> void:
	self.palette = palette
	self.inventory = inventory
	self.facing = facing
	self.is_idle = is_idle
	self.speed = speed


func _ready() -> void:
	palette = palette
	frames.play('idle_' + facing)


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
	interaction_area.project(facing)
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact'):
		var interactables: Array[Area2D] = interaction_area.get_interactables()
		for interactable: Area2D in interactables:
			if interactable is WoodChest:
				var wood_chest: WoodChest = interactable
				Game.gui.open_ui(wood_chest)
				#interactable.open()
				


func update_mask(animation: String, frame: int) -> void:
	var mask := PLAYER_MASK.get_frame_texture(animation, frame)

	PLAYER_MATERIAL.set_shader_parameter('mask', mask)


func _set_palette(value: Texture2D) -> void:
	palette = value
	PLAYER_MATERIAL.set_shader_parameter('palette', palette)
	PLAYER_MATERIAL.set_shader_parameter('palette_width', palette.get_width())


func _on_player_animation_frame_changed() -> void:
	update_mask(frames.animation, frames.frame)

	if is_idle:
		frames.play('idle_' + facing)
		shadow.frame = 0
	else:
		shadow.frame = SHADOW_FRAMES_MAP[frames.frame]

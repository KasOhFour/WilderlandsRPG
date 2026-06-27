# item_stack_2d.gd
class_name ItemStack2D
extends CharacterBody2D

const DEFAULT_ITEM_STACK := preload('res://item_stack.gd')
const DEFAULT_ITEM_POSITION := Vector2(0.00, 0.00)
const DEFAULT_POSITION := Vector2(0.00, 0.00)
const DEFAULT_VELOCITY := Vector2(0.00, 0.00)
const DEFAULT_NO_PICK_UP_DELTA := 0.00
const DEFAULT_BOUNCE_DAMPING := 0.90
const SCENE := preload('res://item_stack_2d.tscn')
const ACCELERATION := 9.99
const DECELERATION := 99.99
const MAX_SPEED := 999.99
const GRAVITY := 918.00

@export var item_stack: ItemStack:
	set = _set_item_stack

var item_position: Vector2
var attractor: MagneticField
var to_position: Vector2
var speed: float
var no_pick_up_delta: float
var bounce_velocity: float
var bounce_damping: float

@onready var area: Area2D = $Area
@onready var item: Sprite2D = $Item
@onready var audio: AudioStreamPlayer2D = $Audio
@onready var shadow: AnimatedSprite2D = $Shadow
@onready var collision: CollisionShape2D = $Collision


static func instance(
		_item_stack := DEFAULT_ITEM_STACK.new(),
		_item_position := DEFAULT_ITEM_POSITION,
		_velocity := DEFAULT_VELOCITY,
		_position := DEFAULT_ITEM_POSITION,
		_no_pick_up_delta := DEFAULT_NO_PICK_UP_DELTA,
		_bounce_damping := DEFAULT_BOUNCE_DAMPING,
) -> ItemStack2D:
	var item_stack_2d: ItemStack2D = SCENE.instantiate()
	item_stack_2d.item_stack = _item_stack
	item_stack_2d.item_position = _item_position
	item_stack_2d.velocity = _velocity
	item_stack_2d.position = _position
	item_stack_2d.to_position = _position
	item_stack_2d.no_pick_up_delta = _no_pick_up_delta
	item_stack_2d.bounce_velocity = -sqrt(2.0 * GRAVITY * abs(_item_position.y))
	item_stack_2d.bounce_damping = _bounce_damping
	return item_stack_2d


func _ready() -> void:
	item.position = item_position
	area.collision_mask = 0
	_update()


func _process(delta: float) -> void:
	if no_pick_up_delta > 0.00:
		no_pick_up_delta -= delta
	elif area.collision_mask != 1:
		area.collision_mask = 1

	if attractor:
		to_position = attractor.global_position

	var shadow_scale := 1.00 - float(item_stack.item.margins) * 0.12
	var shadow_modulate := 0.651 if item.position.y else 0.502

	shadow_scale = clamp(shadow_scale + item.position.y * 0.003, 0.00, 1.00)
	shadow_modulate = clamp(shadow_modulate - item.position.y * 0.003, 0.00, 0.65)
	shadow.scale = shadow_scale * Vector2(1.00, 1.00)
	shadow.modulate = shadow_modulate * Color(1.00, 1.00, 1.00)


func _physics_process(delta: float) -> void:
	var to_speed := 0.00
	var a := DECELERATION

	if attractor and no_pick_up_delta <= 0.00:
		to_speed = MAX_SPEED
		a = ACCELERATION
		speed = move_toward(speed, to_speed, a)
		velocity = (to_position - global_position).normalized() * speed
	else:
		var x := move_toward(velocity.x, to_speed, ACCELERATION / 3.33)
		var y := move_toward(velocity.y, to_speed, ACCELERATION / 3.33)
		velocity = Vector2(x, y)

	move_and_slide()

	var prev_y := item.position.y

	bounce_velocity += GRAVITY * delta
	item.position.y += bounce_velocity * delta

	if prev_y <= 0.0 and item.position.y > 0.0:
		item.position.y = 0.0
		bounce_velocity = -abs(bounce_velocity) * bounce_damping

	elif item.position.y > 0.0:
		item.position.y = 0.0


func _on_area_entered(entered: Area2D) -> void:
	if entered is MagneticField:
		attractor = entered


func _on_area_exited(exited: Area2D) -> void:
	if exited == attractor:
		attractor = null


func _on_body_entered(entered: Node2D) -> void:
	if entered is PlayerBody2D:
		entered.player.inventory.fill_inventory(item_stack.item, item_stack.count)
		queue_free()


func _set_item_stack(value: ItemStack) -> void:
	item_stack = value
	_update()


func _update() -> void:
	if item and item_stack and item_stack.item:
		item.texture = item_stack.item.texture
		# shadow.scale = (1.00 - item_stack.item.margins * 0.12) * Vector2(1.00, 1.00)

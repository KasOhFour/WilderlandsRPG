class_name Tree2D
extends Node2D

const DEFAULT_HITPOINTS_GAUGE := preload('res://hitpoints.tres')
const MAX_JITTER := 0.44

var hitpoints_gauge: EntityStatusGauge
var move_delta := 0.2
var is_falling := false
var lean := 1.0
var threshold_delta := 1.0
var cumulative_delta := 0.0

@onready var treetop := $Treetop
@onready var treetop_sprite_2d := $Treetop/Sprite2D
@onready var treetop_sway_physics_2d := $Treetop/SwayPhysics2D


func _ready() -> void:
	_update_lean(0.0)
	_update_alignment()
	hitpoints_gauge = DEFAULT_HITPOINTS_GAUGE.duplicate_deep()
	hitpoints_gauge.gauge_minimized.connect(_on_hitpoints_minimized)


func _physics_process(delta: float) -> void:
	cumulative_delta += delta
	fall()
	if treetop and cumulative_delta > threshold_delta:
		threshold_delta = randf_range(0.25, 0.75)
		take_hit(randf_range(0.1, 0.6), [$HitFromLeft, $HitFromRight].pick_random())
		cumulative_delta = 0.0


func take_hit(damage: float, source: Node) -> void:
	if is_falling:
		return

	var direction := 1.0

	if source and source.get('global_position') != null:
		direction *= sign(global_position.x - source.global_position.x)
		if not direction:
			direction = 1.0
	_update_lean(direction)
	hitpoints_gauge.value -= damage
	treetop_sway_physics_2d.add_force(damage * direction)


func fall() -> void:
	if not is_falling:
		return

	var last_rotation: float = treetop.rotation_degrees

	treetop.rotation_degrees = move_toward(
		treetop.rotation_degrees,
		100.0 * -lean,
		move_delta,
	)

	move_delta = clamp(move_delta * 1.02, 0.01, 2.5)

	var rotation_delta: float = abs(
		treetop.rotation_degrees - last_rotation,
	)

	if rotation_delta > 0.001:
		var strength: float = clamp(rotation_delta / 2.5, 0.0, 1.0)

		treetop_sprite_2d.offset = Vector2(
			randf_range(-MAX_JITTER, MAX_JITTER),
			randf_range(-MAX_JITTER, MAX_JITTER),
		) * strength
	else:
		treetop_sprite_2d.offset = Vector2.ZERO
		is_falling = false
		treetop.queue_free()


func _on_hitpoints_minimized() -> void:
	is_falling = true
	_update_alignment()
	treetop_sway_physics_2d.enabled = false


func _align_center() -> void:
	treetop.position = Vector2(0.0, -2.0)
	treetop_sprite_2d.position = Vector2(0.0, -36.0)


func _align_left() -> void:
	treetop.position = Vector2(-4.0, -2.0)
	treetop_sprite_2d.position = Vector2(4.0, -36.0)


func _align_right() -> void:
	treetop.position = Vector2(4.0, -2.0)
	treetop_sprite_2d.position = Vector2(-4.0, -36.0)


func _update_lean(direction: float) -> void:
	if treetop_sway_physics_2d.rest_angle < 0.0:
		lean = 1.0
		return
	if treetop_sway_physics_2d.rest_angle > 0.0:
		lean = -1.0
		return
	lean = direction


func _update_alignment() -> void:
	if lean < 0.0:
		_align_right()
	if lean == 0.0:
		_align_center()
	if lean > 0.0:
		_align_left()

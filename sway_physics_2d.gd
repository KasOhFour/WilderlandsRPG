# sway_physics_2d.gd
class_name SwayPhysics2D
extends Node

@export var stiffness := 0.12
@export var damping := 0.88
@export var max_angle := 30.0
# Angle the spring wants to return to.
# Useful for persistent wind lean.
@export var rest_angle := 0.0
# Constant force applied every frame.
# Useful for steady wind pressure.
@export var wind_force := 0.0
@export var sleep_angle := 0.01
@export var sleep_velocity := 0.01

var angular_velocity := 0.0
var enabled := true

@onready var target: Node2D = get_parent() as Node2D


func _physics_process(delta: float) -> void:
	if target == null:
		return

	if not enabled:
		return

	var angle := target.rotation_degrees

	# Nonlinear spring centered on rest_angle.
	var spring_force := (
		(rest_angle - angle)
		* stiffness
		* (
			1.0
			+ pow(
				abs(angle - rest_angle) / max(max_angle, 0.001),
				2.0,
			) * 8.0
		)
	)

	angular_velocity += spring_force * delta * 60.0
	angular_velocity += wind_force * delta * 60.0

	angular_velocity *= pow(damping, delta * 60.0)

	angle += angular_velocity * delta * 60.0

	if angle > max_angle:
		angle = max_angle
		angular_velocity = min(angular_velocity, 0.0)

	elif angle < -max_angle:
		angle = -max_angle
		angular_velocity = max(angular_velocity, 0.0)

	if (
		abs(angle - rest_angle) < sleep_angle
		and abs(angular_velocity) < sleep_velocity
	):
		angle = rest_angle
		angular_velocity = 0.0

	target.rotation_degrees = angle


func add_force(force: float) -> void:
	angular_velocity += force


func set_wind_lean(angle_degrees: float) -> void:
	rest_angle = clamp(
		angle_degrees,
		-max_angle,
		max_angle,
	)


func reset() -> void:
	angular_velocity = 0.0
	rest_angle = 0.0
	wind_force = 0.0

	if target:
		target.rotation_degrees = 0.0

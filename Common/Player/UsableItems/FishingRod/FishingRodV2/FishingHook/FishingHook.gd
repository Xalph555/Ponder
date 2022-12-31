# Fishing Hook
# ---------------------------------
extends KinematicBody2D
class_name FishingHook


# Signals:
#---------------------------------------
signal hook_hooked


# Variables:
#---------------------------------------
export(float) var terminal_speed := 4500.0

export(float) var gravity := 30.0

export(float) var friction_x := 0.01
export(float) var friction_y := 0.01

var velocity := Vector2.ZERO

var is_moving := false 


onready var col_shape := $LineDistanceVisual/CollisionShape2D


# Functions:
#--------------------------------------
func _physics_process(delta: float) -> void:
	if not is_moving:
		return

	velocity.y += gravity

	apply_friction()

	var collision = move_and_collide(velocity * delta)
	if collision:
		handle_collision(collision)


func handle_collision(col_object : KinematicCollision2D) -> void:
	is_moving = false
	emit_signal("hook_hooked")
	print("hook_hooked signal sent")


func apply_friction() -> void:
	velocity.x = lerp(velocity.x, 0, friction_x)
	velocity.y = lerp(velocity.y, 0, friction_y)


func clamp_terminal_speed() -> void:
	velocity.x = clamp(velocity.x, -terminal_speed, terminal_speed)
	velocity.y = clamp(velocity.y, -terminal_speed, terminal_speed)


func throw_hook(spawn_pos : Vector2, throw_dir : Vector2, throw_force : float) -> void:
	global_position = spawn_pos
	velocity = throw_dir * throw_force

	is_moving = true

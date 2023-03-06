# Fishing Hook
# ---------------------------------
extends KinematicBody2D
class_name FishingHook


# Signals:
#---------------------------------------
signal hook_hooked(col_object)
signal hook_released


# Variables:
#---------------------------------------
export(float) var terminal_speed := 4500.0

export(float) var gravity := 30.0

export(float) var friction_x := 0.01
export(float) var friction_y := 0.01

var velocity := Vector2.ZERO

var hooked_normal := Vector2.ZERO

var is_moving := false 

onready var col_shape := $CollisionShape2D

onready var debug_max_length := $MaxLengthVisualisation/CollisionShape2D


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


func _exit_tree() -> void:
	emit_signal("hook_released")


func handle_collision(col_object : KinematicCollision2D) -> void:
	is_moving = false
	hooked_normal = col_object.normal
	emit_signal("hook_hooked", col_object)

	# print("hook_hooked signal sent")


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


func attach_to_object(obj_to_attach) -> void:
	col_shape.set_deferred("disabled", true)

	set_collision_layer_bit(10, false)
	set_collision_mask_bit(1, false)

	# var pos := self.global_position

	get_parent().remove_child(self)
	obj_to_attach.add_child(self)

	self.global_position = obj_to_attach.global_position

	

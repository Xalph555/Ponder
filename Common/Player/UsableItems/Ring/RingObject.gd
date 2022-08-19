#--------------------------------------#
# Ring Object Script                   #
#--------------------------------------#
extends KinematicBody2D

class_name RingObject


# Variables:
#---------------------------------------
export(float) var max_vertical_speed := 1000.0
export(float) var vertical_accel := 30.0

export(float) var max_horizontal_speed := 80.0
export(float) var horizontal_accel := 10.0

export(float) var base_damage := 0.08

var velocity := Vector2.ZERO
var _input_dir := Vector2.ZERO

var position_offset := Vector2.ZERO

var parent : Player

onready var _ground_collider := $RayCast2D


# Functions:
#---------------------------------------
func set_up_ring(ring_parent : Node, parent_velocity : Vector2, global_pos : Vector2, offset_pos : Vector2) -> void:
	parent = ring_parent
	velocity = parent_velocity
	global_position = global_pos
	position_offset = offset_pos


func set_ring_properties(max_vert_speed : float, ver_accel : float, max_hori_speed : float, hori_accel : float, b_dmg : float) -> void:
	max_vertical_speed = max_vert_speed
	vertical_accel = ver_accel
	max_horizontal_speed = max_hori_speed
	horizontal_accel = hori_accel
	base_damage = b_dmg


func _physics_process(delta: float) -> void:
	if not parent:
		return
	
	update_inputs()
	
	velocity.x = clamp(velocity.x + _input_dir.x * horizontal_accel, -max_horizontal_speed, max_horizontal_speed)
	velocity.y = clamp(velocity.y + vertical_accel, -max_vertical_speed, max_vertical_speed)
	
	# friction
	velocity.x = lerp(velocity.x, 0, 0.2)
	
	var collision = move_and_collide(velocity * delta)

	if collision:
		handle_collision(collision)
	
	# print("Velocity: ", velocity.length())

	# set player's position
	parent.global_position = self.global_position + position_offset


func update_inputs() -> void:
	if _ground_collider.is_colliding():
		_input_dir.x = 0

	else:
		_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	_input_dir = _input_dir.normalized()


func handle_collision(col_object : KinematicCollision2D) -> void:
	var collided_object = col_object.get_collider()

	if collided_object.is_in_group("breakable") and velocity.length() > 380.0:
		# calculate damage - scales with velocity 
		var current_damage = base_damage * velocity.length()
		# print("current damage: ", current_damage)

		# will break object
		if (collided_object.get_health() - current_damage) <= 0:
			velocity *= 0.8
		
		else:
			velocity = Vector2.ZERO

		collided_object.add_health(-current_damage)

	else:
		velocity = move_and_slide(velocity)

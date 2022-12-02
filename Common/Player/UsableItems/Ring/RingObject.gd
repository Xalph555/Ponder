#--------------------------------------#
# Ring Object Script                   #
#--------------------------------------#
extends KinematicBody2D

class_name RingObject


# Variables:
#---------------------------------------
var terminal_speed : float

var vertical_acceleration : float
var vertical_max_speed : float
var vertical_limit_speed : float

var horizontal_acceleration : float
var horizontal_max_speed : float
var horizontal_limit_speed : float

var limit_max_transition : float

var in_air_friction_x : float
var in_air_friction_y : float

var base_damage : float
var damage_velocity_threshold : float

var position_offset := Vector2.ZERO

var player_velocity := Vector2.ZERO

var player : Player

onready var _ground_collider := $RayCast2D


# Functions:
#---------------------------------------
func set_up_ring(ring_parent : Node, parent_velocity : Vector2, global_pos : Vector2, offset_pos : Vector2, speed_terminal : float, accel_vertical : float, max_speed_vertical : float, accel_horizontal : float, max_speed_horizontal : float, transition_lim_max : float, air_fric_x : float, air_fric_y : float, b_dmg : float, dmg_vel_threshold : float) -> void:
	player = ring_parent

	player_velocity = parent_velocity

	global_position = global_pos
	position_offset = offset_pos

	terminal_speed = speed_terminal

	vertical_acceleration = accel_vertical
	vertical_max_speed = max_speed_vertical
	vertical_limit_speed = vertical_max_speed

	horizontal_acceleration = accel_horizontal
	horizontal_max_speed = max_speed_horizontal
	horizontal_limit_speed = horizontal_max_speed

	limit_max_transition = transition_lim_max
	
	in_air_friction_x = air_fric_x
	in_air_friction_y = air_fric_y

	base_damage = b_dmg
	damage_velocity_threshold = dmg_vel_threshold

	player.state_manager.change_state(PlayerBaseState.State.ITEM_OVERRIDE)
	player.player_movement.set_snap(false)


func _exit_tree() -> void:
	player.player_movement.set_velocity(player_velocity)

	if not player.is_on_floor():
		player.state_manager.change_state(PlayerBaseState.State.FALL, {no_jump = true})
		return
	
	if player.is_on_floor():
		player.player_movement.set_snap(true)

		if player.player_movement.velocity.length_squared() > 0.0:
			player.state_manager.change_state(PlayerBaseState.State.WALK)

		else:
			player.state_manager.change_state(PlayerBaseState.State.IDLE)


func _physics_process(delta: float) -> void:
	if not player:
		return

	var input_dir := get_player_input()

	handle_movement(delta, input_dir)

	player.update_sprite(input_dir)
	player.global_position = self.global_position + position_offset


func get_player_input() -> Vector2:
	var input_dir := Vector2.ZERO

	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	return input_dir.normalized()


func handle_movement(delta : float, input_dir : Vector2) -> void:
	player_velocity.y = clamp(player_velocity.y + vertical_acceleration, -vertical_limit_speed, vertical_limit_speed)

	if not _ground_collider.is_colliding():
		player_velocity.x = clamp(player_velocity.x + input_dir.x * horizontal_acceleration, -horizontal_limit_speed, horizontal_limit_speed)

	vertical_limit_speed = lerp(vertical_limit_speed, vertical_max_speed, limit_max_transition)
	horizontal_limit_speed = lerp(horizontal_limit_speed, horizontal_max_speed, limit_max_transition)
	
	apply_friction()
	clamp_terminal_speed()

	var collision = move_and_collide(player_velocity * delta)

	if collision:
		handle_collision(collision)

	# print("Ring Velocity: ", player_velocity.length())


func handle_collision(col_object : KinematicCollision2D) -> void:
	var collided_object = col_object.get_collider()

	if collided_object.is_in_group("breakable") and player_velocity.length() > damage_velocity_threshold:
		var current_damage = base_damage * player_velocity.length()
		# print("current damage: ", current_damage)

		if (collided_object.get_health() - current_damage) <= 0:
			player_velocity *= 0.8
	
		else:
			player_velocity = Vector2.ZERO

		collided_object.add_health(-current_damage)

	else:
		player_velocity = move_and_slide(player_velocity)


func apply_friction() -> void:
	player_velocity.x = lerp(player_velocity.x, 0, in_air_friction_x)
	player_velocity.y = lerp(player_velocity.y, 0, in_air_friction_y)


func clamp_terminal_speed() -> void:
	player_velocity.x = clamp(player_velocity.x, -terminal_speed, terminal_speed)
	player_velocity.y = clamp(player_velocity.y, -terminal_speed, terminal_speed)
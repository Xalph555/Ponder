#--------------------------------------#
# Leaf Object Script                   #
#--------------------------------------#
extends KinematicBody2D
class_name LeafObject


# Variables:
#---------------------------------------
var gravity : float

var terminal_speed : float
var acceleration : float
var max_speed : float
var limit_speed : float

var limit_max_transition : float

var in_air_friction_x : float
var in_air_friction_y : float

var wind_force_multiplier : float

var player : Player


# Functions:
#---------------------------------------
func set_up_leaf(new_player : Node, global_pos : Vector2, grav : float, speed_terminal : float, accel: float, speed_max : float, transition_lim_max : float, air_fric_x : float, air_fric_y : float, wind_multi : float) -> void:
	player = new_player
	global_position = global_pos

	gravity = grav

	terminal_speed = speed_terminal
	acceleration = accel
	max_speed = speed_max
	limit_speed = max_speed

	limit_max_transition = transition_lim_max

	in_air_friction_x = air_fric_x
	in_air_friction_y = air_fric_y

	wind_force_multiplier = wind_multi


func _physics_process(delta: float) -> void:
	if not player:
		return
	
	if player.state_manager.current_state == PlayerBaseState.State.ITEM_OVERRIDE:
		# print("leaf is in control")

		var input_dir = get_movement_input()
		# print("leaf input dir: ", input_dir)

		player.player_movement.move_player(delta, input_dir, acceleration, limit_speed, max_speed, limit_max_transition, false, 0, 0, terminal_speed, gravity)

		# player.player_movement.move_player(delta, input_dir)
	
		apply_friction()

		player.update_sprite(input_dir)

		if player.is_on_floor():
			player.state_manager.set_item_override(false, {}, {no_jump = true})
			# set_gliding(false)
	
	else:
		# print("leaf is not in control")
		pass


func get_movement_input() -> Vector2:
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1

	return input_dir


func apply_friction() -> void:
	var current_velocity = player.player_movement.velocity

	current_velocity.x = lerp(current_velocity.x, 0, in_air_friction_x)
	current_velocity.y = lerp(current_velocity.y, 0, in_air_friction_y)

	player.player_movement.set_velocity(current_velocity)


func apply_wind(wind_force : Vector2) -> void:
	if player.state_manager.current_state != PlayerBaseState.State.ITEM_OVERRIDE:
		player.state_manager.set_item_override(true)
		# set_gliding(true)

	player.player_movement.add_velocity(wind_force * wind_force_multiplier)

	# print("I, the mighty leaf, is being pushed by the wind")

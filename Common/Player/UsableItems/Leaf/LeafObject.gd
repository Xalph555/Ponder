#--------------------------------------#
# Leaf Object Script                   #
#--------------------------------------#
extends KinematicBody2D
class_name LeafObject


# Variables:
#--------------------------------------
var gravity : float

var terminal_speed : float
var acceleration : float
var max_speed : float
var limit_speed : float
var limit_max_transition : float

var up_draft_threshhold : float
var up_draft_force : float

var in_air_friction_x : float
var in_air_friction_y : float

var wind_force_multiplier : float

var player_velocity : Vector2

var player : Player


# Functions:
#---------------------------------------
func set_up_leaf(new_player : Player, global_pos : Vector2, grav : float, \
	speed_terminal : float, accel: float, speed_max : float, transition_lim_max : float, \
	draft_threshold: float, draft_force: float, air_fric_x : float, air_fric_y : float, \
	wind_multi : float) -> void:
	player = new_player
	global_position = global_pos

	gravity = grav

	terminal_speed = speed_terminal
	acceleration = accel
	max_speed = speed_max
	limit_speed = max_speed

	limit_max_transition = transition_lim_max

	up_draft_threshhold = draft_threshold
	up_draft_force = draft_force

	in_air_friction_x = air_fric_x
	in_air_friction_y = air_fric_y

	wind_force_multiplier = wind_multi

	player.state_manager.connect("state_changed", self, "_on_state_changed")

	if player.state_manager.current_state == PlayerBaseState.State.JUMP or \
		player.state_manager.current_state == PlayerBaseState.State.FALL:
		set_gliding(true)

		if player.state_manager.previous_state == PlayerBaseState.State.FALL and \
			player.player_movement.velocity.length() > up_draft_threshhold:
			player_velocity += (-1 * player_velocity.normalized()) * up_draft_force * \
			(player.player_movement.velocity.length() / up_draft_threshhold) 

			print("Updraft from leaf")


func _exit_tree() -> void:
	player.state_manager.disconnect("state_changed", self, "_on_state_changed")
	set_gliding(false, {}, {no_jump = true})


func _physics_process(delta: float) -> void:
	if not player:
		return
	
	if player.state_manager.current_state == PlayerBaseState.State.ITEM_OVERRIDE:
		# print("leaf is in control")
		var input_dir = get_movement_input()

		glide_player(delta, input_dir)

		player.update_sprite(input_dir)

		# restore player control
		if player.is_on_floor():
			set_gliding(false)
	
	else:
		# print("leaf is not in control")
		pass


func glide_player(delta : float, input_dir : Vector2) -> void:
	
	# print("leaf input dir: ", input_dir)

	player_velocity.y += gravity * delta

	player_velocity.x = clamp(player_velocity.x + input_dir.x * acceleration, -limit_speed, limit_speed)
	limit_speed = lerp(limit_speed, max_speed, limit_max_transition)
	
	apply_friction()
	clamp_terminal_speed()

	player_velocity = player.move_and_slide(player_velocity, Vector2.UP)

	
func get_movement_input() -> Vector2:
	var input_dir := Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1

	return input_dir


func apply_friction() -> void:
	player_velocity.x = lerp(player_velocity.x, 0, in_air_friction_x)
	player_velocity.y = lerp(player_velocity.y, 0, in_air_friction_y)


func clamp_terminal_speed() -> void:
	player_velocity.x = clamp(player_velocity.x, -terminal_speed, terminal_speed)
	player_velocity.y = clamp(player_velocity.y, -terminal_speed, terminal_speed)


func set_gliding(can_glide : bool, override_args := {}, fall_args := {}, walk_args := {}, idle_args := {}) -> void:
	if can_glide:
		player_velocity = player.player_movement.velocity * 0.8
		player.state_manager.change_state(PlayerBaseState.State.ITEM_OVERRIDE, override_args)
		player.player_movement.set_snap(false)
		
	else:
		player.player_movement.set_velocity(player_velocity * 0.8)

		if not player.is_on_floor():
			player.state_manager.change_state(PlayerBaseState.State.FALL, fall_args)
			return
		
		if player.is_on_floor():
			player.player_movement.set_snap(true)

			if player.player_movement.velocity.length_squared() > 0.0:
				player.state_manager.change_state(PlayerBaseState.State.WALK, walk_args)

			else:
				player.state_manager.change_state(PlayerBaseState.State.IDLE, idle_args)


func apply_wind(wind_force : Vector2) -> void:
	if player.state_manager.current_state != PlayerBaseState.State.ITEM_OVERRIDE:
		set_gliding(true)

	player_velocity += wind_force * wind_force_multiplier

	# print("I, the mighty leaf, is being pushed by the wind")


func _on_state_changed(new_state : int) -> void:
	if new_state == PlayerBaseState.State.JUMP or new_state == PlayerBaseState.State.FALL:
		set_gliding(true)
		
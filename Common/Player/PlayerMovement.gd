# Player Movement
# ----------------------------------------
extends Node
class_name PlayerMovement 


# Variables:
#---------------------------------------

# Horizontal movement
export(float) var terminal_speed := 4500.0
export var acceleration:= 50.0

export(float) var max_speed := 400.0
onready var limit_speed := max_speed

export(float) var limit_max_transition := 0.2

export(float) var on_floor_friction := 0.25
export(float) var in_air_friction := 0.2

# Move and Slide variables
var _up_dir := Vector2.UP
var _snap_dir := Vector2.DOWN

export(float) var _snap_vec_len := 16.0
export(int) var _max_slides := 4
export(float) var _max_slope_angle := 46.0

var _do_stop_on_slope := true
var _has_infinite_inertia := true

var _snap_vector := _snap_dir * _snap_vec_len

var velocity := Vector2.ZERO

# Jump variables
export(float) var jump_height := 38.0 setget set_jump_height
export(float) var jump_time_to_peak := 0.4 setget set_jump_time_to_peak
export(float) var jump_time_to_descent := 0.4 setget set_jump_time_to_descent

var _jump_velocity : float
var _jump_gravity : float
var _fall_gravity : float

# other
var player: Player


# Functions:
#---------------------------------------
func init(new_player: Player) -> void:
	set_jump_variables()

	_max_slope_angle = deg2rad(_max_slope_angle)

	player = new_player


func move_player(delta: float, dir := Vector2.ZERO, accel := acceleration, speed_limit := limit_speed, speed_max := max_speed, speed_transition := limit_max_transition, apply_default_friction := true, floor_friction := on_floor_friction, air_friction := in_air_friction, speed_terminal := terminal_speed, gravity := get_gravity()) -> void:
	velocity.y += gravity * delta
	
	velocity.x = clamp(velocity.x + dir.x * accel, -speed_limit, speed_limit)
	limit_speed = lerp(speed_limit, speed_max, speed_transition)

	if apply_default_friction:
		apply_default_friction(floor_friction, air_friction)

	clamp_terminal_speed(speed_terminal)

	player_move_and_slide()
	
	# print("Player Velocity: ", velocity)


func player_move_and_slide() -> void:
	velocity = player.move_and_slide_with_snap(velocity, 
												_snap_vector, 
												_up_dir, 
												_do_stop_on_slope, 
												_max_slides, 
												_max_slope_angle, 
												_has_infinite_inertia)
	
	# this was my old movement code - things seem to work fine without this? (16/11/2022)

	# if player.is_on_wall():
	# 	velocity = player.move_and_slide_with_snap(velocity, 
	# 											   _snap_vector, 
	# 											   _up_dir, 
	# 											   _do_stop_on_slope, 
	# 											   _max_slides, 
	# 											   _max_slope_angle, 
	# 											   _has_infinite_inertia)
	
	# else:
	# 	velocity.y = player.move_and_slide_with_snap(velocity, 
	# 											     _snap_vector, 
	# 											     _up_dir, 
	# 											     _do_stop_on_slope, 
	# 											     _max_slides, 
	# 											     _max_slope_angle, 
	# 											     _has_infinite_inertia).y


func set_snap(is_enabled: bool) -> void:
	if is_enabled:
		_snap_vector = _snap_dir * _snap_vec_len
	
	else:
		_snap_vector = Vector2.ZERO
	
	# print("is snap vector enabled: ", is_enabled)


func set_velocity(new_velocity: Vector2) -> void:
	velocity = new_velocity


func add_velocity(vel_to_add: Vector2) -> void:
	velocity += vel_to_add


func get_gravity() -> float:
	return _jump_gravity if velocity.y < 0.0 else _fall_gravity


func clamp_terminal_speed(speed_terminal: float) -> void:
	velocity.x = clamp(velocity.x, -speed_terminal, speed_terminal)
	velocity.y = clamp(velocity.y, -speed_terminal, speed_terminal)


func apply_default_friction(floor_friction : float, air_friciton: float) -> void:
	if player.is_on_floor():
		velocity.x = lerp(velocity.x, 0, floor_friction)
		
	else:
		velocity.x = lerp(velocity.x, 0, air_friciton)


# Jump funcs
func jump_player() -> void:
	velocity.y -= velocity.y
	velocity.y += _jump_velocity


func set_jump_variables() -> void:
	_jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
	_jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
	_fall_gravity = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func set_jump_height(value : float) -> void:
	jump_height = value
	set_jump_variables()

func set_jump_time_to_peak(value : float) -> void:
	jump_time_to_peak = value
	set_jump_variables()

func set_jump_time_to_descent(value : float) -> void:
	jump_time_to_descent = value
	set_jump_variables()

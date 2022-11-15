# Player Movement
# ----------------------------------------
extends Node
class_name PlayerMovement 


# Variables:
#---------------------------------------
const _TERMINAL_SPEED := 4500

const _UP_DIR := Vector2.UP
const _SNAP_DIR := Vector2.DOWN
const _SNAP_VEC_LEN := 33
const _MAX_SLIDES := 4
const _MAX_SLOPE_ANGLE := deg2rad(46)

var _do_stop_on_slope := true
var _has_infinite_inertia := true
var _snap_vector := _SNAP_DIR * _SNAP_VEC_LEN

export(float) var move_speed = 60.0

export(float) var gravity := 100.0

# export(float) var jump_force = 200.0

export var jump_height := 38.0 setget set_jump_height
export var jump_time_to_peak := 0.4 setget set_jump_time_to_peak
export var jump_time_to_descent := 0.4 setget set_jump_time_to_descent

var _jump_velocity : float
var _jump_gravity : float
var _fall_gravity : float

var velocity := Vector2.ZERO

var player: PlayerV2


# Functions:
#---------------------------------------
func init(new_player: PlayerV2) -> void:
	set_jump_variables()
	
	player = new_player


func move_player(delta: float, dir := Vector2.ZERO) -> void:
	velocity.y += get_gravity() * delta
	velocity.x = dir.x * move_speed

	if player.is_on_wall():
		velocity = player.move_and_slide_with_snap(velocity, 
												   _snap_vector, 
												   _UP_DIR, 
												   _do_stop_on_slope, 
												   _MAX_SLIDES, 
												   _MAX_SLOPE_ANGLE, 
												   _has_infinite_inertia)
	
	else:
		velocity.y = player.move_and_slide_with_snap(velocity, 
												     _snap_vector, 
												     _UP_DIR, 
												     _do_stop_on_slope, 
												     _MAX_SLIDES, 
												     _MAX_SLOPE_ANGLE, 
												     _has_infinite_inertia).y
	
	print("Player Velocity: ", velocity)


func set_snap(is_enabled: bool) -> void:
	if is_enabled:
		_snap_vector = _SNAP_DIR * _SNAP_VEC_LEN
	
	else:
		_snap_vector = Vector2.ZERO


func get_gravity() -> float:
	return _jump_gravity if velocity.y < 0.0 else _fall_gravity


func jump_player() -> void:
	set_snap(false)

	# velocity.y -= jump_force
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

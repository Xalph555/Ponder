#--------------------------------------#
# Player Script                        #
#--------------------------------------#
extends KinematicBody2D

class_name Player


# Variables:
#---------------------------------------
const _TERMINAL_SPEED := 4500

const _UP_DIR := Vector2.UP
const _SNAP_DIR := Vector2.DOWN
const _SNAP_VEC_LEN := 33
const _MAX_SLIDES := 4
const _MAX_SLOPE_ANGLE := deg2rad(46)

# movement variables
export var acceleration:= 50
export var max_speed := 400

var limit_speed := max_speed

export var on_floor_friction := 0.25
export var in_air_friction := 0.3

var _current_gravity : float

# jump variables
export var jump_height := 38.0 setget set_jump_height
export var jump_time_to_peak := 0.4 setget set_jump_time_to_peak
export var jump_time_to_descent := 0.35 setget set_jump_time_to_descent

var _jump_velocity : float
var _jump_gravity : float
var _fall_gravity : float

var _can_jump := true
var _jump_was_pressed := false

# other variables
var _do_stop_on_slope := true
var _has_infinite_inertia := true
var _snap_vector := _SNAP_DIR * _SNAP_VEC_LEN

var velocity := Vector2.ZERO
var _input_dir := Vector2.ZERO

var is_flying := false

# references
onready var _sprite := $Sprite


# Functions:
#---------------------------------------
func _ready() -> void:
	set_jump_variables()


func _physics_process(delta: float) -> void:
	update_inputs()
	
	velocity.y += 10 # get_gravity() * delta
	velocity.x = clamp(velocity.x + _input_dir.x * acceleration, -limit_speed, limit_speed)
	
	limit_speed = lerp(limit_speed, max_speed, 0.02)
	
	apply_friction()
	clamp_speed()
	
	if is_on_wall(): 
		velocity = move_and_slide_with_snap(velocity, 
											_snap_vector, 
											_UP_DIR, 
											_do_stop_on_slope, 
											_MAX_SLIDES, 
											_MAX_SLOPE_ANGLE, 
											_has_infinite_inertia)
	else:
		velocity.y = move_and_slide_with_snap(velocity, 
											  _snap_vector, 
											  _UP_DIR, 
											  _do_stop_on_slope, 
											  _MAX_SLIDES, 
											  _MAX_SLOPE_ANGLE, 
											  _has_infinite_inertia).y
	
	# Update visuals
	update_sprite()
	
	#print("Velocity: ", velocity)


func update_sprite() -> void:
	# sprite flipping
	if _input_dir.x > 0:
		_sprite.scale.x = 1
		
	elif _input_dir.x < 0:
		_sprite.scale.x = -1
		
	# flip fishing rod


func update_inputs() -> void:
	# Input direction
	_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_input_dir = _input_dir.normalized()
	
	# Jump
	if is_on_floor():
		_can_jump = true
		
		if _jump_was_pressed:
			jump()
	
	else:
		coyote_time()
	
	if Input.is_action_just_pressed("jump"):
		_jump_was_pressed = true
		remember_jump_time()
		
		if _can_jump:
			jump()
		
	else:
		if is_flying:
			_snap_vector = Vector2.ZERO
		
		else:
			_snap_vector = _SNAP_DIR * _SNAP_VEC_LEN


# Jump-related functions
func get_gravity() -> float:
	return _jump_gravity if velocity.y < 0.0 else _fall_gravity


func jump() -> void:
	_snap_vector = Vector2.ZERO
	velocity.y -= velocity.y # to fix 'super jump' bug when going up slopes
	velocity.y += _jump_velocity


func coyote_time() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	_can_jump = false


func remember_jump_time() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	_jump_was_pressed = false


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


# Speed-related functions
func apply_friction() -> void:
	if is_on_floor():
		is_flying = false
		velocity.x = lerp(velocity.x, 0, on_floor_friction)
		
	else:
		velocity.x = lerp(velocity.x, 0, in_air_friction)


func clamp_speed() -> void:
	velocity.x = clamp(velocity.x, -_TERMINAL_SPEED, _TERMINAL_SPEED)
	velocity.y = clamp(velocity.y, -_TERMINAL_SPEED, _TERMINAL_SPEED)


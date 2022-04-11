
extends KinematicBody2D



# Variables:
#---------------------------------------
enum STATES {NORMAL,
			HOOKED}

var current_state = STATES.NORMAL

const _TERMINAL_SPEED := 4500

const _UP_DIR := Vector2.UP
const _SNAP_DIR := Vector2.DOWN
const _SNAP_VEC_LEN := 33
const _MAX_SLIDES := 4
const _MAX_SLOPE_ANGLE := deg2rad(46)

var gravity = 300

export var on_floor_friction := 0.25
export var in_air_friction := 0.2

# movement variables
export var acceleration:= 200
export var max_speed := 500

var limit_speed := max_speed

var _jump_velocity = -150

# other variables
var _do_stop_on_slope := true
var _has_infinite_inertia := true
var _snap_vector := _SNAP_DIR * _SNAP_VEC_LEN

var velocity := Vector2.ZERO
var _input_dir := Vector2.ZERO

var hooked_point := Vector2.ZERO
var hook_dist := 0.0

var ang_vel := 0.0


# Functions:
#---------------------------------------
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	update()
	
	update_inputs()
	
	match (current_state):
		STATES.NORMAL:
			state_normal(delta)
			
		STATES.HOOKED:
			state_hooked(delta)

	clamp_speed()


func state_normal(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = clamp(_input_dir.x * acceleration, -limit_speed, limit_speed)
	
	apply_friction()
	
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


func state_hooked(delta: float) -> void:
	var _distance_to_hook = hooked_point.distance_to(self.global_position)
	var _hook_dir = (hooked_point - self.global_position).normalized()
	
	# applying pendulum angle acceleration
	var angle_accel = -0.25 * cos(hooked_point.direction_to(self.global_position).angle())
	
	angle_accel += _input_dir.x * 0.05
	
	ang_vel += angle_accel
	ang_vel *= 0.99
	
	print("ang velocity: ", ang_vel)
	
	var p_hook_dir := Vector2(sign(ang_vel) * -_hook_dir.y, sign(ang_vel) * _hook_dir.x).normalized()
	var s_force = p_hook_dir * (abs(ang_vel) * hook_dist) 
	
#	print("s force: ", s_force)
	
	velocity = s_force
	
	# adjust postion to max of line length
	if _distance_to_hook > hook_dist:
		self.global_position = hooked_point + (-1 * _hook_dir * hook_dist)
	
#	velocity = move_and_slide_with_snap(velocity, 
#										_snap_vector, 
#										_UP_DIR, 
#										_do_stop_on_slope, 
#										_MAX_SLIDES, 
#										_MAX_SLOPE_ANGLE, 
#										_has_infinite_inertia)

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
											
#	print("Velocity: ", velocity)


func _draw() -> void:
	if current_state == STATES.HOOKED:
		draw_line(Vector2.ZERO, hooked_point - self.global_position, Color.white, 1.5, false)


func update_inputs() -> void:
	# Input direction
	_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_input_dir = _input_dir.normalized()
	
	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			_snap_vector = Vector2.ZERO
			
			velocity.y -= velocity.y # to fix 'super jump' bug when going up slopes
			velocity.y += _jump_velocity
		
	else:
		_snap_vector = _SNAP_DIR * _SNAP_VEC_LEN
	
	# pendulum test
	if Input.is_action_just_pressed("Action1"):
		hooked_point = get_global_mouse_position()
		hook_dist = self.global_position.distance_to(hooked_point)
		ang_vel = sign(velocity.x) * (velocity.length() / hook_dist)
		current_state = STATES.HOOKED
	
	if Input.is_action_just_released("Action1"):
		current_state = STATES.NORMAL


func apply_friction() -> void:
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, on_floor_friction)
		
	else:
		velocity.x = lerp(velocity.x, 0, in_air_friction)


func clamp_speed() -> void:
	velocity.x = clamp(velocity.x, -_TERMINAL_SPEED, _TERMINAL_SPEED)
	velocity.y = clamp(velocity.y, -_TERMINAL_SPEED, _TERMINAL_SPEED)

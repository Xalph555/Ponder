#--------------------------------------#
# Leaf Object Script                   #
#--------------------------------------#
extends KinematicBody2D

class_name LeafObject


# Variables:
#---------------------------------------
const _TERMINAL_SPEED := 4500.0

export(float) var gravity := 60.0

export(float) var acceleration := 5.0
export(float) var max_speed := 180.0

onready var limit_speed := max_speed

export(float) var in_air_friction_x := 0.009
export(float) var in_air_friction_y := 0.035

export(float) var wind_force_multiplier := 4.0

var velocity := Vector2.ZERO
var _input_dir := Vector2.ZERO

var parent : Player

var _just_entered_gliding := false
var _is_being_pushed := false

onready var _wind_timer := $ApplyWindTimer


# Functions:
#---------------------------------------
func set_up_leaf(leaf_parent : Node, parent_velocity : Vector2, global_pos : Vector2) -> void:
	parent = leaf_parent
	velocity = parent_velocity
	global_position = global_pos


func _physics_process(delta: float) -> void:
	if not parent: 
		return

	update_inputs()		

	#print("Input_dir Leaf: ", _input_dir)
	
	if not parent.is_on_floor() or _is_being_pushed:
		switch_gliding(true)
		apply_glide(delta)
		#print("should be able to glide")

	else:
		switch_gliding(false)
		#print("should not be able to glide")


func update_inputs() -> void:
	_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	_input_dir = _input_dir.normalized()


# gliding
func apply_glide(delta : float) -> void:
	velocity.y += gravity * delta

	velocity.x = clamp(velocity.x + _input_dir.x * acceleration, -limit_speed, limit_speed)
	
	limit_speed = lerp(limit_speed, max_speed, 0.01)

	apply_friction()
	clamp_speed()

	parent.velocity = velocity


func switch_gliding(can_glide : bool) -> void:
	if can_glide:
		if _just_entered_gliding:
			#print("entered gliding")
			return
		
		_just_entered_gliding = true

		parent.player_handles_movement = false
		parent.player_can_set_snap = false

		velocity = parent.velocity

	else:
		if not _just_entered_gliding:
			#print("exit gliding")
			return
		
		_just_entered_gliding = false

		parent.player_handles_movement = true
		parent.player_can_set_snap = true

		parent.velocity = velocity
		

# Speed-related functions
func apply_friction() -> void:
	velocity.x = lerp(velocity.x, 0, in_air_friction_x)
	velocity.y = lerp(velocity.y, 0, in_air_friction_y)


func clamp_speed() -> void:
	velocity.x = clamp(velocity.x, -_TERMINAL_SPEED, _TERMINAL_SPEED)
	velocity.y = clamp(velocity.y, -_TERMINAL_SPEED, _TERMINAL_SPEED)


# other
func apply_wind(wind_force : Vector2) -> void:
	_is_being_pushed = true
	velocity += wind_force * wind_force_multiplier

	_wind_timer.start()

	# print("I, the mighty leaf, is being pushed by the wind")


func _on_ApplyWindTimer_timeout() -> void:
	_is_being_pushed = false
	# print("can no longer be pushed - leaf")
	
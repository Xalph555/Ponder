#--------------------------------------#
# Player Script                        #
#--------------------------------------#
extends KinematicBody2D


# Signals:
#---------------------------------------
signal items_ready
signal item_switched(item_num)


# Variables:
#---------------------------------------
const _TERMINAL_SPEED := 4500

const _UP_DIR := Vector2.UP
const _SNAP_DIR := Vector2.DOWN
const _SNAP_VEC_LEN := 33
const _MAX_SLIDES := 4
const _MAX_SLOPE_ANGLE := deg2rad(46)

# movement variables
export var acceleration:= 50.0
export var max_speed := 400.0

onready var limit_speed := max_speed

export var on_floor_friction := 0.25
export var in_air_friction := 0.2

# jump variables
export var jump_height := 38.0 setget set_jump_height
export var jump_time_to_peak := 0.4 setget set_jump_time_to_peak
export var jump_time_to_descent := 0.4 setget set_jump_time_to_descent

var _jump_velocity : float
var _jump_gravity : float
var _fall_gravity : float

var _can_jump := true
var _jump_was_pressed := false

# other movement variables
var _do_stop_on_slope := true
var _has_infinite_inertia := true
var _snap_vector := _SNAP_DIR * _SNAP_VEC_LEN

var velocity := Vector2.ZERO
var _input_dir := Vector2.ZERO

var player_handles_movement := true
# var player_can_set_snap := true
var _has_set_snap_vector := true

# item variables
export(Array, PackedScene) var default_items
var items = {}
var current_item := 0

# references
onready var _item_node := $ActiveTool
onready var _sprite := $Sprite


# Functions:
#---------------------------------------
func _ready() -> void:
	set_jump_variables()
	set_up_default_items()


func _physics_process(delta: float) -> void:
	# update_inputs()
	update_jump_state()
	
	if player_handles_movement:
		player_movement(delta)
	
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
	
	# print("Velocity: ", velocity)


	# Update visuals
	update_sprite()


func _unhandled_input(event: InputEvent) -> void:
	# movement 
	if event.is_action_pressed("move_right"):
		_input_dir.x += 1

	if event.is_action_released("move_right"):
		_input_dir.x -= 1
	
	if event.is_action_pressed("move_left"):
		_input_dir.x -= 1
	
	if event.is_action_released("move_left"):
		_input_dir.x += 1

	_input_dir = _input_dir.normalized()

	# jump
	if event.is_action_pressed("jump"):
		_jump_was_pressed = true
		remember_jump_time()
		
		if _can_jump:
			jump()

	# item switching
	if event.is_action_pressed("Selection1"):
		switch_item(0)
	
	if event.is_action_pressed("Selection2"):
		switch_item(1)

	if event.is_action_pressed("Selection3"):
		switch_item(2)
	
	if event.is_action_pressed("Selection4"):
		switch_item(3)

	if event.is_action_pressed("CycleLeft"):
		switch_item(((current_item - 1) + items.size()) % items.size())
	
	if event.is_action_pressed("CycleRight"):
		switch_item((current_item + 1) % items.size())


func update_sprite() -> void:
	# sprite flipping
	if _input_dir.x > 0:
		_sprite.scale.x = 1
		$ActiveTool.scale.x = 1
		
	elif _input_dir.x < 0:
		_sprite.scale.x = -1
		$ActiveTool.scale.x = -1


func player_movement(delta: float) -> void:
	velocity.y += get_gravity() * delta
	velocity.x = clamp(velocity.x + _input_dir.x * acceleration, -limit_speed, limit_speed)
	
	limit_speed = lerp(limit_speed, max_speed, 0.02)
	
	apply_friction()
	clamp_speed()

	# # handle snap vector setting
	if is_on_floor() and not _has_set_snap_vector:
		_has_set_snap_vector = true
		_snap_vector = _SNAP_DIR * _SNAP_VEC_LEN
		print("snap vector reset")



	# if player_can_set_snap:
	# 	_snap_vector = _SNAP_DIR * _SNAP_VEC_LEN
	
	# else:
	# 	_snap_vector = Vector2.ZERO



# func update_inputs() -> void:
# 	# Jump
# 	# if is_on_floor():
# 	# 	_can_jump = true
		
# 	# 	if _jump_was_pressed:
# 	# 		jump()
	
# 	# else:
# 	# 	coyote_time()
	
# 	if Input.is_action_just_pressed("jump"):
# 		_jump_was_pressed = true
# 		remember_jump_time()
		
# 		if _can_jump:
# 			jump()
		
# 	else:
# 		if player_handles_movement and player_can_set_snap:
# 			_snap_vector = _SNAP_DIR * _SNAP_VEC_LEN
		
# 		else:
# 			_snap_vector = Vector2.ZERO


func disable_snap_vector() -> void:
	if _has_set_snap_vector:
		_snap_vector = Vector2.ZERO
		yield(TempTimer.start_timer(self, 0.5), "timeout")
		_has_set_snap_vector = false

	# yield(TempTimer.start_timer(self, 0.5), "timeout")

	# _snap_vector = _SNAP_DIR * _SNAP_VEC_LEN

	# print("snap vector toggled")


# Jump-related functions
func get_gravity() -> float:
	return _jump_gravity if velocity.y < 0.0 else _fall_gravity


func jump() -> void:
	# _snap_vector = Vector2.ZERO
	disable_snap_vector()
	
	velocity.y -= velocity.y # to fix 'super jump' bug when going up slopes
	velocity.y += _jump_velocity


func update_jump_state() -> void:
	if is_on_floor():
		_can_jump = true
		
		if _jump_was_pressed:
			jump()
	
	else:
		coyote_time()


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
		velocity.x = lerp(velocity.x, 0, on_floor_friction)
		
	else:
		velocity.x = lerp(velocity.x, 0, in_air_friction)


func clamp_speed() -> void:
	velocity.x = clamp(velocity.x, -_TERMINAL_SPEED, _TERMINAL_SPEED)
	velocity.y = clamp(velocity.y, -_TERMINAL_SPEED, _TERMINAL_SPEED)


# item function
func set_up_default_items() -> void:
	for default_item in default_items:
		add_item(default_item)
	
	current_item = 0
	items[current_item].set_active_item(true)

	emit_signal("items_ready")


func switch_item(item_num : int) -> void:
	if item_num == current_item:
		return

	if item_num in items and items[item_num]:
		items[current_item].set_active_item(false)

		items[item_num].set_active_item(true)
		current_item = item_num
	
		emit_signal("item_switched", current_item)


func add_item(item : PackedScene) -> void:
	var item_instance = item.instance()
	_item_node.add_child(item_instance)

	# check if there is a blank space in item slots
	for item in items:
		if not items[item]:
			items[item] = item_instance
			return

	items[items.size()] = item_instance


func remove_item(item_num : int) -> void:
	if item_num in items and items[item_num]:
		items[item_num].call_deferred("free")
		items[item_num] = null

		if item_num == current_item:
			current_item = (current_item + 1) % (items.size() - 1)


# other
func apply_wind(wind_force : Vector2) -> void:
	if player_handles_movement:
		# _snap_vector = Vector2.ZERO
		disable_snap_vector()
		velocity += wind_force
	
	else:
		if items[current_item].has_method("convert_parent_velocity"):
			# items[current_item].convert_parent_velocity(velocity + wind_force)
			items[current_item].angular_velocity += wind_force.normalized().x * wind_force.length() * 0.01

			# print("fishing rod vel converted")


	
	
	
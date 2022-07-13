#--------------------------------------#
# Combined Rod Script                  #
#--------------------------------------#

extends Node2D


# Variables:
#---------------------------------------
export(PackedScene) var hook_physics
export(PackedScene) var hook_continuous

var _hook_instance

# hook properties 
export var min_line_length := 5.0
export var hook_reel_speed := 150

var _line_length := 0.0

var _can_grapple := true
var _can_reel := true

var _distance_to_hook := 0.0
var _hook_dir := Vector2.ZERO

var pullback_vel := Vector2.ZERO

# hook charging properties
export var hook_throw_force_base := 250
export var max_hook_throw_force := 500
export var charge_rate := 3

var _charged_time := 0.0
var _is_charging := false

# hook swing properties
export var swing_force := 0.25
export var push_force := 0.06

export var max_swing_speed := 500.0

var angular_velocity := 0.0

var _input_dir := Vector2.ZERO

# rod properties 
export var rod_start_angle := -45.0

var is_continuous := false

# scene references
onready var _sprite := $PivotPoint/AnimationPivot/Sprite

onready var _pivot_point := $PivotPoint
onready var _hook_point := $PivotPoint/AnimationPivot/HookPoint

onready var _anim_player := $AnimationPlayer
onready var _anim_pivot := $PivotPoint/AnimationPivot

onready var _tween := $Tween

onready var parent = get_parent().get_parent() as Player



# Functions:
#---------------------------------------
func _ready() -> void:
	_pivot_point.rotation_degrees = rod_start_angle

	set_active_item(false)


func set_active_item(is_active : bool) -> void:
	set_process_unhandled_input(is_active)


func _physics_process(delta: float) -> void:
	update()
	
	update_input(delta)
	update_sprite()
	
	if parent.is_on_floor():
		is_continuous = false
	
	if _is_charging:
		_charged_time += charge_rate * delta
	
	if _hook_instance:
		_distance_to_hook = _hook_instance.global_position.distance_to(_hook_point.global_position)
		_hook_dir = (_hook_instance.global_position - _hook_point.global_position).normalized()

		if _hook_instance.is_hooked:
			line_dist_adjust()
			
			if not parent.is_on_floor() and _distance_to_hook > max(1, _line_length - min_line_length):
				if parent.player_handles_movement:
					angular_velocity = sign(parent.velocity.x) * (parent.velocity.length() / _line_length)
					parent.player_handles_movement = false
					
				apply_tension()
			
			else:
				if not parent.player_handles_movement:
					parent.player_handles_movement = true


func _draw() -> void:
	if _hook_instance and _hook_instance.is_hooked:
		draw_line(to_local(_hook_point.global_position), to_local(_hook_instance.global_position), Color.white, 1.01, true)


func update_input(delta: float) -> void:
	# input 
	_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_input_dir = _input_dir.normalized()
	
	if is_continuous:
		continuous_throw_input(delta)
		
	else:
		first_throw_input(delta)
	
	# reel hook
	if Input.is_action_just_released("ui_scroll_up"):
		_line_length += hook_reel_speed * delta
	
	if Input.is_action_just_released("ui_scroll_down") and _can_reel:
		_line_length = max(min_line_length, _line_length - (hook_reel_speed * delta))


func continuous_throw_input(delta: float) -> void:
	if Input.is_action_just_pressed("Action1"):
		if not _hook_instance and _can_grapple:
			_anim_player.play("ThrowHookContinue")
			
			var ang_to_mouse = _pivot_point.global_position.direction_to(get_global_mouse_position()).angle()
			_tween.interpolate_property(_pivot_point, "rotation", 
									_pivot_point.rotation, ang_to_mouse, 
									0.2, Tween.TRANS_SINE,Tween.EASE_IN)
			_tween.start()
		
		if _hook_instance:
			_anim_player.stop()
			release_grapple()
			
			_tween.interpolate_property(_pivot_point, "rotation_degrees", 
									_pivot_point.rotation_degrees, rod_start_angle, 
									0.3, Tween.TRANS_SINE,Tween.EASE_IN)
			_tween.start()
			
			_tween.interpolate_property(_anim_pivot, "rotation", 
									_anim_pivot.rotation, 0, 
									0.3, Tween.TRANS_SINE,Tween.EASE_IN)
			_tween.start()


func first_throw_input(delta: float) -> void:
	# charging rod
	if Input.is_action_just_pressed("Action1"):
		if _can_grapple:
			_anim_player.play("ChargeReady")
			
		else:
			release_grapple()
			
			if not parent.is_on_floor():
				is_continuous = true

	# throw rod
	if Input.is_action_just_released("Action1"):
		_anim_player.stop()
		
		if _hook_instance:
			return
			
		if _is_charging:
			_is_charging = false
			_anim_player.play("ThrowHookFirst")
			
		else:
			_tween.interpolate_property(_pivot_point, "rotation_degrees", 
									_pivot_point.rotation_degrees, rod_start_angle, 
									0.2, Tween.TRANS_SINE,Tween.EASE_IN)
			_tween.start()
			
			_tween.interpolate_property(_anim_pivot, "rotation", 
									_anim_pivot.rotation, 0, 
									0.2, Tween.TRANS_SINE,Tween.EASE_IN)
			_tween.start()



func update_sprite() -> void:
	if _hook_instance:
		_pivot_point.look_at(_hook_instance.global_position)
	
	if _is_charging:
		_pivot_point.look_at(get_global_mouse_position())


func start_charge() -> void:
	_is_charging = true
	_charged_time = 0.0


func throw_grapple() -> void:
	if !_hook_instance:
		if is_continuous:
			_can_grapple = false
		
			var _mouse_dir = get_global_mouse_position() - _hook_point.global_position
			_mouse_dir = _mouse_dir.normalized()
			
			spawn_hook_continuous(_hook_point.global_position, _mouse_dir)
		
		else:
			_can_grapple = false
			
			var _mouse_dir = get_global_mouse_position() - _hook_point.global_position
			_mouse_dir = _mouse_dir.normalized()
			
			var force = _mouse_dir * min(_charged_time * hook_throw_force_base, max_hook_throw_force)
			
			print("Hook Throw Force: ", force.length())
			
			spawn_hook_physics(_hook_point.global_position, force)


func spawn_hook_physics(start_pos : Vector2, force: Vector2) -> void:
	_hook_instance = hook_physics.instance()
	_hook_instance.set_as_toplevel(true)
	
	_hook_instance.connect("has_hooked", self, "on_has_hooked")
	
	add_child(_hook_instance)
	_hook_instance.global_position = start_pos
	
	_hook_instance.apply_central_impulse(force)


func spawn_hook_continuous(start_pos : Vector2, dir: Vector2) -> void:
	_hook_instance = hook_continuous.instance()
	_hook_instance.set_as_toplevel(true)
	
	_hook_instance.connect("has_hooked", self, "on_has_hooked")
	
	add_child(_hook_instance)
	_hook_instance.shoot(start_pos, dir)


func release_grapple() -> void:
	if _hook_instance:
		_can_grapple = true
		
		_hook_instance.disconnect("has_hooked", self, "on_has_hooked")
		_hook_instance.release()
		_hook_instance = null
		
		parent.player_handles_movement = true


func line_dist_adjust() -> void:
	var parent_dir_hook = parent.global_position.direction_to(_hook_instance.global_position)
	var hook_point_dir_hook = _hook_point.global_position.direction_to(_hook_instance.global_position)
	
	if parent_dir_hook.dot(hook_point_dir_hook) < 0:
#		print("not facing same dir")
		return
	
	# restrict movement
	if _distance_to_hook > _line_length:
		parent.player_can_set_snap = false
		
		pullback_vel = _hook_dir * (hook_reel_speed / 2)
		parent.velocity = pullback_vel
	
	else:
		parent.player_can_set_snap = true
		pullback_vel = Vector2.ZERO
	
	# setting _can_reel
	if _distance_to_hook > _line_length + 10:
		_can_reel = false
		
	else:
		_can_reel = true


func apply_tension() -> void:
	# applying pendulum angle acceleration
	var angle_accel = -swing_force * cos(_hook_instance.global_position.direction_to(_hook_point.global_position).angle())
	
	angle_accel += _input_dir.x * push_force
	
	angular_velocity += angle_accel
	angular_velocity *= 0.99
	
#	print("ang velocity: ", angular_velocity)
	
	var p_hook_dir := Vector2(sign(angular_velocity) * -_hook_dir.y, sign(angular_velocity) * _hook_dir.x).normalized()
	var s_force = p_hook_dir * (abs(angular_velocity) * _line_length) + pullback_vel
	
#	print("s force: ", s_force)
	
	parent.velocity = s_force
	
	if parent.velocity.length() > max_swing_speed:
		parent.velocity = parent.velocity.normalized() * max_swing_speed
	
#	print("speed: ", parent.velocity.length())


# signal callbacks
func on_has_hooked() -> void:
	_line_length = max(min_line_length, _distance_to_hook + min_line_length)

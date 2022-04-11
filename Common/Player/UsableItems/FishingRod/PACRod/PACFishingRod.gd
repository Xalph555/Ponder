#--------------------------------------#
# PAC Fishing Rod Script               #
#--------------------------------------#
extends Node2D


# Variables:
#---------------------------------------
export(PackedScene) var hook

var _hook_instance : Hook

# hook properties 
export var line_length := 20.0
export var hook_reel_speed := 150

var _can_grapple := true

var _distance_to_hook := 0.0
var _hook_dir := Vector2.ZERO

# hook swing properties
export var swing_force := 0.25
export var push_force := 0.06

export var max_swing_speed := 500.0

var angular_velocity := 0.0

var _input_dir := Vector2.ZERO

onready var _pivot_point := $PivotPoint
onready var _hook_point := $PivotPoint/HookPoint
onready var _tween := $Tween

onready var parent = get_parent().get_parent() as Player


# Functions:
#---------------------------------------
func _physics_process(delta: float) -> void:
	update_input(delta)
	update_sprite()
	
	if _hook_instance:
		_distance_to_hook = _hook_instance.global_position.distance_to(_hook_point.global_position)
		_hook_dir = (_hook_instance.global_position - _hook_point.global_position).normalized()
		
		if _hook_instance.is_hooked:
			max_dist_adjust()
			
			if not parent.is_on_floor() and _distance_to_hook > line_length - 10:
				if parent.player_handles_movement:
					angular_velocity = sign(parent.velocity.x) * (parent.velocity.length() / line_length)
					parent.player_handles_movement = false
					
				apply_tension()
			
			else:
				if not parent.player_handles_movement:
					parent.player_handles_movement = true


func update_input(delta: float) -> void:
	# input 
	_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_input_dir = _input_dir.normalized()
	
	# charging rod
	if Input.is_action_just_pressed("Action1") and _can_grapple:
#		_tween.interpolate_property(_pivot_point, "rotation_degrees",
#										45, -45,
#										0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		_tween.start()
#
		# play throw animation
		
		throw_grapple()

	# throw rod
	if Input.is_action_just_released("Action1"):
		release_grapple()
	
	# reel hook
	if Input.is_action_just_released("ui_scroll_up"):
		line_length += hook_reel_speed * delta
	
	if Input.is_action_just_released("ui_scroll_down"):
		line_length = max(10, line_length - (hook_reel_speed * delta))


func update_sprite() -> void:
	if _hook_instance:
		_pivot_point.look_at(_hook_instance.global_position)


func throw_grapple() -> void:
	if !_hook_instance:
		_can_grapple = false
		
		var _mouse_dir = get_global_mouse_position() - _hook_point.global_position
#		print(rad2deg(hook_dir.angle()))
		_mouse_dir = _mouse_dir.normalized()
		
		#print(rad2deg(to_local(hook_dir).angle()))
		
		
		# need to restrict hook direction to flat with hook and 75 degrees down it
		
		
		_hook_instance = hook.instance()
		_hook_instance.set_as_toplevel(true)
		
		_hook_instance.connect("has_hooked", self, "on_has_hooked")
		
		add_child(_hook_instance)
		_hook_instance.shoot(parent, _hook_point.global_position, _mouse_dir)


func release_grapple() -> void:
	if _hook_instance:
		_can_grapple = true
		
		_hook_instance.disconnect("has_hooked", self, "on_has_hooked")
		_hook_instance.release()
		_hook_instance = null
		
		parent.player_handles_movement = true


func max_dist_adjust():
	if _distance_to_hook > line_length:
		var parent_origin_dist = self.global_position.distance_to(_hook_point.global_position)
		parent.global_position = _hook_instance.global_position + (-1 * _hook_dir * (line_length + parent_origin_dist))


func apply_tension() -> void:
	# applying pendulum angle acceleration
	var angle_accel = -swing_force * cos(_hook_instance.global_position.direction_to(_hook_point.global_position).angle())
	
	angle_accel += _input_dir.x * push_force
	
	angular_velocity += angle_accel
	angular_velocity *= 0.99
	
#	print("ang velocity: ", angular_velocity)
	
	var p_hook_dir := Vector2(sign(angular_velocity) * -_hook_dir.y, sign(angular_velocity) * _hook_dir.x).normalized()
	var s_force = p_hook_dir * (abs(angular_velocity) * line_length) 
	
#	print("s force: ", s_force)
	
	parent.velocity = s_force
	
	if parent.velocity.length() > max_swing_speed:
		parent.velocity = parent.velocity.normalized() * max_swing_speed
	
#	print("speed: ", parent.velocity.length())
	
	
	# adjust postion to max of line length
	if not parent.is_on_floor():
		if _distance_to_hook != line_length:
			var parent_offset = self.global_position.distance_to(_hook_point.global_position)
			var new_location = _hook_instance.global_position + (-1 * _hook_dir * (line_length + parent_offset))
			
			parent.global_position = lerp(parent.global_position, new_location, 0.5)
	
	
	
#	if _distance_to_hook > line_length:
#		var parent_origin_dist = self.global_position.distance_to(_hook_point.global_position)
#		parent.global_position = _hook_instance.global_position + (-1 * _hook_dir * (line_length + parent_origin_dist))
#
#	if _distance_to_hook < line_length - 10:
#		var line_down_force := -1 * _hook_dir * 0.2
#		parent.velocity += line_down_force
	
	
#	parent.is_flying = true
##	parent.velocity.y = lerp(parent.velocity.y, 0, 0.08)
#
#	# applying pendulum angle acceleration
#	var hook_ang = -cos(_hook_instance.global_position.direction_to(_hook_point.global_position).angle())
#	var angle_accel = abs(-swing_force * hook_ang)
#
#	var p_hook_dir := Vector2(sign(hook_ang) * -_hook_dir.y, sign(hook_ang) * _hook_dir.x).normalized()
#	var s_force = p_hook_dir * (angle_accel * line_length)
#
#	parent.limit_speed = parent.max_speed * 10
#	parent.velocity += s_force
#
##	var hook_ang = _hook_point.global_position.direction_to(_hook_instance.global_position).angle()
##	var ang_accel = -5 * cos(hook_ang)
##	ang_accel += _input_dir.x * 0.08
##
##	_hook_ang_vel += ang_accel
##	_hook_ang_vel *= 0.99
##
##	var p_hook_dir := Vector2(sign(_hook_ang_vel) * -_hook_dir.y, sign(ang_accel) * _hook_dir.x)
##	var s_force = p_hook_dir * abs(_hook_ang_vel)
##
##	parent.velocity += s_force
#

#	# swinging without pendulum physics
##	if _input_dir.x != 0:
##		var p_hook_dir := Vector2(sign(_input_dir.x) * -_hook_dir.y, sign(_input_dir.x) * _hook_dir.x)
##		var s_force := p_hook_dir * swing_force
##
##		parent.velocity += s_force


# signal callbacks
func on_has_hooked() -> void:
	line_length = _distance_to_hook


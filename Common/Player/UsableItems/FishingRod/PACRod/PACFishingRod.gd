#--------------------------------------#
# PAC Fishing Rod Script               #
#--------------------------------------#
extends Node2D


# Variables:
#---------------------------------------
export(PackedScene) var hook

var _hook_instance : PACHook

# hook properties 
export var min_line_length := 5.0
export var hook_reel_speed := 4.0

var _line_length := 0.0

var _can_grapple := true
var _can_reel := true

var _distance_to_hook := 0.0
var _hook_dir := Vector2.ZERO

var pullback_vel := Vector2.ZERO

# hook swing properties
export var swing_force := 0.25
export var push_force := 0.06

export var max_swing_speed := 500.0

var angular_velocity := 0.0

var _input_dir := Vector2.ZERO

# rod properties 
export var rod_start_angle := -45.0

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
	release_grapple()
	set_process_unhandled_input(is_active)
	self.visible = is_active


func _physics_process(delta: float) -> void:
	update()
	
	# update_input(delta)
	update_sprite()
	
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
	if _hook_instance:
		draw_line(to_local(_hook_point.global_position), to_local(_hook_instance.global_position), Color.white, 1.01, true)


func _unhandled_input(event: InputEvent) -> void:
	# input direction
	if event.is_action_pressed("move_right"):
		_input_dir.x += 1

	if event.is_action_released("move_right"):
		_input_dir.x -= 1
	
	if event.is_action_pressed("move_left"):
		_input_dir.x -= 1
	
	if event.is_action_released("move_left"):
		_input_dir.x += 1

	_input_dir = _input_dir.normalized()

	# charging rod
	if event.is_action_pressed("Action1") and _can_grapple:
		_anim_player.play("ThrowHook")
		
		var ang_to_mouse = _pivot_point.global_position.direction_to(get_global_mouse_position()).angle()
		_tween.interpolate_property(_pivot_point, "rotation", 
								_pivot_point.rotation, ang_to_mouse, 
								0.2, Tween.TRANS_SINE,Tween.EASE_IN)
		_tween.start()
	
	# throw rod
	if event.is_action_released("Action1"):
		release_grapple()
	
	# reel hook
	if event.is_action_released("ui_scroll_up"):
		_line_length += hook_reel_speed
	
	if event.is_action_released("ui_scroll_down") and _can_reel:
		_line_length = max(min_line_length, _line_length - (hook_reel_speed))


# func update_input(delta: float) -> void:
# 	# input 
# 	_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
# 	_input_dir = _input_dir.normalized()
	
# 	# charging rod
# 	if Input.is_action_just_pressed("Action1") and _can_grapple:
# 		_anim_player.play("ThrowHook")
		
# 		var ang_to_mouse = _pivot_point.global_position.direction_to(get_global_mouse_position()).angle()
# 		_tween.interpolate_property(_pivot_point, "rotation", 
# 								_pivot_point.rotation, ang_to_mouse, 
# 								0.2, Tween.TRANS_SINE,Tween.EASE_IN)
# 		_tween.start()
		
# #		print("Ang to Mouse: ", rad2deg(ang_to_mouse))
# #		print("Pivot Angle: ", _pivot_point.rotation_degrees)

# 	# throw rod
# 	if Input.is_action_just_released("Action1"):
# 		_anim_player.stop()
# 		release_grapple()
		
# 		_tween.interpolate_property(_pivot_point, "rotation_degrees", 
# 								_pivot_point.rotation_degrees, rod_start_angle, 
# 								0.3, Tween.TRANS_SINE,Tween.EASE_IN)
# 		_tween.start()
		
# 		_tween.interpolate_property(_anim_pivot, "rotation", 
# 								_anim_pivot.rotation, 0, 
# 								0.3, Tween.TRANS_SINE,Tween.EASE_IN)
# 		_tween.start()
	
# 	# reel hook
# 	if Input.is_action_just_released("ui_scroll_up"):
# 		_line_length += hook_reel_speed * delta
	
# 	if Input.is_action_just_released("ui_scroll_down") and _can_reel:
# 		_line_length = max(min_line_length, _line_length - (hook_reel_speed * delta))


func update_sprite() -> void:
	if _hook_instance:
		_pivot_point.look_at(_hook_instance.global_position)


func throw_grapple() -> void:
	if !_hook_instance:
		_can_grapple = false
		
		var _mouse_dir = get_global_mouse_position() - _hook_point.global_position
		_mouse_dir = _mouse_dir.normalized()
		
		spawn_hook(_hook_point.global_position, _mouse_dir)


func spawn_hook(start_pos : Vector2, dir: Vector2) -> void:
	_hook_instance = hook.instance()
	_hook_instance.set_as_toplevel(true)
	
	_hook_instance.connect("has_hooked", self, "on_has_hooked")
	
	add_child(_hook_instance)
	_hook_instance.shoot(start_pos, dir)


func release_grapple() -> void:
	_anim_player.stop()

	if _hook_instance:
		_can_grapple = true
		
		_hook_instance.disconnect("has_hooked", self, "on_has_hooked")
		_hook_instance.release()
		_hook_instance = null
		
		parent.player_handles_movement = true
	
	_tween.interpolate_property(_pivot_point, "rotation_degrees", 
								_pivot_point.rotation_degrees, rod_start_angle, 
								0.3, Tween.TRANS_SINE,Tween.EASE_IN)
	_tween.start()
	
	_tween.interpolate_property(_anim_pivot, "rotation", 
							_anim_pivot.rotation, 0, 
							0.3, Tween.TRANS_SINE,Tween.EASE_IN)
	_tween.start()


func line_dist_adjust() -> void:
	var parent_dir_hook = parent.global_position.direction_to(_hook_instance.global_position)
	var hook_point_dir_hook = _hook_point.global_position.direction_to(_hook_instance.global_position)
	
	if parent_dir_hook.dot(hook_point_dir_hook) < 0:
#		print("not facing same dir")
		return
	
	# restrict movement
	if _distance_to_hook > _line_length:
		parent.player_can_set_snap = false
		
		pullback_vel = _hook_dir * (hook_reel_speed * 10) # need multiplier to give enough force
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


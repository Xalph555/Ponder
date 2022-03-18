#--------------------------------------#
# PAC Fishing Rod Script               #
#--------------------------------------#
extends Node2D


# Variables:
#---------------------------------------
export(PackedScene) var hook

export var line_length := 20.0

# hook tension variables 
var _pull_x := 60
var _pull_y := 105
var _hook_pull := Vector2(_pull_x, _pull_y)

var tension_vec := Vector2.ZERO

var _hook_instance : Hook
var _can_grapple := true

var _distance_to_hook := 0.0
var _hook_dir := Vector2.ZERO

onready var _pivot_point := $PivotPoint
onready var _hook_point := $PivotPoint/HookPoint
onready var _tween := $Tween

onready var parent = get_parent().get_parent()


# Functions:
#---------------------------------------
func _physics_process(delta: float) -> void:
#	if parent.is_on_floor():
#		if _can_grapple:
#			parent.is_flying = false
	
	update_input(delta)
	update_sprite()
	
	if _hook_instance:
		_distance_to_hook = _hook_instance.global_position.distance_to(_hook_point.global_position)
		_hook_dir = (_hook_instance.global_position - _hook_point.global_position).normalized()
	
		if _hook_instance.is_hooked:
			apply_tension()


func update_input(delta: float) -> void:
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
		add_child(_hook_instance)
		_hook_instance.shoot(parent, _hook_point.global_position, _mouse_dir)


func release_grapple() -> void:
	if _hook_instance:
		_can_grapple = true
		
		_hook_instance.release()
		_hook_instance = null


func apply_tension():
	parent.is_flying = true
	
	# adjusting pull direction
	_hook_pull.x = sign(_hook_dir.x) * abs(_hook_pull.x)
	_hook_pull.y = sign(_hook_dir.y) * abs(_hook_pull.y)
	
	tension_vec = _hook_dir * _hook_dir.dot(_hook_pull)
	
	parent.limit_speed = parent.max_speed * 1.3
	parent.velocity += tension_vec
	
	# dead space
	var dead_space := 20.0
	if _distance_to_hook < dead_space:
		var parent_origin_dist = (parent.global_position - _hook_point.global_position).length()
		parent.global_position = _hook_instance.global_position + (_hook_dir * -1 * (dead_space + parent_origin_dist))


func update_sprite() -> void:
	if _hook_instance:
		_pivot_point.look_at(_hook_instance.global_position)

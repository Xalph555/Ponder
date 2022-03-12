#--------------------------------------#
# PAC Fishing Rod Script               #
#--------------------------------------#
extends Node2D


# Variables:
#---------------------------------------
export(PackedScene) var hook;

var _hook_instance

var _can_grapple := true

onready var _pivot_point := $PivotPoint
onready var _hook_point := $PivotPoint/HookPoint
onready var _tween := $Tween

onready var parent = get_parent().get_parent()


# Functions:
#---------------------------------------
func _physics_process(delta: float) -> void:
	if parent.is_on_floor():
		if _can_grapple:
			parent.is_flying = false
	
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
		
		var hook_dir : Vector2 = get_global_mouse_position() - _hook_point.global_position
		print(rad2deg(hook_dir.angle()))
		hook_dir = hook_dir.normalized()
		
		#print(rad2deg(to_local(hook_dir).angle()))
		
		
		# need to restrict hook direction to flat with hook and 75 degrees down it
		
		
		
		_hook_instance = hook.instance()
		_hook_instance.set_as_toplevel(true)
		add_child(_hook_instance)
		_hook_instance.shoot(parent, _hook_point, hook_dir)


func release_grapple() -> void:
	if _hook_instance:
		_can_grapple = true
		
		_hook_instance.release()
		_hook_instance = null

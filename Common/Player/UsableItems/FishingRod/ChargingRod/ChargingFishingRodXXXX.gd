#--------------------------------------#
# Charging Fishing Rod ScriptXXXXXXX   #
#--------------------------------------#
extends Node2D


# Variables:
#---------------------------------------
export var force_factor := 250

var _charge_time := 0.0

var _is_charaging := false

onready var _pivot_point := $PivotPoint
onready var _hook := $PivotPoint/HookPoint/PinJoint2D/Hook
#onready var _hook_joint := $PivotPoint/HookPoint/PinJoint2D

onready var _tween := $Tween


# Functions:
#---------------------------------------
func _ready() -> void:
	_hook.set_as_toplevel(true)


func _physics_process(delta: float) -> void:
	# charging rod
	if Input.is_action_pressed("Action1"):
		if not _is_charaging:
			_tween.interpolate_property(_pivot_point, "rotation_degrees",
										45, -45,
										0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			_tween.start()
		
		_is_charaging = true
		_charge_time += delta
	
	# throw rod
	if Input.is_action_just_released("Action1"):
		_is_charaging = false
		
		_tween.interpolate_property(_pivot_point, "rotation_degrees",
										-45, 45,
										0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_tween.start()
		
		#_hook_joint.softness = 16
		#_hook.position.x = 50
		
		var dir = (get_global_mouse_position() - _hook.global_position).normalized()
		var impulse = dir * _charge_time * force_factor
		
		_hook.apply_central_impulse(impulse)
		
		_charge_time = 0

#--------------------------------------#
# PAC Hook Script                      #
#--------------------------------------#
extends KinematicBody2D

class_name Hook


# Signals:
#---------------------------------------
signal has_hooked


# Variables:
#---------------------------------------
var _move_speed := 1000

var _move_dir := Vector2.ZERO
var _hook_dir := Vector2.ZERO
var _velocity := Vector2.ZERO

var is_hooked := false


# Functions:
#---------------------------------------
func _physics_process(delta: float) -> void:
	if not is_hooked:
		fly_hook(delta)


func fly_hook(delta: float):
	_velocity = _move_dir * _move_speed * delta
	
	var collided = move_and_collide(_velocity)
	
	if collided:
		is_hooked = true
		_move_dir = Vector2.ZERO
		
		emit_signal("has_hooked")
		
#		self.rotation = collided.normal.angle() + deg2rad(180)
#		display_chain()


func shoot(shooter: KinematicBody2D, pos : Vector2, dir: Vector2) -> void:
	global_position = pos
	_move_dir = dir
	
	is_hooked = false


func release() -> void:
	call_deferred("free")

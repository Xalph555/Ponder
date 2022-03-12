#--------------------------------------#
# PAC Hook Script                      #
#--------------------------------------#
extends KinematicBody2D


# Variables:
#---------------------------------------
var _move_speed := 1000

var _pull_x := 15
var _pull_y := 15
var _hook_pull := Vector2(_pull_x, _pull_y)

var _hook_origin : Position2D

var _move_dir := Vector2.ZERO
var _hook_dir := Vector2.ZERO
var _velocity := Vector2.ZERO

var _distance_to_origin := 0.0

var _is_hooked := false

var _parent: KinematicBody2D


# Functions:
#---------------------------------------
func _physics_process(delta: float) -> void:
	_distance_to_origin = self.global_position.distance_to(_hook_origin.global_position)
	_hook_dir = (self.global_position - _hook_origin.global_position).normalized()
	
#	display_chain()
	
	if _is_hooked:
		apply_tension()
	
	else:
		fly_hook(delta)


#func display_chain():
#	# chain graphics
#	_hook_chain.region_rect.size.x = _distance_to_parent
#	_hook_chain.rotation = self.position.angle_to_point(_parent.global_position) - self.rotation + deg2rad(180)


func apply_tension():
	_parent.is_flying = true
	
	# adjusting pull direction
	_hook_pull.x = sign(_hook_dir.x) * abs(_hook_pull.x)
	_hook_pull.y = sign(_hook_dir.y) * abs(_hook_pull.y)

	var tension_vec := _hook_dir * _hook_dir.dot(_hook_pull)
	
#	# dead space
	var dead_space := 15.0
	if _distance_to_origin < dead_space:
		tension_vec *= 0.005 #0.005 * (_pull_x + _pull_y)/2
	
	_parent.limit_speed = _parent.max_speed * 1.3
	_parent.velocity += tension_vec


func fly_hook(delta: float):
	_velocity = _move_dir * _move_speed * delta
	
	var collided = move_and_collide(_velocity)
	
	if collided:
		_is_hooked = true
		_move_dir = Vector2.ZERO
		
#		self.rotation = collided.normal.angle() + deg2rad(180)
#		display_chain()


func shoot(shooter: KinematicBody2D, pos : Position2D, dir: Vector2) -> void:
	_parent = shooter
	_hook_origin = pos
	global_position = _hook_origin.global_position
	
	_move_dir = dir
	
	_is_hooked = false


func release() -> void:
	call_deferred("free")

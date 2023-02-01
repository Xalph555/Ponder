# Rope Node
# ---------------------------------
extends KinematicBody2D


# Variables:
#---------------------------------------
export(float) var node_size := 1.0
export(float) var segment_length := 5.0

export(float) var max_tension := 1.0
export(float) var min_tension := 0.5

export(float) var gravity := 30.0

var pullback_force := 50.0

var attached_node

var dist_to_node := 0.0

var pull_velocity := Vector2.ZERO

onready var col_shape := $CollisionShape2D

# export(NodePath) onready var manual_set_node = get_node(manual_set_node)

# ! need to add min segment size - when reeling subtract current length - when less, remove and send signal?
# could also just check all of this in the fishing rod?

# Functions:
#--------------------------------------
# func _ready() -> void:
# 	init(manual_set_node)


func init(node_to_attach_to) -> void:
	col_shape.shape.radius = node_size
	attached_node = node_to_attach_to


func _process(delta: float) -> void:
	update()


func _draw() -> void:
	draw_line(to_local(global_position), to_local(attached_node.global_position), Color.white, 1.01, true)


func _physics_process(delta: float) -> void:
	if not attached_node:
		return

	dist_to_node = global_position.distance_to(attached_node.global_position)

	# print("Rope Node Dist To Node: ", dist_to_node)

	pull_velocity.y += gravity

	apply_limit_force(delta)

	var lerp_weight = 0.4

	pull_velocity.x = lerp(pull_velocity.x, 0, lerp_weight)
	pull_velocity.y = lerp(pull_velocity.y, 0, lerp_weight)

	# pull_velocity *= 0.6

	# pull_velocity.x = clamp(pull_velocity.x, -400.0, 400.0)

	pull_velocity = move_and_slide(pull_velocity)


func apply_limit_force(delta : float) -> void:
	# if dist_to_node <= get_length_with_tension():
	# 	pull_velocity = lerp(pull_velocity, Vector2.ZERO, 0.1)
	
	# else:
	var pull_dir := global_position.direction_to(attached_node.global_position) as Vector2

	var force_multiplier := dist_to_node - get_length_with_tension()
	pull_velocity += pullback_force * force_multiplier * pull_dir


func get_length_with_tension() -> float:
	return segment_length * max_tension

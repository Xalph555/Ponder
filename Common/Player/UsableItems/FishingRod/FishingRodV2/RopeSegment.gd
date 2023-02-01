# Rope Segment
# ---------------------------------
extends KinematicBody2D


# Variables:
#---------------------------------------
export(float) var segment_length := 10.0

var max_tension := 1.1
export(float) var min_tension := 0.5

var gravity := 1

var angular_velocity := 0.0
var velocity := Vector2.ZERO

onready var attach_point := $Position2D
onready var col_shape := $CollisionShape2D
onready var sprite := $Sprite


# Functions:
#--------------------------------------
func _ready() -> void:
	init(segment_length)


func init(length : float) -> void:
	segment_length = length

	col_shape.shape.extents.x = length / 2.0
	col_shape.position.x = length / 2.0

	attach_point.position.x = length


func _process(delta: float) -> void:
	update()


func _physics_process(delta: float) -> void:
	apply_rotation(delta)

	# velocity.y += gravity
	velocity = move_and_slide(velocity)


func _draw() -> void:
	draw_line(to_local(global_position), to_local(attach_point.global_position), Color.white, 1.01, true)


func add_velocity(vel_to_add : Vector2) -> void:
	velocity += vel_to_add
	


func apply_rotation(delta : float) -> void:
	rotate(5 * delta)

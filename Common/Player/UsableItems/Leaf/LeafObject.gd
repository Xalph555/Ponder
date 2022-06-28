#--------------------------------------#
# Leaf Object Script                   #
#--------------------------------------#

extends StaticBody2D

class_name LeafObject


# Variables:
#---------------------------------------
export var acceleration:= 50
export var max_speed := 400

onready var limit_speed := max_speed

export var on_floor_friction := 0.25
export var in_air_friction := 0.2

var velocity := Vector2.ZERO
var _input_dir := Vector2.ZERO

var parent : Player


# Functions:
#---------------------------------------
func set_up_leaf(leaf_parent : Node, parent_velocity : Vector2, global_pos : Vector2) -> void:
	parent = leaf_parent
	velocity = parent_velocity
	global_position = global_pos


func _physics_process(delta: float) -> void:
	pass
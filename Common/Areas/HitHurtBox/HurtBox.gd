#--------------------------------------#
# Hurtbox Script                       #
#--------------------------------------#
extends Area2D

class_name Hurtbox


# Variables:
#---------------------------------------
onready var _collision_shape := $CollisionShape2D


# Functions:
#---------------------------------------
func disable_hurt_box() -> void:
	_collision_shape.disabled = true


func enable_hurt_box() -> void:
	_collision_shape.disabled = false

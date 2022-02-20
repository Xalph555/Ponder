#--------------------------------------#
# Hitbox Script                        #
#--------------------------------------#
extends Area2D

class_name Hitbox


# Variables:
#---------------------------------------
export(float) var damage = 0
export(float) var knock_back_force = 0

onready var _collision_shape := $CollisionShape2D


# Functions:
#---------------------------------------
func disable_hit_box() -> void:
	_collision_shape.disabled = true


func enable_hit_box() -> void:
	_collision_shape.disabled = false

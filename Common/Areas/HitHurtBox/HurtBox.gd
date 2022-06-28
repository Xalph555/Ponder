#--------------------------------------#
# Hurtbox Script                       #
#--------------------------------------#
extends Area2D

class_name Hurtbox


# Variables:
#---------------------------------------
var parent


# Functions:
#---------------------------------------
func disable_hurt_box() -> void:
	#_collision_shape.disabled = true
	monitorable = false


func enable_hurt_box() -> void:
	#_collision_shape.disabled = false
	monitorable = true

#--------------------------------------#
# Hitbox Script                        #
#--------------------------------------#
extends Area2D

class_name Hitbox


# Variables:
#---------------------------------------
var parent


# Functions:
#---------------------------------------
func disable_hit_box() -> void:
	#_collision_shape.disabled = true
	monitoring = false


func enable_hit_box() -> void:
	#_collision_shape.disabled = false
	monitoring = true

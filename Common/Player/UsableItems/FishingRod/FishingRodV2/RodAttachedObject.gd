# RodAttachedObject
# ---------------------------------
extends Node
class_name RodAttachedObject

# Class is used with fishing rod states
# Provides a container for relevant variables 

# Variables:
#---------------------------------------
var attached_entity

var is_grappled := false

var angular_velocity := 0.0
var previous_anglular_velocity := 0.0
var angular_vel_rate_of_change := 0.0

var pullback_force := 45.0 # this value should not change
var pullback_velocity := Vector2.ZERO

var current_dist_last_point := 0.0


# Functions:
#--------------------------------------
func _init(entity) -> void:
    attached_entity = entity
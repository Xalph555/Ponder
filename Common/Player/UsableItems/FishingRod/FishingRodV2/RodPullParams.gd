# RodGrappleParams Dataclass
# ---------------------------------
extends Node
class_name RodPullParams


# Variables:
#---------------------------------------
var pullback_vel := Vector2.ZERO

var anchor_point := Vector2.ZERO
var move_point := Vector2.ZERO

var pullback_force := 0.0

var max_line_tension := 0.0
var current_dist := 0.0

var rotation_ang := INF

var current_vel := 0.0


# Functions:
#--------------------------------------
func _init(current_pullback := Vector2.ZERO, anchor_p := Vector2.ZERO, move_p := Vector2.ZERO, force := 0.0, line_ten := 0.0, curr_dist := 0.0, rot_ang := INF) -> void:
    pullback_vel = current_pullback

    anchor_point = anchor_p
    move_point = move_p

    pullback_force = force

    max_line_tension = line_ten
    current_dist = curr_dist

    rotation_ang = rot_ang
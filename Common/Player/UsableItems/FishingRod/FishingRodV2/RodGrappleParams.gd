# RodGrappleParams Dataclass
# ---------------------------------
extends Node
class_name RodGrappleParams


# Variables:
#---------------------------------------
var angular_vel := 0.0
var previous_angular_vel := 0.0
var angular_vel_roc := 0.0

var point_from := Vector2.ZERO
var point_to := Vector2.ZERO

var swing_weight := 0.0

var max_line_tension := 0.0
var current_dist := 0.0

var push_dir := Vector2.ZERO


# Functions:
#--------------------------------------
func _init(ang_vel := 0.0, prev_ang_vel := 0.0, ang_vel_roc := 0.0, p_from := Vector2.ZERO, p_to := Vector2.ZERO, swing := 0.0, push := Vector2.ZERO, line_ten := 0.0, curr_dist := 0.0) -> void:
    angular_vel = ang_vel
    previous_angular_vel = prev_ang_vel
    angular_vel_roc = ang_vel_roc

    point_from = p_from
    point_to = p_to

    swing_weight = swing

    push_dir = push

    max_line_tension = line_ten
    current_dist = curr_dist
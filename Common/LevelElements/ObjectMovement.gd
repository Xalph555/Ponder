# Object Movement
# ----------------------------------------
extends Node
class_name ObjectMovement


# Variables:
#---------------------------------------
# gravity
export(float) var gravity := 180.0

# Horizontal movement
export(float) var terminal_speed := 4500.0
export var acceleration:= 50.0

export(float) var max_speed := 400.0
onready var limit_speed := max_speed

export(float) var limit_max_transition := 0.2

export(float) var on_floor_friction := 0.1 #0.25
export(float) var in_air_friction := 0.2

# Move and Slide variables
var _up_dir := Vector2.UP

export(int) var _max_slides := 4
export(float) var _max_slope_angle := 46.0

var _do_stop_on_slope := true
var _has_infinite_inertia := false

var velocity := Vector2.ZERO

var has_friction := true

# TODO: Wind affecting objects?

# other
var object: KinematicBody2D


# Functions:
#---------------------------------------
func init(new_object : KinematicBody2D) -> void:
    _max_slope_angle = deg2rad(_max_slope_angle)
    object = new_object


func move_object(delta : float) -> void:
    velocity.y += gravity * delta

    if has_friction:
        velocity.x = lerp(velocity.x, 0, on_floor_friction)

    # velocity.x = clamp(velocity.x, -10, 10)
    # velocity.y = clamp(velocity.y, -10, 10)
    
    object_move_and_slide()

    # print("Object movement: ", velocity)


func object_move_and_slide() -> void:
    velocity = object.move_and_slide(velocity, _up_dir, _do_stop_on_slope, _max_slides, _max_slope_angle, _has_infinite_inertia)


# velocity funcs
func set_velocity(new_velocity: Vector2) -> void:
    velocity = new_velocity


func add_velocity(vel_to_add: Vector2) -> void:
    velocity += vel_to_add
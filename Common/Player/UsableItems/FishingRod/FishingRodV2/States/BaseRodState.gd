# BaseRodState
# ---------------------------------
extends Node
class_name BaseRodState


# Signals:
#---------------------------------------
# Following 2 signals are intended to notify when the state has been 
#   fully entered/ exited
# These need to be implemented within each subclass
signal state_entered
signal state_exited


# Variables:
#---------------------------------------
var rod_ref


# Functions:
#--------------------------------------
func set_up_state(rod) -> void:
    rod_ref = rod


func enter() -> void:
    pass


func exit() -> void:
    pass


func update_unwrapping() -> void:
    pass


func update_wrapping() -> void:
    pass


func get_max_line_length() -> float:
    return 0.0


func get_min_line_length() -> float:
    return 0.0


func get_line_length_max_tension() -> float:
    return 0.0


func get_line_length_min_tension() -> float:
    return 0.0


func transition_to_grapple() -> void:
	pass


func can_grapple() -> bool:
    return false


func check_grapple_state_change() -> void:
    pass


func grapple_entity() -> void:
    pass


func pull_entity() -> void:
    pass


func can_reel() -> bool:
    return false


func start_reeling(delta : float) -> void:
    pass


func stop_reeling() -> void:
    pass
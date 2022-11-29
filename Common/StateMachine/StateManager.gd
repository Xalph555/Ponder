# State Manager
# -------------------------------
extends Node
class_name BaseStateManager


# Signals:
#---------------------------------------
signal state_changed(new_state)


# Variables:
#---------------------------------------

# need to populate states dictionary with references to all states for manager
var states = {}

var current_state: int
var previous_state: int


# Functions:
#---------------------------------------

func change_state(new_state: int, arg := {}) -> void:
	if current_state:
		states[current_state].exit()

	previous_state = current_state
	current_state = new_state

	states[current_state].enter(arg)

	print("New State: ", states[current_state].get_state_name())


# need initialisation function to properly intialise state machine

func input(event: InputEvent) -> void:
	states[current_state].input(event)


func process(delta: float) -> void:
	states[current_state].process(delta)


func physics_process(delta: float) -> void:
	states[current_state].physics_process(delta)


func _on_state_entered() -> void:
	emit_signal("state_changed", current_state)


func _on_state_exited() -> void:
	pass
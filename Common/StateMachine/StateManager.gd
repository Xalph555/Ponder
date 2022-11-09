# State Manager
# -------------------------------
extends Node
class_name BaseStateManager


# Variables:
#---------------------------------------

# need to populate states dictionary with all states for class
var states = {}

var current_state: BaseState


# Functions:
#---------------------------------------

func change_state (new_state: int) -> void:
	if current_state:
		current_state.exit()

	current_state = states[new_state]
	current_state.enter()

	print("New State: ", new_state)


# need initialisation function to properly intialise state machine

func input(event: InputEvent) -> void:
	var new_state = current_state.input(event)

	if new_state != 0:
		change_state(new_state)


func process(delta: float) -> void:
	var new_state = current_state.process(delta)

	if new_state != 0:
		change_state(new_state)


func physics_process(delta: float) -> void:
	var new_state = current_state.physics_process(delta)

	if new_state != 0:
		change_state(new_state)

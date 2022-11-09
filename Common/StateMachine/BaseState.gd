# Base State
# ------------------------------
extends Node
class_name BaseState


# Variables:
#---------------------------------------

# requires an enum containg all states related to class for state machine
# 	this will also be used as the return value for the functions below that return int

# will also need to have a reference to the class/ object that is supposed to have the state 


# Functions:
#---------------------------------------

func enter() -> void:
	pass


func exit() -> void:
	pass


func input(event: InputEvent) -> int:
	return 0


func process(delta: float) -> int:
	return 0


func physics_process(delta: float) -> int:
	return 0

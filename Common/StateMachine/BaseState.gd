# Base State
# ------------------------------
extends Node
class_name BaseState


# Signals:
#---------------------------------------
signal state_entered
signal state_exited


# Variables:
#---------------------------------------

# requires an enum containg all states related to class for state machine
# 	this will also be used as the return value for the functions below that return int

# will also need to have a reference to the class/ object that is supposed to have the state 

var state_manager : BaseStateManager


# Functions:
#---------------------------------------
func enter(arg := {}) -> void:
	pass


func exit() -> void:
	pass


func input(event: InputEvent) -> void:
	pass


func process(delta: float) -> void:
	pass


func physics_process(delta: float) -> void:
	pass


func get_state_name() -> String:
	return "Base State"
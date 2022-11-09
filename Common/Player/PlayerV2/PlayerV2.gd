# Player V2
# ---------------------------------
extends KinematicBody2D
class_name PlayerV2


# Variables:
#---------------------------------------
var gravity := 4.0
var velocity := Vector2.ZERO

onready var state_manager = $PlayerStateMachine


# Functions:
#---------------------------------------

func _ready() -> void:
	state_manager.init(self)


func _unhandled_input(event: InputEvent) -> void:
	state_manager.input(event)


func _process(delta: float) -> void:
	state_manager.process(delta)


func _physics_process(delta: float) -> void:
	state_manager.physics_process(delta)

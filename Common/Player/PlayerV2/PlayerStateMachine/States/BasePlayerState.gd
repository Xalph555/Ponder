
extends BaseState
class_name PlayerBaseState


# Variables:
#---------------------------------------
enum State {
	NULL,
	IDLE,
	WALK,
	FALL,
	JUMP,
	ITEM_OVERRIDE
}

var player : Player


# Functions:
#---------------------------------------

func get_state_name() -> String:
	return "Player Base State"

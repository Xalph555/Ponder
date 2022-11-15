# Player Base State
# ------------------------------
extends BaseState
class_name PlayerBaseState


# Variables:
#---------------------------------------
enum State {
	NULL,
	IDLE,
	WALK,
	FALL,
	JUMP
}

var player: PlayerV2


# Functions:
#---------------------------------------

func get_state_name() -> String:
	return "Player Base State"
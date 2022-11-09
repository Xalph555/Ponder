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
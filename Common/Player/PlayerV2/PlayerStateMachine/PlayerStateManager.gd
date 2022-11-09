# Player State Manager
# -------------------------------
extends BaseStateManager


# Variables:
#---------------------------------------



# Functions:
#---------------------------------------
func init(player: PlayerV2) -> void:
	states[PlayerBaseState.State.IDLE] = $Idle
	states[PlayerBaseState.State.WALK] = $Walk
	states[PlayerBaseState.State.FALL] = $Fall
	states[PlayerBaseState.State.JUMP] = $Jump

	for child in get_children():
		child.player = player
	
	change_state(PlayerBaseState.State.IDLE)


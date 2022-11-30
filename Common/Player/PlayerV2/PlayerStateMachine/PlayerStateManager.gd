# Player State Manager
# -------------------------------
extends BaseStateManager


# Functions:
#---------------------------------------
func init(new_player: Player) -> void:
	states[PlayerBaseState.State.IDLE] = $Idle
	states[PlayerBaseState.State.WALK] = $Walk
	states[PlayerBaseState.State.FALL] = $Fall
	states[PlayerBaseState.State.JUMP] = $Jump
	states[PlayerBaseState.State.ITEM_OVERRIDE] = $ItemOverride

	for child in get_children():
		child.player = new_player
		child.state_manager = self

		child.connect("state_entered", self, "_on_state_entered")
		child.connect("state_exited", self, "_on_state_exited")
	
	change_state(PlayerBaseState.State.IDLE)


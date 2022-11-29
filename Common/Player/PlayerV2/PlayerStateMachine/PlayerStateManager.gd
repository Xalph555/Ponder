# Player State Manager
# -------------------------------
extends BaseStateManager


# Variables:
#---------------------------------------
var player : Player


# Functions:
#---------------------------------------
func init(new_player: Player) -> void:
	states[PlayerBaseState.State.IDLE] = $Idle
	states[PlayerBaseState.State.WALK] = $Walk
	states[PlayerBaseState.State.FALL] = $Fall
	states[PlayerBaseState.State.JUMP] = $Jump
	states[PlayerBaseState.State.ITEM_OVERRIDE] = $ItemOverride

	player = new_player

	for child in get_children():
		child.player = new_player
		child.state_manager = self

		child.connect("state_entered", self, "_on_state_entered")
		child.connect("state_exited", self, "_on_state_exited")
	
	change_state(PlayerBaseState.State.IDLE)


func set_item_override(is_overriding_player: bool, override_args := {}, fall_args := {}, walk_args := {}, idle_args := {}) -> void:
	if is_overriding_player:
		change_state(PlayerBaseState.State.ITEM_OVERRIDE, override_args)
		player.player_movement.set_snap(false)

	else:
		if not player.is_on_floor():
			change_state(PlayerBaseState.State.FALL, fall_args)
			return
		
		if player.is_on_floor():
			player.player_movement.set_snap(true)

			if player.player_movement.velocity.length_squared() > 0.0:
				change_state(PlayerBaseState.State.WALK, walk_args)

			else:
				change_state(PlayerBaseState.State.IDLE, idle_args)

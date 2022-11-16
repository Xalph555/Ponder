# Player Idle State
# --------------------------------
extends PlayerBaseState


# Functions:
#---------------------------------------

func enter(arg := {}) -> void:
	.enter()
	player.player_movement.velocity.x = 0


func input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		state_manager.change_state(PlayerBaseState.State.WALK)

	elif event.is_action_pressed("jump"):
		state_manager.change_state(PlayerBaseState.State.JUMP)


func physics_process(delta: float) -> void:
	player.player_movement.move_player(delta)

	if !player.is_on_floor() and player.player_movement.velocity.y > 0:
		state_manager.change_state(PlayerBaseState.State.FALL)


func get_state_name() -> String:
	return "Player Idle"
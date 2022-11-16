# Player Idle State
# --------------------------------
extends PlayerBaseState


# Variables:
#---------------------------------------
export(float) var jump_force = 200.0
export(float) var move_speed = 60.0

# var input_dir := Vector2.ZERO


# Functions:
#---------------------------------------
func enter(arg := {}) -> void:
	.enter()
	player.player_movement.set_snap(false)
	player.player_movement.jump_player()


func physics_process(delta: float) -> void:
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1

	player.player_movement.move_player(delta, input_dir)

	player.update_sprite(input_dir)

	if player.player_movement.velocity.y > 0:
		state_manager.change_state(PlayerBaseState.State.FALL, {no_jump = true})
	
	if player.is_on_floor():
		if is_zero_approx(input_dir.x):
			state_manager.change_state(PlayerBaseState.State.IDLE)
		
		else:
			state_manager.change_state(PlayerBaseState.State.WALK)


func get_state_name() -> String:
	return "Player Jump"

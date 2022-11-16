# Player Move State
# ----------------------------
extends PlayerBaseState
class_name PlayerMoveState


# Variables:
#---------------------------------------
export(float) var move_speed = 60.0


# Functions:
#---------------------------------------
func input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		state_manager.change_state(PlayerBaseState.State.JUMP)


func physics_process(delta: float) -> void:
	if !player.is_on_floor():# and player.player_movement.velocity.y > 0:
		state_manager.change_state(PlayerBaseState.State.FALL)
	
	var input_dir = get_movement_input()
	
	player.player_movement.move_player(delta, input_dir)

	if is_zero_approx(input_dir.x): 
		state_manager.change_state(PlayerBaseState.State.IDLE)


func get_movement_input() -> Vector2:
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1

	return input_dir


func get_state_name() -> String:
	return "Player Move !!!this shouldn't be a state on its own!!!"
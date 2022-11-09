# Player Idle State
# --------------------------------
extends PlayerBaseState


# Variables:
#---------------------------------------
export(float) var move_speed = 60.0

var input_dir := Vector2.ZERO


# Functions:
#---------------------------------------
func input(event: InputEvent) -> int:
	if event.is_action_pressed("jump"):
		return PlayerBaseState.State.JUMP
	
	# # movement 
	# if event.is_action_pressed("move_right"):
	# 	input_dir.x += 1

	# if event.is_action_released("move_right"):
	# 	input_dir.x -= 1
	
	# if event.is_action_pressed("move_left"):
	# 	input_dir.x -= 1
	
	# if event.is_action_released("move_left"):
	# 	input_dir.x += 1

	# input_dir = input_dir.normalized()
	
	return PlayerBaseState.State.NULL


func physics_process(delta: float) -> int:
	if !player.is_on_floor():
		return PlayerBaseState.State.FALL
	
	input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1

	player.velocity.y += player.gravity
	player.velocity.x = input_dir.x * move_speed
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	if is_zero_approx(input_dir.x): 
		return PlayerBaseState.State.IDLE

	return PlayerBaseState.State.NULL
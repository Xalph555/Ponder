# Player Idle State
# --------------------------------
extends PlayerBaseState


# Variables:
#---------------------------------------
export(float) var jump_force = 100.0
export(float) var move_speed = 60.0

var input_dir := Vector2.ZERO


# Functions:
#---------------------------------------
func enter() -> void:
	.enter()
	player.velocity.y = -jump_force


""" func input(event: InputEvent) -> int:
	if event.is_action_pressed("move_right"):
		input_dir.x += 1

	if event.is_action_released("move_right"):
		input_dir.x -= 1
	
	if event.is_action_pressed("move_left"):
		input_dir.x -= 1
	
	if event.is_action_released("move_left"):
		input_dir.x += 1

	input_dir = input_dir.normalized()
	
	return PlayerBaseState.State.NULL """


func physics_process(delta: float) -> int:
	input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1
		
	player.velocity.y += player.gravity
	player.velocity.x = input_dir.x * move_speed
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	if player.velocity.y > 0:
		return PlayerBaseState.State.FALL
	
	if player.is_on_floor():
		if is_zero_approx(input_dir.x):
			return PlayerBaseState.State.IDLE
		
		else:
			return PlayerBaseState.State.WALK
	
	return PlayerBaseState.State.NULL
# Player Idle State
# --------------------------------
extends PlayerBaseState


# Functions:
#---------------------------------------

func enter() -> void:
	.enter()
	player.velocity.x = 0


func input(event: InputEvent) -> int:
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		return PlayerBaseState.State.WALK

	elif event.is_action_pressed("jump"):
		return PlayerBaseState.State.JUMP
	
	return PlayerBaseState.State.NULL


func physics_process(delta: float) -> int:
	player.velocity.y += player.gravity
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	if !player.is_on_floor():
		return PlayerBaseState.State.FALL

	return PlayerBaseState.State.NULL


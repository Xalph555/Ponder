# Player Idle State
# --------------------------------
extends PlayerBaseState


# Variables:
#---------------------------------------
export(float) var move_speed = 60.0

export(float) var jump_buffer = 0.1
var _jump_buffer_timer := 0.0

export(float) var coyote_delay = 0.1
var _coyote_timer := 0.0


# Functions:
#---------------------------------------
func enter(arg := {}) -> void:
	.enter()

	if !arg.has("no_jump"):
		_jump_buffer_timer = 0
		_coyote_timer = coyote_delay

		print("Falling and can jump")


func input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and _coyote_timer > 0:
		state_manager.change_state(PlayerBaseState.State.JUMP)

	if event.is_action_pressed("jump") and _jump_buffer_timer <= 0:
		_jump_buffer_timer = jump_buffer


func process(delta: float) -> void:
	_jump_buffer_timer -= delta
	_coyote_timer -= delta


func physics_process(delta: float) -> void:
	var input_dir = get_movement_input()

	# player.velocity.y += player.gravity
	# player.velocity.x = input_dir.x * move_speed
	# player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

	player.player_movement.move_player(delta, input_dir)

	if player.is_on_floor():
		if _jump_buffer_timer > 0:
			state_manager.change_state(PlayerBaseState.State.JUMP)

		if is_zero_approx(input_dir.x):
			# player.player_movement.set_snap(true)
			state_manager.change_state(PlayerBaseState.State.IDLE)
		
		else:
			# player.player_movement.set_snap(true)
			state_manager.change_state(PlayerBaseState.State.WALK)


func get_movement_input() -> Vector2:
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1

	return input_dir


func get_state_name() -> String:
	return "Player Fall"
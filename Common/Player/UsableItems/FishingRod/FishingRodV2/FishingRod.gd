# Fishing Rod V2
# ---------------------------------
extends BaseItem
class_name FishingRod


# Signals:
#---------------------------------------
signal rod_hooked
signal rod_hook_released


# Variables:
#---------------------------------------
export(PackedScene) var hook_scene
var _hook_instance : FishingHook

export(float) var hook_throwing_force := 800.0

var is_hooked := false
var is_grappling := false

# line length
var max_line_length : float
export(float) var line_length_slack = 5.0
export(float) var min_line_length = 5.0

export(float) var max_tension := 1.1
export(float) var min_tension := 0.5

var hook_end_hook_dist : float

# rod rotation
export(float) var rotation_acceleration := 50.0
export(float) var rotation_limit_check := 10.0

var can_rotate_grapple := false
var previous_anglular_velocity := 0.0

export(float) var rotation_speed_transition := 1.0
var current_rotation_transition := 0.0

# reeling
var is_reeling := false
export(float) var reel_acceleration := 250.0

export(float) var time_to_max_reel := 2.5
var current_reel_time := 0.0

export(float) var reel_tolorence := 3.0

# pullling
var pullback_force := 50.0 
var pullback_velocity := Vector2.ZERO

# grappling
export(float) var pendulumn_fall := 0.25
export(float) var push_force := 0.065
export(float) var swing_speed := 100.0
export(float) var max_swing_speed := 500.0
var angular_velocity := 0.0
var angular_vel_rate_of_change := 0.0
export(float) var grapple_adjustment_force := 60.0

# scene references
onready var pivot_point := $PivotPoint
onready var hook_end := $PivotPoint/AnimationPivot/HookPoint
onready var jump_height_ray := $JumpHeightRay
onready var rod_sprite := $PivotPoint/AnimationPivot/Sprite
onready var hitbox := $PivotPoint/RodHitBox


# Functions:
#--------------------------------------
func init(new_player: Player) -> void:
	.init(new_player)
	set_active_item(false)

	jump_height_ray.cast_to.y = player.player_movement.jump_height + 7.0

	player.state_manager.connect("state_changed", self, "_on_state_changed")


func set_active_item(is_active : bool) -> void:
	.set_active_item(is_active)

	set_process_unhandled_input(is_active)
	set_process(is_active)

	break_hook()
	self.visible = is_active


func destroy_rod() -> void:
	player.state_manager.disconnect("state_changed", self, "_on_state_changed")
	call_deferred("free")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Action1") and hitbox.get_overlapping_bodies().size() == 0:
		throw_hook()

	if event.is_action_released("Action1"):
		break_hook()

	if event.is_action_pressed("Action2"):
		is_reeling = true
		current_reel_time = 0.0
		player.player_movement.set_snap(false)

	if event.is_action_released("Action2"):
		is_reeling = false

		if player.state_manager.current_state != PlayerBaseState.State.FALL:
			player.player_movement.set_snap(true)


func _process(delta: float) -> void:
	update()
	update_rod_sprite()
	update_fishing_rod_rotation(delta)

	# print("Mouse Position: ", get_global_mouse_position())


func _physics_process(delta: float) -> void:
	if not is_hooked:
		return
	
	hook_end_hook_dist = hook_end.global_position.distance_to(_hook_instance.global_position)

	_hook_instance.col_shape.shape.radius = get_line_with_tension()

	if is_reeling:
		reel_line(delta)

	if is_grappling:
		grappling(delta)

	else:
		pulling(delta)

	if not is_grappling and not player.is_on_floor() and hook_end_hook_dist >= get_line_with_tension():
		player.state_manager.change_state(PlayerBaseState.State.ITEM_OVERRIDE)


func _draw() -> void:
	if _hook_instance:
		if is_hooked:
			var color_min := Color.white
			var color_max := Color.red
			var color_weight := clamp(inverse_lerp(max_line_length * 0.9, get_line_with_tension(), hook_end_hook_dist), 0, 1)

			var line_color = color_min.linear_interpolate(color_max, color_weight)

			draw_line(to_local(hook_end.global_position), to_local(_hook_instance.global_position), line_color, 1.01, true)
		
		else:
			draw_line(to_local(hook_end.global_position), to_local(_hook_instance.global_position), Color.white, 1.01, true)


func update_fishing_rod_rotation(delta: float) -> void:
	if is_hooked:
		# pulling rotation
		if not is_grappling:
			var dir_to_mouse := (get_global_mouse_position() - self.global_position).normalized() as Vector2
			var angle_to_mouse := Vector2.RIGHT.rotated(pivot_point.rotation).angle_to(dir_to_mouse)
			var angle_weight := abs(angle_to_mouse / PI)

			var rotation_amount := sign(angle_to_mouse) * rotation_acceleration * angle_weight

			var dir_to_hook := (_hook_instance.global_position - self.global_position).normalized() as Vector2
			var angle_to_hook := dir_to_mouse.angle_to(dir_to_hook)

			# applying tension from pulling back rod
			if hook_end_hook_dist > max_line_length * min_tension:
				if sign(angle_to_mouse) != sign(angle_to_hook):
					var tension := (1 - clamp(inverse_lerp(max_line_length * min_tension, get_line_with_tension(), hook_end_hook_dist), 0.6, 1))
					rotation_amount *= tension

				else:
					if abs(rotation_amount) > rotation_limit_check:
						rotation_amount = 0.0

			pivot_point.rotate(rotation_amount * delta)
		
		# grappling rotation
		else:
			if can_rotate_grapple:
				var dir_to_hook := hook_end.global_position.direction_to(_hook_instance.global_position) as Vector2
				var current_dir := Vector2.RIGHT.rotated(pivot_point.rotation)

				if current_dir.dot(dir_to_hook) < 0.99:
					current_rotation_transition = clamp(current_rotation_transition + delta, 0.0, rotation_speed_transition)
					var rotation_weight := lerp(0.002, 0.1, current_rotation_transition / rotation_speed_transition) as float
					pivot_point.rotation = lerp_angle(pivot_point.rotation, dir_to_hook.angle(), rotation_weight) 

					# print("Rotation Weight: ", current_rotation_transition / rotation_speed_transition)
				
				else:
					pivot_point.look_at(_hook_instance.global_position)

			else:
				if abs(angular_vel_rate_of_change) < 0.1:
					can_rotate_grapple = true

	else:
		pivot_point.look_at(get_global_mouse_position())


func update_rod_sprite() -> void:
	if get_movement_input().x > 0:
		rod_sprite.scale.x = 1
	elif get_movement_input().x < 0:
		rod_sprite.scale.x = -1


func throw_hook() -> void:
	if is_instance_valid(_hook_instance) || is_hooked:
		return

	var throw_dir := (get_global_mouse_position() - hook_end.global_position).normalized() as Vector2

	var _hook = hook_scene.instance() as FishingHook
	_hook_instance = _hook
	
	_hook_instance.connect("hook_hooked", self, "_on_hook_hooked")
	get_tree().get_root().add_child(_hook_instance)

	var throw_force_mod := clamp(hook_end.global_position.distance_to(get_global_mouse_position()) / 80.0, 0.2, 1.0)
	if Vector2.RIGHT.rotated(pivot_point.rotation).dot(hook_end.global_position.direction_to(get_global_mouse_position())) < 0:
		throw_force_mod = 0.2

	# print("Rod throw force: ", throw_force_mod)

	# print("Hook end to mouse: ", hook_end.global_position.distance_to(get_global_mouse_position()))

	_hook_instance.throw_hook(hook_end.global_position, throw_dir, hook_throwing_force * throw_force_mod)

	# print("Hook Thrown")


func break_hook() -> void:
	if not is_instance_valid(_hook_instance):
		return

	_hook_instance.disconnect("hook_hooked", self, "_on_hook_hooked")
	
	_hook_instance.call_deferred("free")
	yield(_hook_instance, "tree_exited")
	_hook_instance = null

	is_hooked = false

	if (player.state_manager.current_state == PlayerBaseState.State.ITEM_OVERRIDE):
		if not player.is_on_floor():
			player.state_manager.change_state(PlayerBaseState.State.FALL, {no_jump = true})
		
		else:
			player.player_movement.set_snap(true)

			if player.player_movement.velocity.length_squared() > 0.0:
				player.state_manager.change_state(PlayerBaseState.State.WALK)

			else:
				player.state_manager.change_state(PlayerBaseState.State.IDLE)

	emit_signal("rod_hook_released")
	print("Hook Broken")


func reel_line(delta : float) -> void:
	if hook_end_hook_dist > get_line_with_tension() + reel_tolorence:
		return

	current_reel_time += delta

	var accel_multiplier := clamp(inverse_lerp(0, time_to_max_reel, current_reel_time), 0.2, 1)
	var reel_amount := reel_acceleration * accel_multiplier * delta 

	max_line_length = clamp(max_line_length - reel_amount, min_line_length, max_line_length)
	# print("Reeling - Max Line Length: ", max_line_length)


func grappling(delta : float) -> void:
	# applying pendulum angle acceleration
	var angle_accel = -pendulumn_fall * cos(_hook_instance.global_position.direction_to(hook_end.global_position).angle())
	
	angle_accel += get_movement_input().x * push_force

	# TODO: need to update player sprite facing direction

	player.update_sprite(get_movement_input())

	angular_velocity += angle_accel	
	angular_velocity *= 0.99

	angular_vel_rate_of_change = angular_velocity - previous_anglular_velocity

	# print ("ROC: ", angular_vel_rate_of_change)

	previous_anglular_velocity = angular_velocity
	
	# print("ang velocity: ", angular_velocity)
	
	var hook_dir := hook_end.global_position.direction_to(_hook_instance.global_position) as Vector2
	var p_hook_dir := Vector2(sign(angular_velocity) * -hook_dir.y, sign(angular_velocity) * hook_dir.x).normalized()
	var s_force := p_hook_dir * (abs(angular_velocity) * get_weighted_swing_speed()) 

	# print("s force: ", s_force)

	# adjust to meet max_line_length
	var dist_factor := (hook_end_hook_dist - get_line_with_tension())
	var adjust_force := dist_factor * hook_dir * grapple_adjustment_force
	s_force += adjust_force

	player.player_movement.set_velocity(s_force)
	
	if player.player_movement.velocity.length() > max_swing_speed:
		player.player_movement.set_velocity(player.player_movement.velocity.normalized() * max_swing_speed)
	
	player.player_movement.player_move_and_slide()

	check_grapple_state_change()

	# TODO: there should still be some force being acted on the hooked object (maybe) - the weight of the player


func get_movement_input() -> Vector2:
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1

	return input_dir


func check_grapple_state_change() -> void:
	if player.is_on_floor():
		player.player_movement.set_snap(true)

		player.player_movement.velocity.y = 0.0

		if player.player_movement.velocity.length_squared() > 0.0:
			player.state_manager.change_state(PlayerBaseState.State.WALK)

		else:
			player.state_manager.change_state(PlayerBaseState.State.IDLE)


func convert_to_angular_vel(current_vel : Vector2) -> void:
	angular_velocity = sign(current_vel.x) * (current_vel.length() / get_weighted_swing_speed())


func get_weighted_swing_speed() -> float:
	var swing_speed_weight := clamp(get_line_with_tension() / 100.0, 0.4, 1.0)
	return swing_speed * swing_speed_weight


func pulling(delta : float) -> void:
	if hook_end_hook_dist <= get_line_with_tension():
		pullback_velocity = lerp(pullback_velocity, Vector2.ZERO, 0.1)
		# print("Fishing rod should not be pulling anymore")

	else:
		var dir_to_hook := (_hook_instance.global_position - hook_end.global_position).normalized() as Vector2 

		if not player.state_manager.current_state == PlayerBaseState.State.IDLE or is_reeling:
			var force_multiplier := max(inverse_lerp(max_line_length, get_line_with_tension(), hook_end_hook_dist), 0)

			pullback_velocity = Vector2.ONE * pullback_force * force_multiplier

		pullback_velocity = pullback_velocity.length() * dir_to_hook

		if player.player_movement._snap_vector != Vector2.ZERO and not is_reeling:
			pullback_velocity.y = 0.0
		
	# print("Pullback Velocity(X, Y): ", pullback_velocity)
	player.player_movement.add_velocity(pullback_velocity)
	
	# TODO: apply force to object based on pull - force changes depending on 


func get_line_with_tension() -> float:
	return max_line_length * max_tension


func transition_to_grapple():
	if not is_grappling:
		is_grappling = true
		can_rotate_grapple = false
		
		
		current_rotation_transition = 0.0

		pullback_velocity = Vector2.ZERO

		convert_to_angular_vel(player.player_movement.velocity)\

		# print("Pullback Velocity(X, Y): ", pullback_velocity)

		# print("Fishing Rod now grappling")


func _on_hook_hooked() -> void:
	# print("hook_hooked signal received")

	if is_hooked or not is_instance_valid(_hook_instance):
		return
	
	is_hooked = true
	max_line_length = hook_end.global_position.distance_to(_hook_instance.global_position) + line_length_slack
	pullback_velocity = Vector2.ZERO

	if player.state_manager.current_state == PlayerBaseState.State.FALL:
		player.state_manager.change_state(PlayerBaseState.State.ITEM_OVERRIDE)

		# This second conversion is required to prevent snapping and jittery behaviour when first 
		# grappling while falling - likely works due to it dampening the extra velocity from the player
		convert_to_angular_vel(player.player_movement.velocity)

		# print("Fishing Rod now grappling")
	
	elif player.state_manager.current_state != PlayerBaseState.State.ITEM_OVERRIDE:
		is_grappling = false
		# print("Fishing Rod now pulling")
	
	emit_signal("rod_hooked")
	

func _on_state_changed(new_state : int) -> void:
	if not is_hooked:
		return

	if new_state == PlayerBaseState.State.ITEM_OVERRIDE:
		transition_to_grapple()
			
	else:
		if is_grappling:
			is_grappling = false
			# print("Fishing Rod now pulling")

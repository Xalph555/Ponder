# Rod Hooked Solid Object State
# ---------------------------------
extends BaseRodState


# Variables:
#---------------------------------------
var hooked_surface

# # pullling
# var pullback_force := 45.0 # this value should not change
# var pullback_velocity := Vector2.ZERO


# Functions:
#--------------------------------------
func enter(args := {}) -> void:
	.enter(args)
	
	if args.has("hooked_surface"):
		hooked_surface = args["hooked_surface"]
		# print("Hooked Surface recieved: ", hooked_surface)

	emit_signal("state_entered")


func exit() -> void:
	emit_signal("state_exited")


func update_unwrapping() -> void:
	if rod_ref.wrap_points.size() < 2:
		return
	
	var dir_anchor_to_hinge := rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.wrap_points.back()) as Vector2
	var dir_anchor_to_rod := rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.hook_end.global_position) as Vector2

	var hook_end_angle := dir_anchor_to_hinge.angle_to(dir_anchor_to_rod) as float

	if sign(rod_ref.wrap_angles.back()) > 0:
		# print("Hook End Angle: ", hook_end_angle, " | Required (Less than): ", wrap_angles.back())

		if hook_end_angle < rod_ref.wrap_angles.back():
			unwrap_last_hook_point()
	
	else:
		# print("Hook End Angle: ", hook_end_angle, " | Required (greater than): ", wrap_angles.back())

		if hook_end_angle > rod_ref.wrap_angles.back():
			unwrap_last_hook_point()


func unwrap_last_hook_point() -> void:
	if rod_ref.wrap_points.size() < 2:
		return

	# Only unwrap if there is a clear line of sight to next available wrap point
	var space_state = rod_ref.get_world_2d().direct_space_state
	var cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points[rod_ref.wrap_points.size() - 2], [attached_player.attached_entity, rod_ref._hook_instance])

	if not cast_res:
		rod_ref.wrap_points.remove(rod_ref.wrap_points.size() - 1)

		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 2] += rod_ref.wrap_lengths.back()
		rod_ref.wrap_lengths.remove(rod_ref.wrap_lengths.size() - 1)

		rod_ref.wrap_angles.remove(rod_ref.wrap_angles.size() - 1)
	
	else:
		# ray cast debugging
		# last_ray_cast_points = [hook_end.global_position, wrap_points[wrap_points.size() - 2]]
		# ray_cast_hit_point = cast_res.position

		# print("no clean line of sight to unwrap | points remaining: ", wrap_points.size())
		# print("Object in line of sight: ", cast_res.collider)

		pass


func update_wrapping() -> void:
	if rod_ref.hitbox.get_overlapping_bodies().size() != 0:
		return

	var space_state = rod_ref.get_world_2d().direct_space_state
	var cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points.back(), [attached_player.attached_entity, rod_ref._hook_instance])

	if cast_res:
		# print("Rope Wrapping | Position: ", cast_res.position, " | O abject: ", cast_res.collider)

		var new_point := cast_res.position as Vector2
		var offset_dir := rod_ref.get_offset_dir(cast_res.collider, new_point) as Vector2

		# print("Offset dir: ", offset_dir)

		# ray cast debugging
		# last_ray_cast_points = [new_point, new_point + (offset_dir * 20)]
		# ray_cast_hit_point = new_point

		new_point = rod_ref.adjust_hit_point(new_point, offset_dir, rod_ref.wrapping_offset, rod_ref.hook_end.global_position, rod_ref.wrap_points.back(), rod_ref.offset_attemps, space_state, [attached_player.attached_entity, rod_ref._hook_instance])

		if new_point == Vector2.INF:
			return

		# is wrapping allowed
		var dist_to_last_point = new_point.distance_to(rod_ref.wrap_points.back())

		if dist_to_last_point < rod_ref.get_min_line_length() or rod_ref.hook_end.global_position.distance_to(new_point) < rod_ref.get_min_line_length():
			return

		# print("Min Line Length: ", min_line_length, " | dist to last point: ", dist_to_last_point, " | hook end to new: ", hook_end.global_position.distance_to(new_point))

		rod_ref.wrap_points.append(new_point)

		var remaining_dist = rod_ref.wrap_lengths.back() - dist_to_last_point

		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] = dist_to_last_point
		rod_ref.wrap_lengths.append(remaining_dist)

		var dir_anchor_to_hinge := rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.wrap_points.back()) as Vector2
		var dir_anchor_to_rod := rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.hook_end.global_position) as Vector2

		var angle_to_add = dir_anchor_to_hinge.angle_to(dir_anchor_to_rod)

		rod_ref.wrap_angles.append(angle_to_add)


func get_line_length_max_tension() -> float:
	return rod_ref.wrap_lengths.back()


func handle_rod_behaviour(delta : float) -> void:
	# print("Current Max Line Length: ", rod_ref.get_max_line_length())
	# print("Back Length: ", rod_ref.wrap_lengths.back(), " | Front Length: ", rod_ref.wrap_lengths.front())
	
	# Update player's actual distance to connected point
	attached_player.current_dist_last_point = rod_ref.hook_end.global_position.distance_to(rod_ref.wrap_points.back())



	if attached_player.is_grappled:
		grapple_player(delta)
	else:
		pull_player(delta)


func transition_player_to_grapple() -> void:
	if not attached_player.is_grappled:
		attached_player.is_grappled = true

		attached_player.pullback_velocity = Vector2.ZERO

		var conversion_weight = clamp(inverse_lerp(rod_ref.get_min_line_length(), 40.0, get_line_length_max_tension()) , 0.05, 0.8)

		# print("Conversion weight: ",conversion_weight)

		convert_to_angular_vel(attached_player.attached_entity.player_movement.velocity * conversion_weight)

		# print("Pullback Velocity(X, Y): ", pullback_velocity)
		# print("Fishing Rod now grappling")


func convert_to_angular_vel(current_vel : Vector2) -> void:
	# rod_ref.attached_player.angular_velocity = sign(current_vel.x) * (current_vel.length() / get_weighted_swing_speed())
	attached_player.angular_velocity = sign(current_vel.x) * (current_vel.length() / get_weighted_swing_speed())


func get_weighted_swing_speed() -> float:
	var swing_speed_weight := clamp(rod_ref.get_max_line_length() / 100.0, 0.4, 1.0)
	return rod_ref.swing_speed * swing_speed_weight


func can_player_grapple() -> bool:
	var dir_to_hook_end := rod_ref.wrap_points.back().direction_to(rod_ref.hook_end.global_position) as Vector2

	# return not attached_player.is_grappled and not attached_player.attached_entity.is_on_floor() and rod_ref.hook_end_hook_dist >= get_line_length_max_tension() and Vector2.UP.dot(dir_to_hook_end) < -0.3
	return not attached_player.is_grappled and not attached_player.attached_entity.is_on_floor() and attached_player.current_dist_last_point >= get_line_length_max_tension() and Vector2.UP.dot(dir_to_hook_end) < -0.3


func grapple_player(delta : float) -> void:
	var grapple_params := RodGrappleParams.new(attached_player.angular_velocity, attached_player.previous_anglular_velocity, attached_player.angular_vel_rate_of_change, rod_ref.wrap_points.back(), rod_ref.hook_end.global_position, get_weighted_swing_speed(), rod_ref.get_movement_input(), get_line_length_max_tension(), attached_player.current_dist_last_point)

	attached_player.attached_entity.update_sprite(rod_ref.get_movement_input())

	attached_player.attached_entity.player_movement.set_velocity(rod_ref.get_grapple_force(grapple_params))

	if attached_player.attached_entity.player_movement.velocity.length() > rod_ref.max_swing_speed:
		attached_player.attached_entity.player_movement.set_velocity(attached_player.attached_entity.player_movement.velocity.normalized() * rod_ref.max_swing_speed)

	attached_player.angular_velocity = grapple_params.angular_vel
	attached_player.previous_anglular_velocity = grapple_params.previous_angular_vel
	attached_player.angular_vel_rate_of_change = grapple_params.angular_vel_roc

	rod_ref.update_grappling_rod_rotation(delta, attached_player.angular_vel_rate_of_change)
	
	attached_player.attached_entity.player_movement.player_move_and_slide()

	check_grapple_state_change()


func check_grapple_state_change() -> void:
	if attached_player.attached_entity.is_on_floor():
		attached_player.attached_entity.player_movement.set_snap(true)

		attached_player.attached_entity.player_movement.velocity.y = 0.0

		if attached_player.attached_entity.player_movement.velocity.length_squared() > 0.0:
			attached_player.attached_entity.state_manager.change_state(PlayerBaseState.State.WALK)

		else:
			attached_player.attached_entity.state_manager.change_state(PlayerBaseState.State.IDLE)


func pull_player(delta : float) -> void:
	rod_ref.update_pull_rod_rotation(delta)

	var pull_params := RodPullParams.new(attached_player.pullback_velocity, rod_ref.wrap_points.back(), rod_ref.hook_end.global_position, attached_player.pullback_force, get_line_length_max_tension(), attached_player.current_dist_last_point)

	pull_params.current_vel = attached_player.attached_entity.player_movement.velocity.length()
		
	# slope correction
	if attached_player.attached_entity.player_movement.is_on_slope():
		pull_params.rotation_ang = attached_player.attached_entity.get_floor_normal().angle()
		# dir_to_hook = dir_to_hook.rotated(attached_player.attached_entity.get_floor_normal().angle())

	attached_player.pullback_velocity = rod_ref.get_pulling_force(pull_params)

	if attached_player.attached_entity.player_movement._snap_vector != Vector2.ZERO and not rod_ref.is_being_reeled():
		attached_player.pullback_velocity.y = 0.0

	# print("Pullback Velocity(X, Y): ", attached_player.pullback_velocity)
	# print("Pullback Velocity: ", attached_player.pullback_velocity.length())
	attached_player.attached_entity.player_movement.add_velocity(attached_player.pullback_velocity)


func can_reel() -> bool:
	var dir_of_rod := Vector2.RIGHT.rotated(rod_ref.pivot_point.rotation)
	var dir_to_hook := rod_ref.pivot_point.global_position.direction_to(rod_ref.wrap_points.back()) as Vector2

	# var can := (rod_ref.hook_end_hook_dist <= get_line_length_max_tension() + rod_ref.reel_tolorence and dir_of_rod.dot(dir_to_hook) >= 0.7) as bool
	var can := (attached_player.current_dist_last_point <= get_line_length_max_tension() + rod_ref.reel_tolorence and dir_of_rod.dot(dir_to_hook) >= 0.7) as bool

	return can


func start_reeling(delta : float) -> void:
	if not can_reel():
		return
	
	if attached_player.attached_entity.player_movement.is_snapped():
		attached_player.attached_entity.player_movement.set_snap(false)

	rod_ref.current_reel_time += delta

	var accel_multiplier := clamp(inverse_lerp(0, rod_ref.time_to_max_reel, rod_ref.current_reel_time), 0.2, 1)
	var reel_amount := (rod_ref.reel_acceleration * accel_multiplier * delta) as float

	rod_ref.max_line_length = clamp(rod_ref.get_max_line_length() - reel_amount, rod_ref.get_min_line_length(), rod_ref.get_max_line_length())

	# print("Reeling - Max Line Length: ", max_line_length)
	# print("Wrap Lengths array size: ", wrap_lengths.size())

	if rod_ref.wrap_lengths.size() == 1:
		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] = rod_ref.get_max_line_length()
	else:
		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] -= reel_amount

	if rod_ref.wrap_lengths.back() <= 0.0:
		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] = 0.0

		unwrap_last_hook_point()


func stop_reeling() -> void:
	if attached_player.attached_entity.state_manager.current_state != PlayerBaseState.State.FALL:
		attached_player.attached_entity.player_movement.set_snap(true)
	
	rod_ref.is_reeling = false

	rod_ref.emit_signal("rod_reeling_stopped")

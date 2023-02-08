# Rod Hooked Solid Object State
# ---------------------------------
extends BaseRodState


# Functions:
#--------------------------------------
func enter() -> void:
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

		if hook_end_angle <= rod_ref.wrap_angles.back():
			unwrap_last_hook_point()
	
	else:
		# print("Hook End Angle: ", hook_end_angle, " | Required (greater than): ", wrap_angles.back())

		if hook_end_angle >= rod_ref.wrap_angles.back():
			unwrap_last_hook_point()


func unwrap_last_hook_point() -> void:
	if rod_ref.wrap_points.size() < 2:
		return

	# Only unwrap if there is a clear line of sight to next available wrap point
	var space_state = rod_ref.get_world_2d().direct_space_state
	var cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points[rod_ref.wrap_points.size() - 2], [rod_ref.player, rod_ref._hook_instance])

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
	var cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points.back(), [rod_ref.player, rod_ref._hook_instance])

	if cast_res:
		# print("Rope Wrapping | Position: ", cast_res.position, " | O abject: ", cast_res.collider)

		var new_point := cast_res.position as Vector2
		var offset_dir := rod_ref.get_offset_dir(cast_res.collider, new_point) as Vector2

		# print("Offset dir: ", offset_dir)

		# ray cast debugging
		# last_ray_cast_points = [new_point, new_point + (offset_dir * 20)]
		# ray_cast_hit_point = new_point

		new_point = rod_ref.adjust_hit_point(new_point, offset_dir, rod_ref.wrapping_offset, rod_ref.hook_end.global_position, rod_ref.wrap_points.back(), rod_ref.offset_attemps, space_state, [rod_ref.player, rod_ref._hook_instance])

		if new_point == Vector2.INF:
			return

		# var attemps := 0
		# while (space_state.intersect_ray(hook_end.global_position, new_point, [player, _hook_instance]) or space_state.intersect_ray(wrap_points.back(), new_point, [player, _hook_instance])) and (attemps < offset_attemps):
		# 	new_point += offset_dir * wrapping_offset
		# 	attemps += 1
		
		# if attemps >= offset_attemps:
		# 	print("Failed to offset point")
		# 	return

		# is wrapping allowed
		var dist_to_last_point = new_point.distance_to(rod_ref.wrap_points.back())

		if dist_to_last_point < get_min_line_length() or rod_ref.hook_end.global_position.distance_to(new_point) < get_min_line_length():
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


func get_max_line_length() -> float:
    return rod_ref.max_line_length


func get_min_line_length() -> float:
	return rod_ref.min_line_length 


func get_line_length_max_tension() -> float:
    return rod_ref.wrap_lengths.back()


func get_line_length_min_tension() -> float:
    return rod_ref.wrap_lengths.back() * rod_ref.min_tension


func transition_to_grapple() -> void:
	if not rod_ref.is_grappling:
		rod_ref.is_grappling = true
		rod_ref.can_rotate_grapple = false
		rod_ref.current_rotation_transition = 0.0
		
		rod_ref.pullback_velocity = Vector2.ZERO

		var conversion_weight = clamp(inverse_lerp(get_min_line_length(), 40.0, get_line_length_max_tension()) , 0.05, 0.8)

		# print("Conversion weight: ",conversion_weight)

		convert_to_angular_vel(rod_ref.player.player_movement.velocity * conversion_weight)

		# print("Pullback Velocity(X, Y): ", pullback_velocity)

		# print("Fishing Rod now grappling")


func convert_to_angular_vel(current_vel : Vector2) -> void:
	rod_ref.angular_velocity = sign(current_vel.x) * (current_vel.length() / get_weighted_swing_speed())


func get_weighted_swing_speed() -> float:
	# var swing_speed_weight := clamp(get_line_with_max_tension() / 100.0, 0.4, 1.0)
	var swing_speed_weight := clamp(get_max_line_length() / 100.0, 0.4, 1.0)
	return rod_ref.swing_speed * swing_speed_weight


func can_grapple() -> bool:
	var dir_to_hook_end := rod_ref.wrap_points.back().direction_to(rod_ref.hook_end.global_position) as Vector2

	return not rod_ref.is_grappling and not rod_ref.player.is_on_floor() and rod_ref.hook_end_hook_dist >= get_line_length_max_tension() and Vector2.UP.dot(dir_to_hook_end) < -0.3


func check_grapple_state_change() -> void:
	if rod_ref.player.is_on_floor():
		rod_ref.player.player_movement.set_snap(true)

		rod_ref.player.player_movement.velocity.y = 0.0

		if rod_ref.player.player_movement.velocity.length_squared() > 0.0:
			rod_ref.player.state_manager.change_state(PlayerBaseState.State.WALK)

		else:
			rod_ref.player.state_manager.change_state(PlayerBaseState.State.IDLE)


func grapple_entity() -> void:
	# applying pendulum angle acceleration
	var angle_accel = -rod_ref.pendulumn_fall * cos(rod_ref.wrap_points.back().direction_to(rod_ref.hook_end.global_position).angle())
	
	angle_accel += rod_ref.get_movement_input().x * rod_ref.push_force

	#updating player sprite direction
	rod_ref.player.update_sprite(rod_ref.get_movement_input())

	rod_ref.angular_velocity += angle_accel	

	rod_ref.angular_velocity *= 0.99

	# print("Angular Vel: ", angular_velocity)

	rod_ref.angular_vel_rate_of_change = rod_ref.angular_velocity - rod_ref.previous_anglular_velocity

	# print ("ROC: ", angular_vel_rate_of_change)

	rod_ref.previous_anglular_velocity = rod_ref.angular_velocity
	
	# print("ang velocity: ", angular_velocity)
	
	var hook_dir := rod_ref.hook_end.global_position.direction_to(rod_ref.wrap_points.back()) as Vector2
	var p_hook_dir := Vector2(sign(rod_ref.angular_velocity) * -hook_dir.y, sign(rod_ref.angular_velocity) * hook_dir.x).normalized()
	var s_force := p_hook_dir * (abs(rod_ref.angular_velocity) * get_weighted_swing_speed()) 

	# print("s force: ", s_force)

	# adjust to meet max_line_length
	var dist_factor := (rod_ref.hook_end_hook_dist - get_line_length_max_tension()) as float
	var adjust_force := (dist_factor * hook_dir * rod_ref.grapple_adjustment_force) as Vector2
	s_force += adjust_force

	rod_ref.player.player_movement.set_velocity(s_force)
	
	if rod_ref.player.player_movement.velocity.length() > rod_ref.max_swing_speed:
		rod_ref.player.player_movement.set_velocity(rod_ref.player.player_movement.velocity.normalized() * rod_ref.max_swing_speed)
	
	rod_ref.player.player_movement.player_move_and_slide()

	check_grapple_state_change()


func pull_entity() -> void:
	if rod_ref.hook_end_hook_dist <= get_line_length_max_tension():
		rod_ref.pullback_velocity = lerp(rod_ref.pullback_velocity, Vector2.ZERO, 0.1)
		# print("Fishing rod should not be pulling anymore")

	else:
		var dir_to_hook := rod_ref.hook_end.global_position.direction_to(rod_ref.wrap_points.back()) as Vector2

		if rod_ref.player.player_movement.is_on_slope():
			dir_to_hook = dir_to_hook.rotated(rod_ref.player.get_floor_normal().angle())

		# print("Dir to hook: ", dir_to_hook)

		var force_multiplier := max(rod_ref.hook_end_hook_dist - get_line_length_max_tension(), 0.0)
		rod_ref.pullback_velocity = rod_ref.pullback_force * force_multiplier * dir_to_hook

		# print("Pullback Velocity before y-adjustment (X, Y): ", pullback_velocity)

		if rod_ref.player.player_movement._snap_vector != Vector2.ZERO and not rod_ref.is_being_reeled():
			rod_ref.pullback_velocity.y = 0.0
		

	# print("Pullback Velocity(X, Y): ", pullback_velocity)
	rod_ref.player.player_movement.add_velocity(rod_ref.pullback_velocity)


func can_reel() -> bool:
	var dir_of_rod := Vector2.RIGHT.rotated(rod_ref.pivot_point.rotation)
	var dir_to_hook := rod_ref.pivot_point.global_position.direction_to(rod_ref.wrap_points.back()) as Vector2

	var can := (rod_ref.hook_end_hook_dist <= get_line_length_max_tension() + rod_ref.reel_tolorence and dir_of_rod.dot(dir_to_hook) >= 0.7) as bool

	# print("Can Reel: ", can)
	# print("Reel length test: ", hook_end_hook_dist <= get_line_with_max_tension() + reel_tolorence)
	# print("Dot check: ", dir_of_rod.dot(dir_to_hook) >= 0.7)
	# print("-------------------------------------------")
	# print("Player snap vector: ", player.player_movement._snap_vector)

	return can


func start_reeling(delta : float) -> void:
	if not can_reel():
		return
	
	if rod_ref.player.player_movement.is_snapped():
		rod_ref.player.player_movement.set_snap(false)

	rod_ref.current_reel_time += delta

	var accel_multiplier := clamp(inverse_lerp(0, rod_ref.time_to_max_reel, rod_ref.current_reel_time), 0.2, 1)
	var reel_amount := (rod_ref.reel_acceleration * accel_multiplier * delta) as float

	rod_ref.max_line_length = clamp(get_max_line_length() - reel_amount, get_min_line_length(), get_max_line_length())

	# print("Reeling - Max Line Length: ", max_line_length)
	# print("Wrap Lengths array size: ", wrap_lengths.size())

	if rod_ref.wrap_lengths.size() == 1:
		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] = get_max_line_length()

	else:
		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] -= reel_amount

	if rod_ref.wrap_lengths.back() <= 0.0:
		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] = 0.0

		unwrap_last_hook_point()


func stop_reeling() -> void:
	if rod_ref.player.state_manager.current_state != PlayerBaseState.State.FALL:
		rod_ref.player.player_movement.set_snap(true)
	
	rod_ref.is_reeling = false

	rod_ref.emit_signal("rod_reeling_stopped")
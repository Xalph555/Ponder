# Rod Hooked Moveable Object State
# ---------------------------------
extends BaseRodState


# Variables:
#---------------------------------------
enum DominantEntity {
	NONE,
	PLAYER,
	OBJECT
}


var attached_object : RodAttachedObject

var current_line_length := 0.0

var dominant_entity := DominantEntity.NONE as int


# Functions:
#--------------------------------------
func enter(args := {}) -> void:
	.enter(args)

	if args.has("hooked_object"):
		attached_object = RodAttachedObject.new(args["hooked_object"])

	dominant_entity = DominantEntity.PLAYER

	emit_signal("state_entered")


func exit() -> void:
	attached_object.attached_entity.controls_movement = true
	attached_object.is_grappled = false
			
	emit_signal("state_exited")

	
func update_unwrapping() -> void:
	if rod_ref.wrap_points.size() > 1:
		update_unwrapping_player()
		
	if rod_ref.wrap_points.size() > 2:
		update_unwrapping_object()


func update_wrapping() -> void:
	update_wrapping_player()

	if rod_ref.wrap_points.size() > 1:
		update_wrapping_object()


func update_unwrapping_player() -> void:
	if rod_ref.hitbox.get_overlapping_bodies().size() != 0:
		return

	var hook_end_angle := rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.wrap_points.back()).angle_to(rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.hook_end.global_position)) as float

	if sign(rod_ref.wrap_angles.back()) > 0:
		if hook_end_angle < rod_ref.wrap_angles.back():
			unwrap_point(true)
	else:
		if hook_end_angle > rod_ref.wrap_angles.back():
			unwrap_point(true)


func update_unwrapping_object() -> void:
	var hook_start_angle := rod_ref.wrap_points.front().direction_to(rod_ref.wrap_points[1]).angle_to(rod_ref.wrap_points.front().direction_to(rod_ref.wrap_points[2])) as float
		
	if sign(rod_ref.wrap_angles[1]) > 0:
		if hook_start_angle < rod_ref.wrap_angles[1]:
			print("Current Angle: ", hook_start_angle)
			print("Angle being tested: ", rod_ref.wrap_angles[1])
			unwrap_point(false)
	else:
		if hook_start_angle > rod_ref.wrap_angles[1]:
			print("Current Angle: ", hook_start_angle)
			print("Angle being tested: ", rod_ref.wrap_angles[1])
			unwrap_point(false)


func unwrap_point(is_rod_point : bool) -> void:
	if rod_ref.wrap_points.size() < 2:
		print("HookedObject Rod State - Could not unwrap due to insufficient wrap_points")
		return

	var space_state = rod_ref.get_world_2d().direct_space_state

	if is_rod_point:
		var cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points[rod_ref.wrap_points.size() - 2], [attached_player.attached_entity, attached_object.attached_entity, rod_ref._hook_instance])

		if not cast_res:
			rod_ref.wrap_points.remove(rod_ref.wrap_points.size() - 1)

			rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 2] += rod_ref.wrap_lengths.back()
			rod_ref.wrap_lengths.remove(rod_ref.wrap_lengths.size() - 1)

			rod_ref.wrap_angles.remove(rod_ref.wrap_points.size() - 1)

			print("--------------------------------")
			print("Unwrapping rod point - player")
	
	else:
		var cast_res = space_state.intersect_ray(rod_ref.wrap_points.front(), rod_ref.wrap_points[1], [attached_player.attached_entity, attached_object.attached_entity, rod_ref._hook_instance])

		if not cast_res:
			print("--------------------------------")
			print("Unwrapping object point - object")
			print("Angles: ", rod_ref.wrap_angles)
			
			rod_ref.wrap_points.remove(1)

			rod_ref.wrap_lengths[0] += rod_ref.wrap_lengths[1]
			rod_ref.wrap_lengths.remove(1)

			rod_ref.wrap_angles.remove(1)	
	
	print("Current Max Line Length: ", rod_ref.get_max_line_length())
	print("Lengths array: ", rod_ref.wrap_lengths)
	
	var length_total := 0.0
	for l in rod_ref.wrap_lengths:
		length_total += l
	print("Length array (total): ", length_total)

	print("--------------------------------")


func update_wrapping_player() -> void:
	var space_state = rod_ref.get_world_2d().direct_space_state
	var cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points.back(), [attached_player.attached_entity, rod_ref._hook_instance, attached_object.attached_entity])

	if cast_res:
		var new_point := cast_res.position as Vector2
		var offset_dir := rod_ref.get_offset_dir(cast_res.collider, new_point) as Vector2

		new_point = rod_ref.adjust_hit_point(new_point, offset_dir, rod_ref.wrapping_offset, rod_ref.hook_end.global_position, rod_ref.wrap_points.back(), rod_ref.offset_attemps, space_state, [attached_player.attached_entity, rod_ref._hook_instance, attached_object.attached_entity])

		if new_point == Vector2.INF:
			return

		# is wrapping allowed
		var dist_to_last_point = new_point.distance_to(rod_ref.wrap_points.back())
		if dist_to_last_point < rod_ref.get_min_line_length() or rod_ref.hook_end.global_position.distance_to(new_point) < rod_ref.get_min_line_length():
			return

		rod_ref.wrap_points.append(new_point)

		var remaining_dist = rod_ref.wrap_lengths.back() - dist_to_last_point

		print("Current Max Line Length (player wrap): ", rod_ref.get_max_line_length())

		print("Lengths array: ", rod_ref.wrap_lengths)

		print("Dist_to_last_point: ", dist_to_last_point)
		print("Remaining dist: ", remaining_dist)

		print("Original back point: ", rod_ref.wrap_lengths.back())
		rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] = dist_to_last_point
		print("Upated back point (player wrap): ", rod_ref.wrap_lengths.back())
		rod_ref.wrap_lengths.append(remaining_dist)
		print("New back point (player wrap): ", rod_ref.wrap_lengths.back())

		print("Lengths array: ", rod_ref.wrap_lengths)

		var length_total := 0.0
		for l in rod_ref.wrap_lengths:
			length_total += l
		print("Length array (total): ", length_total)

		print("--------------------------------")

		var dir_anchor_to_hinge := rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.wrap_points.back()) as Vector2
		var dir_anchor_to_rod := rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.hook_end.global_position) as Vector2

		var angle_to_add = dir_anchor_to_hinge.angle_to(dir_anchor_to_rod)

		rod_ref.wrap_angles.append(angle_to_add)


func update_wrapping_object() -> void:
	var space_state = rod_ref.get_world_2d().direct_space_state
	var cast_res = space_state.intersect_ray(rod_ref.wrap_points.front(), rod_ref.wrap_points[1], [attached_player.attached_entity, rod_ref._hook_instance, attached_object.attached_entity])

	if cast_res:
		var new_point := cast_res.position as Vector2
		var offset_dir := rod_ref.get_offset_dir(cast_res.collider, new_point) as Vector2

		new_point = rod_ref.adjust_hit_point(new_point, offset_dir, rod_ref.wrapping_offset, rod_ref.wrap_points.front(), rod_ref.wrap_points[1], rod_ref.offset_attemps, space_state, [attached_player.attached_entity, rod_ref._hook_instance, attached_object.attached_entity])

		if new_point == Vector2.INF:
			return
		
		# is wrapping allowed
		var dist_to_last_point = new_point.distance_to(rod_ref.wrap_points.front())
		if dist_to_last_point < rod_ref.get_min_line_length() or rod_ref.wrap_points.front().distance_to(new_point) < rod_ref.get_min_line_length():
			return

		rod_ref.wrap_points.insert(1, new_point)

		var remaining_dist = rod_ref.wrap_lengths.front() - dist_to_last_point

		print("Dist_to_last_point: ", dist_to_last_point)
		print("Remaining dist: ", remaining_dist)

		print("Current Max Line Length (object wrap): ", rod_ref.get_max_line_length())
		rod_ref.wrap_lengths[0] = dist_to_last_point
		print("Upated front point (object wrap): ", rod_ref.wrap_lengths.front())
		rod_ref.wrap_lengths.insert(1, remaining_dist)
		print("New front[1] point (object wrap): ", rod_ref.wrap_lengths[1])

		print("Lengths array: ", rod_ref.wrap_lengths)

		var length_total := 0.0
		for l in rod_ref.wrap_lengths:
			length_total += l
		print("Length array (total): ", length_total)

		print("--------------------------------")

		var angle_to_add = rod_ref.wrap_points.front().direction_to(rod_ref.wrap_points[1]).angle_to(rod_ref.wrap_points.front().direction_to(rod_ref.wrap_points[2]))

		rod_ref.wrap_angles.insert(1, angle_to_add)


func get_line_length_max_tension() -> float:
	# if from_player:
	# 	return rod_ref.wrap_lengths.back()
	# else:
	# 	return rod_ref.wrap_lengths.front()
	
	return rod_ref.wrap_lengths.front() + rod_ref.wrap_lengths.back()


func handle_rod_behaviour(delta : float) -> void:
	# print("Current Max Line Length: ", rod_ref.get_max_line_length())
	# print("Back Length: ", rod_ref.wrap_lengths.back(), " | Front Length: ", rod_ref.wrap_lengths.front())
	# print("Lengths array: ", rod_ref.wrap_lengths)
	# print("--------------------------------")

	# Update attached object's position
	# rod_ref.wrap_points[0] = attached_object.attached_entity.global_position
	rod_ref.wrap_points[0] = rod_ref._hook_instance.global_position

	update_wrapping_distances(delta)

	# update states for each attached object
	update_object_states()

	# TODO: Update Dominance?

	# execute grapple and pull behaviours
	if dominant_entity == DominantEntity.PLAYER:
		rod_ref.update_fishing_rod_rotation(delta)

		if attached_object.is_grappled:
			grapple_object(delta)
		else:
			pull_object(delta)
	
	else:
		if attached_player.is_grappled:
			grapple_player(delta)
		else:
			pull_player(delta)		
	

func update_wrapping_distances(delta : float) -> void:
	# Update player's actual distance from last point
	attached_player.current_dist_last_point = rod_ref.hook_end.global_position.distance_to(rod_ref.wrap_points.back())

	# Update object's actual distance from last point
	if rod_ref.wrap_points.size() > 1:
		attached_object.current_dist_last_point = rod_ref.wrap_points.front().distance_to(rod_ref.wrap_points[1])
	else:
		attached_object.current_dist_last_point = rod_ref.wrap_points.front().distance_to(rod_ref.hook_end.global_position)

	# update end distances
	if dominant_entity == DominantEntity.PLAYER:
		if rod_ref.wrap_lengths.size() > 1:
			var player_dist_diff := (attached_player.current_dist_last_point - rod_ref.wrap_lengths.back()) as float

			rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] += player_dist_diff
			rod_ref.wrap_lengths[0] -= player_dist_diff

	else:
		if rod_ref.wrap_lengths.size() > 1:
			var object_dist_diff := (attached_object.current_dist_last_point - rod_ref.wrap_lengths.front()) as float

			rod_ref.wrap_lengths[0] += object_dist_diff
			rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] -= object_dist_diff

	if rod_ref.wrap_lengths.back() < 0.0:
		unwrap_point(true)

	if rod_ref.wrap_lengths.front() < 0.0:
		unwrap_point(false)

	# update current actual line length
	current_line_length = attached_player.current_dist_last_point + attached_object.current_dist_last_point


func update_object_states() -> void:
	if attached_object.attached_entity.is_on_floor() and attached_object.is_grappled:
		# print("Hooked Object switching to pulling state")

		attached_object.attached_entity.controls_movement = true
		attached_object.is_grappled = false
	
	elif not attached_object.attached_entity.is_on_floor() and not attached_object.is_grappled:
		var dir_to_last_point : Vector2
		
		if rod_ref.wrap_points.size() > 1:
			dir_to_last_point = rod_ref.wrap_points[1].direction_to(rod_ref.wrap_points.front())
		else:
			dir_to_last_point = rod_ref.hook_end.global_position.direction_to(rod_ref.wrap_points.front())
		
		if Vector2.UP.dot(dir_to_last_point) < -0.3:
			# print("Hooked Object switching to grappling state")

			attached_object.attached_entity.controls_movement = false
			attached_object.is_grappled = true


func transition_player_to_grapple() -> void:
	if not attached_player.is_grappled:
		attached_player.is_grappled = true

		attached_player.pullback_velocity = Vector2.ZERO

		var conversion_weight = clamp(inverse_lerp(rod_ref.get_min_line_length(), 40.0, get_line_length_max_tension()) , 0.05, 0.8)

		convert_player_angular_vel(attached_player.attached_entity.player_movement.velocity * conversion_weight)


func convert_player_angular_vel(current_vel : Vector2) -> void:
	attached_player.angular_velocity = sign(current_vel.x) * (current_vel.length() / get_weighted_swing_speed())


func get_weighted_swing_speed() -> float:
	var swing_speed_weight := clamp(rod_ref.get_max_line_length() / 100.0, 0.4, 1.0)
	return rod_ref.swing_speed * swing_speed_weight


func can_player_grapple() -> bool:
	var dir_to_hook_end := rod_ref.wrap_points.back().direction_to(rod_ref.hook_end.global_position) as Vector2

	# return not attached_player.is_grappled and not attached_player.attached_entity.is_on_floor() and rod_ref.hook_end_hook_dist >= get_line_length_max_tension(true) and Vector2.UP.dot(dir_to_hook_end) < -0.3
	return not attached_player.is_grappled and not attached_player.attached_entity.is_on_floor() and attached_player.current_dist_last_point >= get_line_length_max_tension() and Vector2.UP.dot(dir_to_hook_end) < -0.3


func grapple_player(delta : float) -> void:
	# var grapple_params := RodGrappleParams.new(attached_player.angular_velocity, attached_player.previous_anglular_velocity, attached_player.angular_vel_rate_of_change, rod_ref.wrap_points.back(), rod_ref.hook_end.global_position, get_weighted_swing_speed(), rod_ref.get_movement_input(), get_line_length_max_tension(true), attached_player.current_dist_last_point)
	var grapple_params := RodGrappleParams.new(attached_player.angular_velocity, attached_player.previous_anglular_velocity, attached_player.angular_vel_rate_of_change, rod_ref.wrap_points.back(), rod_ref.hook_end.global_position, get_weighted_swing_speed(), rod_ref.get_movement_input(), get_line_length_max_tension(), current_line_length)

	# updating sprite
	attached_player.attached_entity.update_sprite(rod_ref.get_movement_input())

	attached_player.attached_entity.player_movement.set_velocity(rod_ref.get_grapple_force(grapple_params))

	if attached_player.attached_entity.player_movement.velocity.length() > rod_ref.max_swing_speed:
		attached_player.attached_entity.player_movement.set_velocity(attached_player.attached_entity.player_movement.velocity.normalized() * rod_ref.max_swing_speed)

	attached_player.angular_velocity = grapple_params.angular_vel
	attached_player.previous_anglular_velocity = grapple_params.previous_angular_vel
	attached_player.angular_vel_rate_of_change = grapple_params.angular_vel_roc

	rod_ref.update_grappling_rod_rotation(delta, attached_player.angular_vel_rate_of_change)
	
	attached_player.attached_entity.player_movement.player_move_and_slide()

	check_player_grapple_state_change()


func check_player_grapple_state_change() -> void:
	if attached_player.attached_entity.is_on_floor():
		attached_player.attached_entity.player_movement.set_snap(true)

		attached_player.attached_entity.player_movement.velocity.y = 0.0

		if attached_player.attached_entity.player_movement.velocity.length_squared() > 0.0:
			attached_player.attached_entity.state_manager.change_state(PlayerBaseState.State.WALK)

		else:
			attached_player.attached_entity.state_manager.change_state(PlayerBaseState.State.IDLE)


func grapple_object(delta : float) -> void:
	# var grapple_params := RodGrappleParams.new(attached_object.angular_velocity, attached_object.previous_anglular_velocity, attached_object.angular_vel_rate_of_change, rod_ref.wrap_points[1], rod_ref.wrap_points.front(), get_weighted_swing_speed(), Vector2.ZERO, get_line_length_max_tension(false), attached_object.current_dist_last_point) 
	# var grapple_params := RodGrappleParams.new(attached_object.angular_velocity, attached_object.previous_anglular_velocity, attached_object.angular_vel_rate_of_change, rod_ref.wrap_points[1], rod_ref.wrap_points.front(), get_weighted_swing_speed(), Vector2.ZERO, get_line_length_max_tension(false), current_line_length) 
	var grapple_params := RodGrappleParams.new(attached_object.angular_velocity, attached_object.previous_anglular_velocity, attached_object.angular_vel_rate_of_change, Vector2.ZERO, rod_ref.wrap_points.front(), get_weighted_swing_speed(), Vector2.ZERO, get_line_length_max_tension(), current_line_length) 

	if rod_ref.wrap_points.size() > 1:
		grapple_params.point_from = rod_ref.wrap_points[1]
	else:
		grapple_params.point_from = rod_ref.hook_end.global_position

	attached_object.attached_entity.object_movement.set_velocity(rod_ref.get_grapple_force(grapple_params))
	
	if attached_object.attached_entity.object_movement.velocity.length() > rod_ref.max_swing_speed:
		attached_object.attached_entity.object_movement.set_velocity(attached_object.attached_entity.object_movement.velocity.normalized() * rod_ref.max_swing_speed)

	attached_object.angular_velocity = grapple_params.angular_vel
	attached_object.previous_anglular_velocity = grapple_params.previous_angular_vel
	attached_object.angular_vel_rate_of_change = grapple_params.angular_vel_roc	

	attached_object.attached_entity.object_movement.object_move_and_slide()

	# TODO: Apply movement to object (if we add friction to hooked object movement)

	# check_object_grapple_state_change()

# !!! Do I need this, or can I just rely on the object change state method 
func check_object_grapple_state_change() -> void:
	if attached_object.attached_entity.is_on_floor():
		attached_object.attached_entity.object_movement.has_friction = true
		attached_object.is_grappled = false


func pull_player(delta : float) -> void:
	rod_ref.update_pull_rod_rotation(delta)

	# var pull_params := RodPullParams.new(attached_player.pullback_velocity, rod_ref.wrap_points.back(), rod_ref.hook_end.global_position, attached_player.pullback_force, get_line_length_max_tension(true), attached_player.current_dist_last_point)
	var pull_params := RodPullParams.new(attached_player.pullback_velocity, rod_ref.wrap_points.back(), rod_ref.hook_end.global_position, attached_player.pullback_force, get_line_length_max_tension(), current_line_length)
	
	# slope correction
	if attached_player.attached_entity.player_movement.is_on_slope():
		pull_params.rotation_ang = attached_player.attached_entity.get_floor_normal().angle()

	attached_player.pullback_velocity = rod_ref.get_pulling_force(pull_params)

	if attached_player.attached_entity.player_movement._snap_vector != Vector2.ZERO and not rod_ref.is_being_reeled():
		attached_player.pullback_velocity.y = 0.0

	attached_player.attached_entity.player_movement.add_velocity(attached_player.pullback_velocity)


func pull_object(delta : float) -> void:
	# var pull_params := RodPullParams.new(attached_object.pullback_velocity, rod_ref.wrap_points[1], rod_ref.wrap_points.front(), attached_object.pullback_force, get_line_length_max_tension(false), attached_object.current_dist_last_point)
	# var pull_params := RodPullParams.new(attached_object.pullback_velocity, Vector2.ZERO, rod_ref.wrap_points.front(), attached_object.pullback_force, get_line_length_max_tension(false), attached_object.current_dist_last_point)
	var pull_params := RodPullParams.new(attached_object.pullback_velocity, Vector2.ZERO, rod_ref.wrap_points.front(), attached_object.pullback_force, get_line_length_max_tension(), current_line_length)

	pull_params.pullback_force = 1

	if rod_ref.wrap_points.size() > 1:
		pull_params.anchor_point = rod_ref.wrap_points[1]
	else:
		pull_params.anchor_point = rod_ref.hook_end.global_position

	attached_object.pullback_velocity = rod_ref.get_pulling_force(pull_params)

	# (might need y-axis correction depending on how things to - will objects have snap_vectors/ require snapping)

	attached_object.attached_entity.object_movement.add_velocity(attached_object.pullback_velocity)


func can_reel() -> bool:
	var dir_of_rod := Vector2.RIGHT.rotated(rod_ref.pivot_point.rotation)
	var dir_to_hook := rod_ref.pivot_point.global_position.direction_to(rod_ref.wrap_points.back()) as Vector2

	var can := (current_line_length <= get_line_length_max_tension() + rod_ref.reel_tolorence) as bool

	print("can reel ----------")
	print("current length: ", current_line_length)
	print("comparison length: ", get_line_length_max_tension() + rod_ref.reel_tolorence)

	if dominant_entity == DominantEntity.OBJECT:
		can = can and dir_of_rod.dot(dir_to_hook) >= 0.7

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


	if rod_ref.wrap_lengths.size() == 1:
		rod_ref.wrap_lengths[0] = rod_ref.get_max_line_length()
	
	else: 
		if dominant_entity == DominantEntity.PLAYER:
			rod_ref.wrap_lengths[0] -= reel_amount
			# rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] += reel_amount

			if rod_ref.wrap_lengths[0] < 0.0:
				unwrap_point(false)

		else:
			rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] -= reel_amount
			# rod_ref.wrap_lengths[0] += reel_amount

			if rod_ref.wrap_lengths[rod_ref.wrap_lengths.size() - 1] < 0.0:
				unwrap_point(true)

	print("Reeling - Max Line Length: ", rod_ref.max_line_length)
	print("Lengths array: ", rod_ref.wrap_lengths)

	var length_total := 0.0
	for l in rod_ref.wrap_lengths:
		length_total += l
	print("Length array (total): ", length_total)

	print("--------------------------------")


func stop_reeling() -> void:
	if attached_player.attached_entity.state_manager.current_state != PlayerBaseState.State.FALL:
		attached_player.attached_entity.player_movement.set_snap(true)
	
	rod_ref.is_reeling = false

	rod_ref.emit_signal("rod_reeling_stopped")

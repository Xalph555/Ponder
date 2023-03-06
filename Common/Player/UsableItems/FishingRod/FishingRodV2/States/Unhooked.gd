# Rod Unhooked State
# ---------------------------------
extends BaseRodState


# Functions:
#--------------------------------------
func enter(args := {}) -> void:
	.enter(args)

	emit_signal("state_entered")


func exit() -> void:
	emit_signal("state_exited")


func update_unwrapping() -> void:
	if not is_instance_valid(rod_ref._hook_instance) or rod_ref.is_hooked:
		return
	
	if rod_ref.wrap_points.size() > 0:
		update_unwrapping_to_rod()
	
	if rod_ref.wrap_points.size() > 1:
		update_unwrapping_to_hook()


func update_wrapping() -> void:
	if not is_instance_valid(rod_ref._hook_instance) or rod_ref.is_hooked:
		return

	update_wrapping_to_rod()

	if rod_ref.wrap_points.size() > 0:
		update_wrapping_to_hook()


func update_unwrapping_to_rod() -> void:
	var hook_end_angle : float

	if rod_ref.wrap_points.size() > 1:
		hook_end_angle = rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.wrap_points.back()).angle_to(rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.hook_end.global_position)) as float
	
	else:
		hook_end_angle = rod_ref._hook_instance.global_position.direction_to(rod_ref.wrap_points.back()).angle_to(rod_ref._hook_instance.global_position.direction_to(rod_ref.hook_end.global_position)) as float

	if sign(rod_ref.wrap_angles.back()) > 0:
		if hook_end_angle < rod_ref.wrap_angles.back():
			# unwrap_point(rod_ref.wrap_points.size() - 1)
			unwrap_point(true)
	
	else:
		if hook_end_angle > rod_ref.wrap_angles.back():
			# unwrap_point(rod_ref.wrap_points.size() - 1)
			unwrap_point(true)


func update_unwrapping_to_hook() -> void:
	var hook_start_angle := rod_ref._hook_instance.global_position.direction_to(rod_ref.wrap_points.front()).angle_to(rod_ref._hook_instance.global_position.direction_to(rod_ref.wrap_points[1])) as float
		
	if sign(rod_ref.wrap_angles.front()) > 0:
		if hook_start_angle < rod_ref.wrap_angles.front():
			# unwrap_point(0)
			unwrap_point(false)
	
	else:
		if hook_start_angle > rod_ref.wrap_angles.front():
			# unwrap_point(0)
			unwrap_point(false)


# func unwrap_point(i : int) -> void:
# 	var n = rod_ref.wrap_points.size()
# 	var m = rod_ref.wrap_angles.size()

# 	if i < 0 or i > m or i > n:
# 		return
	
# 	rod_ref.wrap_points.remove(i)
# 	rod_ref.wrap_angles.remove(i)

func unwrap_point(is_rod_point : bool) -> void:
	var space_state = rod_ref.get_world_2d().direct_space_state

	if is_rod_point:
		var cast_res
		if rod_ref.wrap_points.size() > 1:
			cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points[rod_ref.wrap_points.size() - 2], [attached_player.attached_entity, rod_ref._hook_instance])
		else:
			cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points[0], [attached_player.attached_entity, rod_ref._hook_instance])

		if not cast_res:
			rod_ref.wrap_points.remove(rod_ref.wrap_points.size() - 1)

			rod_ref.wrap_angles.remove(rod_ref.wrap_points.size() - 1)
	
	else:
		var cast_res
		if rod_ref.wrap_points.size() > 1:
			cast_res = space_state.intersect_ray(rod_ref._hook_instance.global_position, rod_ref.wrap_points[1], [attached_player.attached_entity, rod_ref._hook_instance])
		else:
			cast_res = space_state.intersect_ray(rod_ref._hook_instance.global_position, rod_ref.hook_end.global_position, [attached_player.attached_entity, rod_ref._hook_instance])

		if not cast_res:
			rod_ref.wrap_points.remove(1)

			rod_ref.wrap_angles.remove(1)



func update_wrapping_to_rod() -> void:
	if rod_ref.hitbox.get_overlapping_bodies().size() != 0:
		return

	var space_state = rod_ref.get_world_2d().direct_space_state
	var cast_res : Dictionary
	
	if rod_ref.wrap_points.size() > 0:
		cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref.wrap_points.back(), [attached_player.attached_entity, rod_ref._hook_instance])
		
	else:
		cast_res = space_state.intersect_ray(rod_ref.hook_end.global_position, rod_ref._hook_instance.global_position, [attached_player.attached_entity, rod_ref._hook_instance])

	if cast_res:
		var new_point := cast_res.position as Vector2
		var offset_dir := rod_ref.get_offset_dir(cast_res.collider, new_point) as Vector2

		# # ray cast debugging
		# rod_ref.last_ray_cast_points = [new_point, new_point + (offset_dir * 20)]
		# rod_ref.ray_cast_hit_point = new_point

		if rod_ref.wrap_points.size() > 0:
			new_point = rod_ref.adjust_hit_point(new_point, offset_dir, rod_ref.wrapping_offset, rod_ref.hook_end.global_position, rod_ref.wrap_points.back(), rod_ref.offset_attemps, space_state, [attached_player.attached_entity, rod_ref._hook_instance])

		else:
			new_point = rod_ref.adjust_hit_point(new_point, offset_dir, rod_ref.wrapping_offset, rod_ref.hook_end.global_position, rod_ref._hook_instance.global_position, rod_ref.offset_attemps, space_state, [attached_player.attached_entity, rod_ref._hook_instance])

		if new_point == Vector2.INF:
			return

		rod_ref.wrap_points.append(new_point)
		
		var angle_to_add : float
		if rod_ref.wrap_points.size() > 1:
			angle_to_add = rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.wrap_points.back()).angle_to(rod_ref.wrap_points[rod_ref.wrap_points.size() - 2].direction_to(rod_ref.hook_end.global_position))
		
		else:
			angle_to_add = rod_ref._hook_instance.global_position.direction_to(rod_ref.wrap_points.back()).angle_to(rod_ref._hook_instance.global_position.direction_to(rod_ref.hook_end.global_position))

		rod_ref.wrap_angles.append(angle_to_add)


func update_wrapping_to_hook() -> void:
	var space_state = rod_ref.get_world_2d().direct_space_state
	var cast_res = space_state.intersect_ray(rod_ref._hook_instance.global_position, rod_ref.wrap_points[0], [attached_player.attached_entity, rod_ref._hook_instance])

	if cast_res:
		var new_point := cast_res.position as Vector2
		var offset_dir := rod_ref.get_offset_dir(cast_res.collider, new_point) as Vector2

		# ray cast debugging
		rod_ref.last_ray_cast_points = [new_point, new_point + (offset_dir * 20)]
		rod_ref.ray_cast_hit_point = new_point

		new_point = rod_ref.adjust_hit_point(new_point, offset_dir, rod_ref.wrapping_offset, rod_ref._hook_instance.global_position, rod_ref.wrap_points.front(), rod_ref.offset_attemps, space_state, [attached_player.attached_entity, rod_ref._hook_instance])

		if new_point == Vector2.INF:
			return

		rod_ref.wrap_points.insert(0, new_point)

		rod_ref.wrap_angles[0] = rod_ref._hook_instance.global_position.direction_to(rod_ref.wrap_points.front()).angle_to(rod_ref._hook_instance.global_position.direction_to(rod_ref.wrap_points[1]))

		var angle_to_add = rod_ref._hook_instance.global_position.direction_to(rod_ref.wrap_points.front()).angle_to(rod_ref._hook_instance.global_position.direction_to(rod_ref.wrap_points[1]))

		rod_ref.wrap_angles.insert(0, angle_to_add)

# Fishing Rod V2
# ---------------------------------
extends BaseItem
class_name FishingRod


# Signals:
#---------------------------------------
signal rod_hooked
signal rod_hook_released

signal rod_reeling
signal rod_reeling_stopped


# Variables:
#---------------------------------------
export(PackedScene) var hook_scene
var _hook_instance : FishingHook

enum State {
	UNHOOKED,
	HOOKED_SOLID,
	HOOKED_OBJECT
}

var states = {}

var current_state := State.UNHOOKED as int
var previous_state  := State.UNHOOKED as int

var wrap_points := []
var wrap_lengths := []
var wrap_angles := []

var wrapping_offset := 0.1
var offset_attemps := 80

# raycast debugging
var last_ray_cast_points := []
var ray_cast_hit_point := Vector2.ZERO

export(float) var hook_throwing_force := 800.0

var is_hooked := false
var is_grappling := false

# line length
var max_line_length : float
export(float) var line_length_slack = 5.0
export(float) var min_line_length = 5.0

# export(float) var max_tension := 1.1
export(float) var min_tension := 0.1

var hook_end_hook_dist : float

# rod rotation
export(float) var rotation_acceleration := 50.0
export(float) var rotation_limit_check := 10.0

var can_rotate_grapple := false
var previous_anglular_velocity := 0.0

export(float) var rotation_speed_transition := 0.5 #1.0
var current_rotation_transition := 0.0

# reeling
var is_reeling := false
export(float) var reel_acceleration := 250.0

export(float) var time_to_max_reel := 2.5
var current_reel_time := 0.0

export(float) var reel_tolorence := 3.0

# pullling
var pullback_force := 45.0 # this value should not change
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
onready var rod_sprite := $PivotPoint/AnimationPivot/Sprite
onready var hitbox := $PivotPoint/RodHitBox


# Functions:
#--------------------------------------
func init(new_player : Player) -> void:
	.init(new_player)

	# add states
	states[State.UNHOOKED] = $RodStates/Unhooked
	states[State.HOOKED_SOLID] = $RodStates/HookedSolid

	for state in $RodStates.get_children():
		state.set_up_state(self)

	player.state_manager.connect("state_changed", self, "_player_on_state_changed")


func destroy_rod() -> void:
	player.state_manager.disconnect("state_changed", self, "_player_on_state_changed")
	call_deferred("free")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Action1") and hitbox.get_overlapping_bodies().size() == 0:
		throw_hook()

	if event.is_action_released("Action1"):
		break_hook()

	if event.is_action_pressed("Action2") and is_hooked:
		is_reeling = true
		current_reel_time = 0.0

		emit_signal("rod_reeling")

	if event.is_action_released("Action2"):
		states[current_state].stop_reeling()


func _process(delta: float) -> void:
	update()
	update_rod_sprite()
	update_fishing_rod_rotation(delta)

	# print("Mouse Position: ", get_global_mouse_position())


func _physics_process(delta: float) -> void:
	states[current_state].update_unwrapping()
	states[current_state].update_wrapping()

	if not is_hooked:
		return

	hook_end_hook_dist = hook_end.global_position.distance_to(wrap_points.back())

	# debugging visualisation 
	# _hook_instance.col_shape.shape.radius = get_line_with_max_tension()

	if is_reeling:
		states[current_state].start_reeling(delta)

	if is_grappling:
		states[current_state].grapple_entity()
	else:
		states[current_state].pull_entity()

	# print("Is Player Snapped: ", player.player_movement.is_snapped())
	# print("Is player on floor: ", player.is_on_floor())
	
	if states[current_state].can_grapple():
		player.state_manager.change_state(PlayerBaseState.State.ITEM_OVERRIDE)


func change_state(new_state : int) -> void:
	previous_state = current_state
	current_state = new_state
	
	# include match statement for things to do when transitioning states


func _draw() -> void:
	# drawing raycast debug
	# for i in range(last_ray_cast_points.size() - 1):
	# 	draw_line(to_local(last_ray_cast_points[i]), to_local(last_ray_cast_points[i + 1]), Color.green, 1.01, true)
	
	# draw_circle(to_local(ray_cast_hit_point), 2, Color.azure)
	# last_ray_cast_points.clear()

	# drawing rope
	if not is_instance_valid(_hook_instance):
		return
		
	var line_color := Color.white

	if is_hooked:
		var color_min := Color.white
		var color_max := Color.red

		var current_line_dist := 0.0
		for i in range(wrap_lengths.size() - 1):
			current_line_dist += wrap_lengths[i]

		current_line_dist += hook_end_hook_dist

		var color_weight := clamp(inverse_lerp(max_line_length * 0.9, max_line_length, current_line_dist), 0, 1)

		line_color = color_min.linear_interpolate(color_max, color_weight)
	
	if not wrap_points.empty():
		for i in range(wrap_points.size() - 1):
			draw_line(to_local(wrap_points[i]), to_local(wrap_points[i + 1]), line_color, 1.01, true)

		draw_line(to_local(wrap_points.back()), to_local(hook_end.global_position), line_color, 1.01, true)

		if not is_hooked:
			draw_line(to_local(wrap_points.front()), to_local(_hook_instance.global_position), line_color, 1.01, true)

	else:
		draw_line(to_local(hook_end.global_position), to_local(_hook_instance.global_position), Color.white, 1.01, true)


func update_fishing_rod_rotation(delta: float) -> void:
	if is_hooked:
		# pulling rotation
		if not is_grappling:
			update_pull_rod_rotation(delta)
		
		# grappling rotation
		else:
			update_grappling_rod_rotation(delta)

	else:
		pivot_point.look_at(get_global_mouse_position())


func update_pull_rod_rotation(delta : float) -> void:
	var dir_to_mouse := (get_global_mouse_position() - self.global_position).normalized() as Vector2
	var angle_to_mouse := Vector2.RIGHT.rotated(pivot_point.rotation).angle_to(dir_to_mouse)
	var angle_weight := abs(angle_to_mouse / PI)

	var rotation_amount := sign(angle_to_mouse) * rotation_acceleration * angle_weight

	var dir_to_hook := (wrap_points.back() - self.global_position).normalized() as Vector2
	var angle_to_hook := dir_to_mouse.angle_to(dir_to_hook)

	# applying tension from pulling back rod
	if hook_end_hook_dist > max_line_length * min_tension:
		if sign(angle_to_mouse) != sign(angle_to_hook):
			var tension := (1 - clamp(inverse_lerp(states[current_state].get_line_length_min_tension(), states[current_state].get_max_line_length(), hook_end_hook_dist), 0.6, 1))
			rotation_amount *= tension

		else:
			if abs(rotation_amount) > rotation_limit_check:
				rotation_amount = 0.0

	pivot_point.rotate(rotation_amount * delta)


func update_grappling_rod_rotation(delta : float) -> void:
	if can_rotate_grapple:
		var dir_to_hook := hook_end.global_position.direction_to(wrap_points.back()) as Vector2
		var current_dir := Vector2.RIGHT.rotated(pivot_point.rotation)

		if current_dir.dot(dir_to_hook) < 0.99:
			current_rotation_transition = clamp(current_rotation_transition + delta, 0.0, rotation_speed_transition)
			var rotation_weight := lerp(0.002, 0.1, current_rotation_transition / rotation_speed_transition) as float
			pivot_point.rotation = lerp_angle(pivot_point.rotation, dir_to_hook.angle(), rotation_weight) 

			# print("Rotation Weight: ", current_rotation_transition / rotation_speed_transition)
		
		else:
			pivot_point.look_at(wrap_points.back())

	else:
		if abs(angular_vel_rate_of_change) < 0.1:
			can_rotate_grapple = true


func update_rod_sprite() -> void:
	if get_movement_input().x > 0:
		rod_sprite.scale.x = 1

	elif get_movement_input().x < 0:
		rod_sprite.scale.x = -1


func get_position_of_nearest_tile(tile_map : TileMap, pos : Vector2) -> Vector2:
	# print("===============================")
	# print("Starting Global Pos: ", pos)

	var local_pos := tile_map.to_local(pos)
	var map_pos := tile_map.world_to_map(local_pos)

	var dirs := [
				Vector2(0, 0),
				Vector2(1, 0),
				Vector2(-1, 0),
				Vector2(0, 1),
				Vector2(0, -1),
				Vector2(1, 1),
				Vector2(1, -1),
				Vector2(-1, 1),
				Vector2(-1, -1)
				]

	var adjacent_tiles := []

	# print("Map Pos: ", map_pos)

	for dir in dirs:
		var test_pos := Vector2(map_pos.x + dir.x, map_pos.y + dir.y)
		var tile_id := tile_map.get_cell(test_pos.x, test_pos.y)

		if tile_id != TileMap.INVALID_CELL and not ("slope" in tile_map.tile_set.tile_get_name(tile_id)):
			var global_pos := tile_map.to_global(tile_map.map_to_world(test_pos))
			global_pos.x += tile_map.cell_size.x / 2.0
			global_pos.y += tile_map.cell_size.y / 2.0

			adjacent_tiles.append(global_pos)
	
	var shortest_pos := adjacent_tiles[0] as Vector2
	var min_dist := shortest_pos.distance_to(pos)

	for i in range(1, adjacent_tiles.size()):
		var d := adjacent_tiles[i].distance_to(pos) as float
		
		if d < min_dist:
			shortest_pos = adjacent_tiles[i]
			min_dist = d

	# print("New Global Pos: ", shortest_pos)
	# print("===============================")

	return shortest_pos


func get_offset_dir(hit_object : Object, hit_position : Vector2) -> Vector2:
	if hit_object is TileMap:
		var nearst_tile_pos := get_position_of_nearest_tile(hit_object, hit_position)
		return nearst_tile_pos.direction_to(hit_position)

	else:
		return hit_object.global_position.direction_to(hit_position)


func adjust_hit_point(original_point : Vector2, offset_dir : Vector2, offset_amount : float, point_a : Vector2, point_b : Vector2, max_attempts : int, world_phyiscs_state : Physics2DDirectSpaceState, ignored_entities : Array) -> Vector2:
	var origin_point := original_point

	var attemps := 0
	while (world_phyiscs_state.intersect_ray(point_a, origin_point, ignored_entities) or world_phyiscs_state.intersect_ray(point_b, origin_point, ignored_entities)) and (attemps < max_attempts):
		origin_point += offset_dir * offset_amount
		attemps += 1
	
	if attemps >= max_attempts:
		print("Failed to offset point")
		return Vector2.INF
	
	return origin_point


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

	wrap_points.clear()
	wrap_lengths.clear()
	wrap_angles.clear()

	change_state(State.UNHOOKED)

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


func is_being_reeled() -> bool:
	# return can_reel() and is_reeling
	return states[current_state].can_reel() and is_reeling


# func grappling(delta : float) -> void:
# 	# TODO: there should still be some force being acted on the hooked object (maybe) - the weight of the player


func get_movement_input() -> Vector2:
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1

	return input_dir


func _on_hook_hooked() -> void:
	print("hook_hooked signal received")

	if is_hooked or not is_instance_valid(_hook_instance):
		return

	# updating rope wrapping 
	wrap_points.insert(0, _hook_instance.global_position)

	max_line_length = 0.0

	for i in range(wrap_points.size() - 1):
		var new_dist := wrap_points[i].distance_to(wrap_points[i + 1]) as float

		wrap_lengths.append(new_dist)
		max_line_length += new_dist
		
	wrap_lengths.append(hook_end.global_position.distance_to(wrap_points.back()) + line_length_slack)
	max_line_length += wrap_lengths.back()

	if wrap_points.size() > 2:
		wrap_angles[0] = _hook_instance.global_position.direction_to(wrap_points.front()).angle_to(_hook_instance.global_position.direction_to(wrap_points[1]))

	elif wrap_points.size() > 1:
		wrap_angles[0] = _hook_instance.global_position.direction_to(wrap_points.front()).angle_to(_hook_instance.global_position.direction_to(hook_end.global_position))

	wrap_angles.insert(0, 0)


	is_hooked = true

	pullback_velocity = Vector2.ZERO
	is_grappling = false

	change_state(State.HOOKED_SOLID)

	# transtion player state
	if player.state_manager.current_state == PlayerBaseState.State.FALL:
		var dir_to_hook := wrap_points.back().direction_to(hook_end.global_position) as Vector2

		if Vector2.UP.dot(dir_to_hook) < -0.3:
			player.state_manager.change_state(PlayerBaseState.State.ITEM_OVERRIDE)

			print("Fishing Rod now grappling")
	
	elif player.state_manager.current_state != PlayerBaseState.State.ITEM_OVERRIDE:
		is_grappling = false
		print("Fishing Rod now pulling")

	emit_signal("rod_hooked")
	

func _player_on_state_changed(new_state : int) -> void:
	if not is_hooked:
		return

	if new_state == PlayerBaseState.State.ITEM_OVERRIDE:
		states[current_state].transition_to_grapple()
			
	else:
		if is_grappling:
			is_grappling = false
			# print("Fishing Rod now pulling")

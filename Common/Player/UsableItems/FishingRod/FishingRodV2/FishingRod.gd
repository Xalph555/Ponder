# Fishing Rod V2
# ---------------------------------
extends BaseItem
class_name FishingRod


# Variables:
#---------------------------------------
export(PackedScene) var hook_scene

var _hook_instance : FishingHook

export(float) var hook_throwing_force := 800.0

var is_hooked := false
var max_line_length : float

export(float) var min_line_length = 2.0
export(float) var reel_acceleration := 500.0

export(float) var time_to_max_reel := 2.5
var current_reel_time := 0.0

var is_reeling := false

export(float) var max_tension := 1.1
export(float) var min_tension := 0.5

export(float) var pull_acceleration := 50.0

export(float) var rotation_limit_check := 10.0

var hook_end_hook_dist : float

onready var pivot_point := $PivotPoint
onready var hook_end := $PivotPoint/AnimationPivot/HookPoint


# Functions:
#--------------------------------------
func init(new_player: Player) -> void:
	.init(new_player)
	set_active_item(false)


func set_active_item(is_active : bool) -> void:
	.set_active_item(is_active)

	set_process_unhandled_input(is_active)
	set_process(is_active)

	break_hook()
	self.visible = is_active


func destroy_rod() -> void:
	call_deferred("free")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Action1"):
		throw_hook()
	if event.is_action_released("Action1"):
		break_hook()

	if event.is_action_pressed("Action2"):
		is_reeling = true
		current_reel_time = 0.0

	if event.is_action_released("Action2"):
		is_reeling = false


func _process(delta: float) -> void:
	update()
	update_fishing_rod_rotation(delta)


func _physics_process(delta: float) -> void:

	if is_reeling:
		reel_line(delta)
		print("Max Line Length: ", max_line_length)

	var pull_back_force := 10.0

	if is_hooked:
		hook_end_hook_dist = hook_end.global_position.distance_to(_hook_instance.global_position)

		if hook_end_hook_dist >= max_line_length:
			var dir_to_hook := (_hook_instance.global_position - hook_end.global_position).normalized() as Vector2 
			var force_multiplier := inverse_lerp(max_line_length, max_line_length * max_tension, hook_end_hook_dist)

			var force_back := (dir_to_hook * pull_back_force * force_multiplier) as Vector2

			# print("Force Back: ", force_back)

			player.player_movement.add_velocity(force_back)


func _draw() -> void:
	if _hook_instance:
		draw_line(to_local(hook_end.global_position), to_local(_hook_instance.global_position), Color.white, 1.01, true)


func update_fishing_rod_rotation(delta: float) -> void:
	if is_hooked:
		var dir_to_mouse := (get_global_mouse_position() - self.global_position).normalized() as Vector2
		var angle_to_mouse := Vector2.RIGHT.rotated(pivot_point.rotation).angle_to(dir_to_mouse)
		var angle_weight := abs(angle_to_mouse / PI)

		var rotation_amount := sign(angle_to_mouse) * pull_acceleration * angle_weight

		var dir_to_hook := (_hook_instance.global_position - self.global_position).normalized() as Vector2
		var angle_to_hook := dir_to_mouse.angle_to(dir_to_hook)

		# applying tension from pulling back rod
		if hook_end_hook_dist > max_line_length * min_tension:
			if sign(angle_to_mouse) != sign(angle_to_hook):
				var tension := (1 - clamp(inverse_lerp(max_line_length * min_tension, max_line_length * max_tension, hook_end_hook_dist), 0.6, 1))
				rotation_amount *= tension

			else:
				if abs(rotation_amount) > rotation_limit_check:
					rotation_amount = 0.0

		pivot_point.rotate(rotation_amount * delta)

	else:
		pivot_point.look_at(get_global_mouse_position())


func throw_hook() -> void:
	if is_instance_valid(_hook_instance) || is_hooked:
		return

	var throw_dir := (get_global_mouse_position() - hook_end.global_position).normalized() as Vector2

	var _hook = hook_scene.instance() as FishingHook
	_hook_instance = _hook
	
	_hook_instance.connect("hook_hooked", self, "_on_hook_hooked")
	get_tree().get_root().add_child(_hook_instance)

	_hook_instance.throw_hook(hook_end.global_position, throw_dir, hook_throwing_force)

	print("Hook Thrown")


func break_hook() -> void:
	if not is_instance_valid(_hook_instance):
		return

	_hook_instance.disconnect("hook_hooked", self, "_on_hook_hooked")

	#? probably need to transfer velocity back to the player once we let them go
	
	_hook_instance.call_deferred("free")
	yield(_hook_instance, "tree_exited")
	_hook_instance = null

	is_hooked = false

	print("Hook Broken")


func reel_line(delta : float) -> void:
	current_reel_time += delta

	var accel_multiplier := clamp(inverse_lerp(0, time_to_max_reel, current_reel_time), 0.2, 1)
	var reel_amount := reel_acceleration * accel_multiplier * delta 

	max_line_length = clamp(max_line_length - reel_amount, min_line_length, max_line_length)


func _on_hook_hooked() -> void:
	print("hook_hooked signal received")

	if is_hooked or not is_instance_valid(_hook_instance):
		return
	
	is_hooked = true
	max_line_length = hook_end.global_position.distance_to(_hook_instance.global_position)

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


func _process(delta: float) -> void:
	update()
	update_fishing_rod_rotation(delta)


func _physics_process(delta: float) -> void:
	pass


func _draw() -> void:
	if _hook_instance:
		draw_line(to_local(hook_end.global_position), to_local(_hook_instance.global_position), Color.white, 1.01, true)


func update_fishing_rod_rotation(delta: float) -> void:
	var max_tension := 1.1
	var min_tension := 0.5

	var pull_acceleration := 50.0

	if is_hooked:		
		var hook_end_hook_dist := hook_end.global_position.distance_to(_hook_instance.global_position) as float

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
				if abs(rotation_amount) > 10.0:
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


func _on_hook_hooked() -> void:
	print("hook_hooked signal received")

	if is_hooked or not is_instance_valid(_hook_instance):
		return
	
	is_hooked = true
	max_line_length = hook_end.global_position.distance_to(_hook_instance.global_position)


#--------------------------------------#
# Ring Item Script                     #
#--------------------------------------#
extends BaseItem
class_name RingItem


# Variables:
#---------------------------------------
export(PackedScene) var ring_object

export(Vector2) var position_offset := Vector2(0, -5)

export(float) var terminal_speed := 4500.0

export(float) var vertical_acceleration := 150.0
export(float) var vertical_max_speed := 2000.0

export(float) var horizontal_acceleration := 5.0
export(float) var horizontal_max_speed := 150.0

export(float) var limit_max_transition := 0.1

export(float) var in_air_friction_x := 0.2
export(float) var in_air_friction_y := 0.2

export(float) var base_damage := 0.08
export(float) var damage_velocity_threshold := 400.0

var _ring_instance : RingObject


# Functions:
#--------------------------------------
func init(new_player: Player) -> void:
	.init(new_player)
	set_active_item(false)


func set_active_item(is_active : bool) -> void:
	.set_active_item(is_active)

	set_process_unhandled_input(is_active)

	if not is_active:
		destroy_ring()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Action1"):
		spawn_ring()
	
	if event.is_action_released("Action1"):
		destroy_ring()


func spawn_ring() -> void:
	if player:
		_ring_instance = ring_object.instance()
		
		get_tree().get_root().add_child(_ring_instance)
		
		_ring_instance.set_up_ring(player, player.player_movement.velocity, player.global_position, position_offset, terminal_speed, vertical_acceleration, vertical_max_speed, horizontal_acceleration, horizontal_max_speed, limit_max_transition, in_air_friction_x, in_air_friction_y, base_damage, damage_velocity_threshold)
	

func destroy_ring() -> void:
	if is_instance_valid(_ring_instance):
		_ring_instance.call_deferred("free")
		yield(_ring_instance, "tree_exited")
		_ring_instance = null


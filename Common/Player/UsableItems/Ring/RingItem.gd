#--------------------------------------#
# Ring Item Script                     #
#--------------------------------------#
extends BaseItem
class_name RingItem


# Variables:
#---------------------------------------
export(PackedScene) var ring_object
export(Vector2) var position_offset := Vector2(0, -5)

export(float) var max_vertical_speed := 1000.0
export(float) var vertical_accel := 30.0

export(float) var max_horizontal_speed := 80.0
export(float) var horizontal_accel := 10.0

export(float) var base_damage := 0.08

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
		player.player_handles_movement = false
		
		_ring_instance = ring_object.instance()
		
		get_tree().get_root().add_child(_ring_instance)
		
		_ring_instance.set_up_ring(player, player.velocity, player.global_position, position_offset)

		_ring_instance.set_ring_properties(max_vertical_speed, vertical_accel, max_horizontal_speed, horizontal_accel, base_damage)


func destroy_ring() -> void:
	if _ring_instance:
		player.player_handles_movement = true
		player.velocity = _ring_instance.velocity
		
		_ring_instance.call_deferred("free")
		_ring_instance = null


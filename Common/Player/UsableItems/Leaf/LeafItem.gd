#--------------------------------------#
# Leaf Item Script                     #
#--------------------------------------#
extends BaseItem
class_name LeafItem


# Variables:
#---------------------------------------
export(PackedScene) var leaf_object
export(Vector2) var placement_offset = Vector2(0, -20.0)

export(float) var gravity := 60.0

export(float) var acceleration := 5.0
export(float) var max_speed := 180.0

export(float) var in_air_friction_x := 0.009
export(float) var in_air_friction_y := 0.035

export(float) var wind_force_multiplier := 4.0

var _leaf_instance : LeafObject


# Functions:
#--------------------------------------
func init(new_player: Player) -> void:
	.init(new_player)
	set_active_item(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Action1"):
		spawn_leaf()
	
	if event.is_action_released("Action1"):
		destroy_leaf()


func set_active_item(is_active : bool) -> void:
	.set_active_item(is_active)

	set_process_unhandled_input(is_active)

	if not is_active:
		destroy_leaf()


func spawn_leaf() -> void:
	if player:
		_leaf_instance = leaf_object.instance()
		
		add_child(_leaf_instance)
		
		_leaf_instance.set_up_leaf(player, player.velocity, player.global_position + placement_offset)
		
		_leaf_instance.set_leaf_properties(gravity, acceleration, max_speed, in_air_friction_x, in_air_friction_y, wind_force_multiplier)


func destroy_leaf() -> void:
	if _leaf_instance:		
		player.velocity = _leaf_instance.velocity

		_leaf_instance.call_deferred("free")
		_leaf_instance = null

		player.player_handles_movement = true
		# player.player_can_set_snap = true

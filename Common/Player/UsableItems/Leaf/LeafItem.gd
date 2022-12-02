#--------------------------------------#
# Leaf Item Script                     #
#--------------------------------------#
extends BaseItem
class_name LeafItem


# Variables:
#---------------------------------------
export(PackedScene) var leaf_object

export(Vector2) var placement_offset = Vector2(0, -20.0)

export(float) var gravity := 100.0

export(float) var terminal_speed := 4500.0
export(float) var acceleration := 5.0
export(float) var max_speed := 200.0
export(float) var limit_max_transition := 0.1

export(float) var up_draft_threshhold := 260.0
export(float) var up_draft_force := 300.0

export(float) var in_air_friction_x := 0.009
export(float) var in_air_friction_y := 0.035

export(float) var wind_force_multiplier := 4.0

var _leaf_instance : LeafObject


# Functions:
#--------------------------------------
func init(new_player: Player) -> void:
	.init(new_player)
	set_active_item(false)


func set_active_item(is_active : bool) -> void:
	.set_active_item(is_active)

	set_process_unhandled_input(is_active)

	if not is_active:
		destroy_leaf()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Action1"):
		spawn_leaf()
	
	if event.is_action_released("Action1"):
		destroy_leaf()


func spawn_leaf() -> void:
	if player:
		_leaf_instance = leaf_object.instance()
		
		add_child(_leaf_instance)
		
		_leaf_instance.set_up_leaf(player, player.global_position + placement_offset, \
		gravity, terminal_speed, acceleration, max_speed, limit_max_transition, up_draft_threshhold, \
		up_draft_force, in_air_friction_x, in_air_friction_y, wind_force_multiplier)


func destroy_leaf() -> void:
	if is_instance_valid(_leaf_instance):
		_leaf_instance.call_deferred("free")
		yield(_leaf_instance, "tree_exited")
		_leaf_instance = null


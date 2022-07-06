#--------------------------------------#
# Leaf Item Script                     #
#--------------------------------------#
extends Node2D

class_name LeafItem


# Variables:
#---------------------------------------
export(PackedScene) var leaf_object
export(Vector2) var placement_offset = Vector2(0, -20.0)

var _leaf_instance : LeafObject

onready var parent = get_parent().get_parent() as Player


# Functions:
#--------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Action1"):
		spawn_leaf()
	
	if event.is_action_released("Action1"):
		destroy_leaf()


func spawn_leaf() -> void:
	if parent:
		_leaf_instance = leaf_object.instance()
		
		add_child(_leaf_instance)
		
		_leaf_instance.set_up_leaf(parent, parent.velocity, parent.global_position + placement_offset)


func destroy_leaf() -> void:
	if _leaf_instance:
		parent.player_handles_movement = true
		parent.velocity = _leaf_instance.velocity

		_leaf_instance.call_deferred("free")

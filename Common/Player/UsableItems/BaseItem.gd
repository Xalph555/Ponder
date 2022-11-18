# Base Item
# --------------------------------------------
extends Node2D
class_name BaseItem


# Variables:
#---------------------------------------
var player: Player


# Functions:
#---------------------------------------
func init(new_player: Player) -> void:
	player = new_player


func set_active_item(is_active : bool) -> void:
	pass
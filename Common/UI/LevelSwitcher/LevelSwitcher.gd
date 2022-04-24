#--------------------------------------#
# Level Switcher Script                #
#--------------------------------------#

extends Control
class_name LevelSwitcher


# Variables:
#---------------------------------------
export (PackedScene) var level_button
export (Dictionary) var levels

onready var buttons_container := $VBoxContainer/Buttons


# Functions:
#---------------------------------------
func _ready() -> void:
	yield(get_tree(), "idle_frame")
	
	for i in levels.keys():
		var new_button = level_button.instance()
		
		new_button.level_name = i
		new_button.text = i
	
		new_button.connect("level_button_pressed", self, "on_level_button_pressed")
		buttons_container.add_child(new_button)


func on_level_button_pressed(level_name: String):
#	get_tree().change_scene(levels[level_name])
	get_tree().call_deferred("change_scene", levels[level_name])

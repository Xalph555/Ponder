#--------------------------------------#
# Level Switcher Script                #
#--------------------------------------#

extends Control
class_name LevelSwitcher


# Variables:
#---------------------------------------
export (PackedScene) var level_button
export (Array, Dictionary) var levels

onready var buttons_container := $VBoxContainer/Buttons


# Functions:
#---------------------------------------
func _ready() -> void:
	yield(get_tree(), "idle_frame")
	
	for i in range(len(levels)):
		var new_button = level_button.instance()
	
		new_button.level_index = i
		new_button.level_name = levels[i].keys()[0]
		
		new_button.text = new_button.level_name
	
		new_button.connect("level_button_pressed", self, "on_level_button_pressed")
		buttons_container.add_child(new_button)


func on_level_button_pressed(level_index: int, level_name: String):
	get_tree().change_scene(levels[level_index][level_name])

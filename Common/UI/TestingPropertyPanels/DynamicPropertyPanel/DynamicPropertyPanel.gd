#--------------------------------------#
# DynamicPropertyPanel Script          #
#--------------------------------------#
extends Control
class_name DynamicPropertyPanel


# Variables:
#---------------------------------------
export(PackedScene) var property_setter

export(NodePath) var target_path
var _target_node

export(Dictionary) var adjustable_vars

onready var property_container := $PanelContainer/VBoxContainer/PropertySetters

onready var _anim_player := $AnimationPlayer


# Functions:
#---------------------------------------
func _ready() -> void:
	_target_node = get_node(target_path)

	# create property containers
	for display_name in adjustable_vars:
		var property_setter_instance = property_setter.instance() as PropertySetterNumeric

		property_container.add_child(property_setter_instance)

		property_setter_instance.set_up_ui(_target_node, display_name, adjustable_vars[display_name])


func save_temp_stats() -> void:
	pass


func _on_ExportButton_button_up() -> void:
	_anim_player.play("ExportedChanges")

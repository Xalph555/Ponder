#--------------------------------------#
# Property Setter Numeric Script       #
#--------------------------------------#

extends HBoxContainer
class_name PropertySetterNumeric


# Signals
#---------------------------------------
signal value_changed(new_value)
signal valid_change
signal invalid_change


# Variables:
#---------------------------------------
var _target_node

var display_name := ""
var target_setting := ""
var current_setting := 0.00

onready var _settings_title := $SettingTitle
onready var _spin_box := $SpinBox


# Functions:
#---------------------------------------
func _ready() -> void:
	_spin_box.get_line_edit().connect("text_entered", self, "_on_spin_box_text_entered")


func set_up_ui(t_node, dis_name : String, var_name : String) -> void:
	_target_node = t_node

	display_name = dis_name
	_settings_title.text = display_name
	target_setting = var_name

	current_setting = _target_node.get(target_setting)
	_spin_box.value = current_setting


func update_target_setting(value : float) -> void:
	current_setting = value

	_spin_box.value = value


func _on_spin_box_text_entered(_new_text: String) -> void:
	_spin_box.get_line_edit().release_focus()


func _on_SpinBox_value_changed(value : float) -> void:
	# update_target_setting(value)

	current_setting = value

	_target_node.set(target_setting, current_setting)
	emit_signal("value_changed", current_setting)

	_spin_box.get_line_edit().release_focus()

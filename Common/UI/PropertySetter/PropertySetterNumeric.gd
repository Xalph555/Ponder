#--------------------------------------#
# Property Setter Numeric Script       #
#--------------------------------------#

extends HBoxContainer
class_name PropertySetterNumeric


# Signals
#---------------------------------------
signal value_changed(value)
signal valid_change
signal invalid_change


# Variables:
#---------------------------------------
export(NodePath) var target_path
var _target_node

export(String) var target_setting
var current_setting := 0.00

onready var _line_edit = $LineEdit


# Functions:
#---------------------------------------
func _ready() -> void:
	_target_node = get_node(target_path)
	current_setting = _target_node.get(target_setting)
	
	_line_edit.text = str(current_setting)


func _on_LineEdit_text_entered(new_text: String) -> void:
	if new_text.is_valid_float() or new_text.is_valid_integer():
		current_setting = max(0.01, float(new_text))
		_line_edit.text = str(current_setting)
		
		_target_node.set(target_setting, float(current_setting))
		
		emit_signal("valid_change")
		emit_signal("value_changed", current_setting)
	
	else:
		_line_edit.text = str(current_setting)
		emit_signal("invalid_change")
	
	_line_edit.release_focus()


func _on_Confirm_button_up() -> void:
	if _line_edit.text.is_valid_float() or _line_edit.text.is_valid_integer():
		current_setting = max(0.01, float(_line_edit.text))
		_line_edit.text = str(current_setting)
		
		_target_node.set(target_setting, float(current_setting))
		
		emit_signal("valid_change")
		emit_signal("value_changed", current_setting)
	
	else:
		_line_edit.text = str(current_setting)
		emit_signal("invalid_change")
	
	_line_edit.release_focus()

extends Button


signal level_button_pressed(l_name)

var level_name := ""


func _on_button_up() -> void:
	emit_signal("level_button_pressed", level_name)

extends Button


signal level_button_pressed(index, name)

var level_index := 0
var level_name := ""


func _on_button_up() -> void:
	emit_signal("level_button_pressed", level_index, level_name)

extends Control

onready var _settings := $Settings


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ToggleSettings"):
		_settings.visible = !_settings.visible
	
	if event.is_action_pressed("ResetLevel"):
		get_tree().reload_current_scene()


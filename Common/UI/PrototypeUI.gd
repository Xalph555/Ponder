extends Control

onready var _settings := $Settings


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ToggleSettings"):
		_settings.visible = !_settings.visible
	
	if event.is_action_pressed("ResetLevel"):
		GlobalData.is_game_first_load = false
		
		get_tree().reload_current_scene()


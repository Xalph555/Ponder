extends Control

onready var _anim_player := $AnimationPlayer
onready var _property_containers := $PropertySetters/VBoxContainer


func _on_invalid_change() -> void:
	_anim_player.play("InvalidChange")


func _on_valid_change() -> void:
	_anim_player.play("ValidChange")


func _on_ExportButton_button_up() -> void:
	var text_file = File.new()
	
	var export_count = 0
	var file_name = "PhysicsRodSettings{id}"
	
	while text_file.file_exists("user://%s.txt" % file_name.format({"id": str(export_count)})):
		export_count += 1
	
	file_name = file_name.format({"id": str(export_count)})
	text_file.open("user://%s.txt" % file_name, File.WRITE)
	
	text_file.store_line("Physics Rod Settings:")
	
	for i in _property_containers.get_children():
		var property_setting = str(i.target_setting) + ": " + str(i.current_setting)
		text_file.store_line(property_setting)
	
	text_file.close()

#--------------------------------------#
# DynamicPropertyPanel Script          #
#--------------------------------------#
extends Control
class_name DynamicPropertyPanel


# Variables:
#---------------------------------------
export(String) var setter_title
export(PackedScene) var property_setter

var save_wrapper
var _target_node

export(Resource) var settings_resource

onready var setting_title := $PanelContainer/VBoxContainer/SettingsTitle
onready var property_container := $PanelContainer/VBoxContainer/PropertySetters

onready var _anim_player := $AnimationPlayer

onready var _file_dialog := $FileDialog


# Functions:
#---------------------------------------
func set_up_ui(target_node) -> void:
	print("Dynamic setter ready")
	setting_title.text = setter_title

	_target_node = target_node

	# create property containers
	settings_resource.resource_local_to_scene = true
	var properties = settings_resource.get_script().get_script_property_list()

	for property in properties:
		var property_setter_instance = property_setter.instance() as PropertySetterNumeric

		property_container.add_child(property_setter_instance)

		property_setter_instance.set_up_ui(_target_node, property["name"], property["name"])

		property_setter_instance.connect("value_changed", self, "_on_value_changed")

	# set up the save wrapper
	save_wrapper = DefaultSaveWrapper.new()
	save_wrapper.set_up_wrapper(setter_title, settings_resource)

	if GlobalData.is_game_first_load:
		save_wrapper.write_temp_save()

	else:
		load_temp_stats()


func load_default_stats() -> void:
	var default_save = save_wrapper.load_default_save().settings_resource

	for p_setter in property_container.get_children(): 
		p_setter.update_target_setting(default_save.get(p_setter.target_setting))


func save_temp_stats() -> void:
	for p_setter in property_container.get_children():
		save_wrapper.settings_resource.set(p_setter.target_setting, p_setter.current_setting)

	save_wrapper.write_temp_save()
	

func load_temp_stats() -> void:
	var temp_save = save_wrapper.load_temp_save().settings_resource

	for p_setter in property_container.get_children(): 
		p_setter.update_target_setting(temp_save.get(p_setter.target_setting))


func _on_value_changed(_new_value : float) -> void:
	save_temp_stats()


func _on_ExportButton_button_up() -> void:
	_file_dialog.popup_centered()


func _on_FileDialog_dir_selected(dir:String) -> void:
	var text_file = File.new()
	
	var file_name = setter_title
	
	text_file.open(dir + "/%s.txt" % file_name, File.WRITE)
	
	text_file.store_line(setter_title)
	
	for i in property_container.get_children():
		var property_setting = str(i.display_name) + ": " + str(i.current_setting)
		text_file.store_line(property_setting)
	
	text_file.close()

	_anim_player.play("ExportedChanges")


func _on_ResetButton_button_up() -> void:
	load_default_stats()

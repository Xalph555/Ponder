#--------------------------------------#
# DefaultSaveWrapper Script            #
#--------------------------------------#
extends Resource
class_name DefaultSaveWrapper


# Variables:
#---------------------------------------
const SAVE_BASE_PATH := "user://save_"

var _settings_name := ""
export var settings_resource : Resource

var _default_val_save_path := ""
var _temp_val_save_path := ""


# Functions:
#---------------------------------------
func set_up_wrapper(settings_name : String, settings_res : Resource) -> void:
	_settings_name = settings_name
	settings_resource = settings_res

	var extension := ".tres" if OS.is_debug_build() else ".res"

	_default_val_save_path = SAVE_BASE_PATH + settings_name + extension
	_temp_val_save_path = SAVE_BASE_PATH + settings_name + "_temp" + extension

	write_default_save()


func write_default_save() -> void:
	ResourceSaver.save(_default_val_save_path, self)


func write_temp_save() -> void:
	ResourceSaver.save(_temp_val_save_path, self)


func load_default_save() -> Resource:
	return ResourceLoader.load(_default_val_save_path, "", true) 


func load_temp_save() -> Resource:
	return ResourceLoader.load(_temp_val_save_path, "", true) 
#--------------------------------------#
# Aug2022 Property setup Script        #
#--------------------------------------#
extends Control


# Variables:
#---------------------------------------
export(NodePath) onready var player_ref = get_node(player_ref) as Player

export(NodePath) onready var player_settings = get_node(player_settings) as DynamicPropertyPanel
export(NodePath) onready var fishing_rod_settings = get_node(fishing_rod_settings) as DynamicPropertyPanel
export(NodePath) onready var leaf_settings = get_node(leaf_settings) as DynamicPropertyPanel
export(NodePath) onready var ring_settings = get_node(ring_settings) as DynamicPropertyPanel

onready var _settings := $Settings


# Functions:
#---------------------------------------
func _ready() -> void:
	# player_ref.connect("items_ready", self, "_on_items_ready")

	if not player_ref.is_inside_tree():
		yield(player_ref, "ready")
	
	player_ref.connect("item_switched", self, "_on_item_switched")

	set_up_ui()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ToggleSettings"):
		_settings.visible = !_settings.visible
	
	if event.is_action_pressed("ResetLevel"):
		GlobalData.is_game_first_load = false
		
		get_tree().reload_current_scene()


func set_up_ui() -> void:
	player_settings.set_up_ui(player_ref)

	var items = player_ref.items

	fishing_rod_settings.set_up_ui(items[0])
	leaf_settings.set_up_ui(items[1])
	ring_settings.set_up_ui(items[2])

	fishing_rod_settings.visible = true
	leaf_settings.visible = false
	ring_settings.visible = false


func _on_item_switched(current_item : int) -> void:
	match current_item:
		0:
			fishing_rod_settings.visible = true
			leaf_settings.visible = false
			ring_settings.visible = false

		1:
			fishing_rod_settings.visible = false
			leaf_settings.visible = true
			ring_settings.visible = false

		2:
			fishing_rod_settings.visible = false
			leaf_settings.visible = false
			ring_settings.visible = true


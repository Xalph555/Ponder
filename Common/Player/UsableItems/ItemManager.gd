# Item Manager
# --------------------------
extends Node2D
class_name ItemManager


# Variables:
#---------------------------------------
export(Array, PackedScene) var default_items

var items := []
var current_item := 0

var player : Player


# Functions:
#---------------------------------------
func init(new_player: Player) -> void:
	player = new_player

	set_up_default_items()


func input(event: InputEvent) -> void:
	if event.is_action_pressed("Selection1"):
		switch_item(0)
	
	if event.is_action_pressed("Selection2"):
		switch_item(1)

	if event.is_action_pressed("Selection3"):
		switch_item(2)
	
	if event.is_action_pressed("Selection4"):
		switch_item(3)

	if event.is_action_pressed("CycleLeft"):
		switch_item(((current_item - 1) + items.size()) % items.size())
	
	if event.is_action_pressed("CycleRight"):
		switch_item((current_item + 1) % items.size())


func set_up_default_items() -> void:
	for default_item in default_items:
		add_item(default_item)  
	
	current_item = 0
	items[current_item].set_active_item(true)


func add_item(item : PackedScene) -> void:
	var item_instance = item.instance()
	add_child(item_instance)

	items.append(item_instance)

	item_instance.init(player)


func remove_item(item_num : int) -> void:
	if item_num < 0 or item_num >= items.size():
		return
	
	if item_num == current_item:
		items[current_item].set_active_item(false)

	items[item_num].call_deferred("free")
	items.remove(item_num)

	if item_num == current_item:
		if current_item != 0:
			current_item = items.size() - 1
		
		items[current_item].set_active_item(true)

	elif item_num < current_item and current_item != 0:
		current_item = items.size() - 1
		
	
func switch_item(item_num : int) -> void:
	if item_num == current_item or item_num < 0 or item_num >= items.size():
		return

	items[current_item].set_active_item(false)

	items[item_num].set_active_item(true)
	current_item = item_num
	
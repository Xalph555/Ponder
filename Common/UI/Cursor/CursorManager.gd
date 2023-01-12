# Cursor Manager
# ---------------------------------
extends Control


# Variables:
#---------------------------------------
enum State {
	READY1,
	READY2,
	READY3,
	HOOKED,
	REELING
}

export(NodePath) onready var player_ref = get_node(player_ref) as Player

export(Texture) var cursor_ready1 = null
export(Texture) var cursor_ready2 = null
export(Texture) var cursor_ready3 = null

export(Texture) var cursor_hooked = null
export(Texture) var cursor_reeling = null

var base_window_size := Vector2.ZERO
var base_cursor_size := Vector2.ZERO
var cursor_scale := 1.0

# var player : Player
var fishing_rod : FishingRod

var is_hooked := false

var current_state :int = State.READY1


# Functions:
#--------------------------------------
func _ready() -> void:
	set_process(false)
	yield(get_tree(), "idle_frame")
	init(player_ref)


func init(new_player : Player) -> void:
	# player = new_player 
	fishing_rod = player_ref.fishing_rod

	base_window_size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
	base_cursor_size = cursor_ready1.get_size()

	get_tree().connect("screen_resized", self, "_on_screen_resize")

	fishing_rod.connect("rod_hooked", self, "_on_rod_hooked")
	fishing_rod.connect("rod_hook_released", self, "_on_rod_hook_released")

	fishing_rod.connect("rod_reeling", self, "_on_rod_reeling")
	fishing_rod.connect("rod_reeling_stopped", self, "_on_rod_reeling_stopped")

	set_process(true)

	_on_screen_resize()


func _process(delta: float) -> void:
	if current_state == State.HOOKED or current_state == State.REELING:
		return
		
	var throw_distance := clamp(fishing_rod.hook_end.global_position.distance_to(get_global_mouse_position()) / 80.0, 0.0, 1.0)

	# print("Cursor throw dist: ", throw_distance)
	# print("Hook end to mouse: ", fishing_rod.hook_end.global_position.distance_to(get_global_mouse_position()))

	# print("Mouse Position: ", get_global_mouse_position())

	if throw_distance <= 0.3:
		if current_state != State.READY1:
			current_state = State.READY1
			set_cursor_icon()

	elif throw_distance > 0.3 and throw_distance <= 0.9:
		if current_state != State.READY2:
			current_state = State.READY2
			set_cursor_icon()
	
	else:
		if current_state != State.READY3:
			current_state = State.READY3
			set_cursor_icon()


func set_cursor_icon() -> void:
	var texture = ImageTexture.new()
	var image : Image

	match current_state:
		State.READY1:
			image = cursor_ready1.get_data()
			
		State.READY2:
			image = cursor_ready2.get_data()
		
		State.READY3:
			image = cursor_ready3.get_data()
		
		State.HOOKED:
			image = cursor_hooked.get_data()
		
		State.REELING:
			image = cursor_reeling.get_data()
	
	image.resize(base_cursor_size.x * cursor_scale, base_cursor_size.y * cursor_scale, Image.INTERPOLATE_NEAREST)
	texture.create_from_image(image)

	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW)


func _on_screen_resize() -> void:
	var current_window_size = OS.window_size
	cursor_scale = min(current_window_size.x / base_window_size.x, current_window_size.y / base_window_size.y)

	print("Current Window Size: ", current_window_size)
	print("Scale X: ", floor(current_window_size.x / base_window_size.x))
	print("Scale Y: ", floor(current_window_size.y / base_window_size.y))

	set_cursor_icon()


func _on_rod_hooked() -> void:
	current_state = State.HOOKED
	is_hooked = true
	set_cursor_icon()


func _on_rod_hook_released() -> void:
	current_state = State.READY1
	is_hooked = false
	set_cursor_icon()


func _on_rod_reeling() -> void:
	current_state = State.REELING
	set_cursor_icon()


func _on_rod_reeling_stopped() -> void:
	if is_hooked:
		current_state = State.HOOKED
	else:
		current_state = State.READY1
		
	set_cursor_icon()
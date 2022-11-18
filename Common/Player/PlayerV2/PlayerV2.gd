# Player V2
# ---------------------------------
extends KinematicBody2D
class_name Player


# Variables:
#---------------------------------------
onready var player_movement := $PlayerMovement
onready var state_manager := $PlayerStateMachine
onready var item_manager := $ItemManager

onready var _sprite := $Sprite


# Functions:
#---------------------------------------
func _ready() -> void:
	state_manager.init(self)
	player_movement.init(self)


func _unhandled_input(event: InputEvent) -> void:
	state_manager.input(event)
	item_manager.input(event)


func _process(delta: float) -> void:
	state_manager.process(delta)


func _physics_process(delta: float) -> void:
	state_manager.physics_process(delta)


func update_sprite (facing_dir: Vector2) -> void:
	if facing_dir.x > 0:
		_sprite.scale.x = 1
		# item_manager.scale.x = 1
		
	elif facing_dir.x < 0:
		_sprite.scale.x = -1
		# item_manager.scale.x = -1
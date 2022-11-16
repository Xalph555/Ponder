# Player V2
# ---------------------------------
extends KinematicBody2D
class_name PlayerV2


# Variables:
#---------------------------------------
onready var state_manager := $PlayerStateMachine
onready var player_movement := $PlayerMovement

onready var _sprite := $Sprite

# Functions:
#---------------------------------------
func _ready() -> void:
	state_manager.init(self)
	player_movement.init(self)


func _unhandled_input(event: InputEvent) -> void:
	state_manager.input(event)


func _process(delta: float) -> void:
	state_manager.process(delta)


func _physics_process(delta: float) -> void:
	state_manager.physics_process(delta)


func update_sprite (facing_dir: Vector2) -> void:
	if facing_dir.x > 0:
		_sprite.scale.x = 1
		# $ActiveTool.scale.x = 1
		
	elif facing_dir.x < 0:
		_sprite.scale.x = -1
		# $ActiveTool.scale.x = -1
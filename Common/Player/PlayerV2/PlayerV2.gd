# Player V2
# ---------------------------------
extends KinematicBody2D
class_name Player


# Variables:
#---------------------------------------
var player_half_height := 0.0

onready var player_movement := $PlayerMovement
onready var state_manager := $PlayerStateMachine
onready var fishing_rod := $FishingRod

onready var _sprite := $Sprite
onready var capsule_col := $CollisionShape2D


# Functions:
#---------------------------------------
func _ready() -> void:
	state_manager.init(self)
	player_movement.init(self)

	fishing_rod.init(self)

	player_half_height = capsule_col.shape.radius + (capsule_col.shape.height / 2.0)


func _unhandled_input(event: InputEvent) -> void:
	state_manager.input(event)


func _process(delta: float) -> void:
	state_manager.process(delta)


func _physics_process(delta: float) -> void:
	state_manager.physics_process(delta)


func update_sprite (facing_dir: Vector2) -> void:
	if facing_dir.x > 0:
		_sprite.scale.x = 1
		
	elif facing_dir.x < 0:
		_sprite.scale.x = -1


func apply_wind(wind_force : Vector2) -> void:
	player_movement.apply_wind(wind_force)

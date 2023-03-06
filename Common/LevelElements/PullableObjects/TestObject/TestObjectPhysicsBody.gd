# Test Pullable Object PHYSICS BODY
extends KinematicBody2D


var controls_movement := true


onready var object_movement := $ObjectMovement


func _ready() -> void:
    object_movement.init(self)


func _physics_process(delta: float) -> void:
    if controls_movement:
        object_movement.move_object(delta)
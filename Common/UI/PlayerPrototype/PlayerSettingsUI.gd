extends Control

onready var _anim_player := $AnimationPlayer


func _on_invalid_change() -> void:
	_anim_player.play("InvalidChange")


func _on_valid_change() -> void:
	_anim_player.play("ValidChange")

# Player Walk State
# --------------------------------
extends PlayerMoveState


# Functions:
#---------------------------------------
func enter(arg := {}) -> void:
	emit_signal("state_entered")


func exit() -> void:
	emit_signal("state_exited")


func get_state_name() -> String:
	return "Player Walk"
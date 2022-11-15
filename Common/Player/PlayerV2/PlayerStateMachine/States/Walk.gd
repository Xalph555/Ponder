# Player Idle State
# --------------------------------
extends PlayerMoveState


# Variables:
#---------------------------------------



# Functions:
#---------------------------------------
func input(event: InputEvent) -> void:
	.input(event)


func get_state_name() -> String:
	return "Player Walk"
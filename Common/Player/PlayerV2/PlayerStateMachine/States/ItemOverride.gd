# Player Item Override State
# --------------------------------
extends PlayerBaseState

# Items that need to override the player's state will control the transition in and out of this state 
# The player should not be able to enter/ exit this state through their own states


# Functions:
#---------------------------------------
func enter(arg := {}) -> void:
	emit_signal("state_entered")


func exit() -> void:
	emit_signal("state_exited")


func get_state_name() -> String:
	return "Player Item Override"

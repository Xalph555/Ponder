# BaseRodState
# ---------------------------------
extends Node
class_name BaseRodState


# Signals:
#---------------------------------------
# Following 2 signals are intended to notify when the state has been 
#   fully entered/ exited
# These need to be implemented within each subclass
signal state_entered
signal state_exited


# Variables:
#---------------------------------------
var rod_ref

var attached_player : RodAttachedObject


# Functions:
#--------------------------------------
func set_up_state(rod) -> void:
	rod_ref = rod


func enter(args := {}) -> void:
	if args.has("player_ref"):
		attached_player = RodAttachedObject.new(args["player_ref"])
		# print("Attached Player to Rod: ", attached_player.attached_entity)

func exit() -> void:
	pass

	
func update_unwrapping() -> void:
	pass

func update_wrapping() -> void:
	pass


func handle_rod_behaviour(delta : float) -> void:
	pass


func transition_player_to_grapple() -> void:
	pass

func transition_player_to_pull() -> void:
	attached_player.is_grappled = false

func can_player_grapple() -> bool:
	return false


func can_reel() -> bool:
	return false

func start_reeling(delta : float) -> void:
	pass

func stop_reeling() -> void:
	pass

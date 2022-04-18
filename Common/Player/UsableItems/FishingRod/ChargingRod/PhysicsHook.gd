#--------------------------------------#
# Physics Hook Script                  #
#--------------------------------------#

extends RigidBody2D

class_name PhysicsHook


# Signals:
#---------------------------------------
signal has_hooked


# Variables:
#---------------------------------------
var is_hooked := false


# Functions:
#---------------------------------------
func _ready() -> void:
	pass


func _on_PhysicsHook_body_entered(body: Node) -> void:
	sleeping = true
	is_hooked = true
	
	emit_signal("has_hooked")


func release() -> void:
	call_deferred("free")

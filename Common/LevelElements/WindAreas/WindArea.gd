#--------------------------------------#
# WindArea Script                      #
#--------------------------------------#
extends Area2D
class_name WindArea


# Variables:
#---------------------------------------
export(Vector2) var wind_dir := Vector2.ZERO
export(float) var push_force := 10.0

onready var _col_shape := $CollisionShape2D
onready var particles := $Particles2D


# Functions:
#---------------------------------------
func _ready() -> void:
	particles.process_material.direction = Vector3(wind_dir.x, wind_dir.y, 0)
	particles.process_material.emission_box_extents = Vector3(_col_shape.shape.extents.x, _col_shape.shape.extents.y, 1)

	particles.emitting = true


func _physics_process(delta: float) -> void:
	var bodies := get_overlapping_bodies()
	
	var applied_force = wind_dir * push_force

	for body in bodies:
		# print(body.name)

		if body.has_method("apply_wind"):
			body.apply_wind(applied_force)
			

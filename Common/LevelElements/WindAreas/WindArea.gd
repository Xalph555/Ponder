#--------------------------------------#
# WindArea Script                      #
#--------------------------------------#
extends Area2D
class_name WindArea


# Variables:
#---------------------------------------
export(Vector2) var wind_dir := Vector2.RIGHT
export(float) var push_force := 5.0

onready var _col_shape := $CollisionShape2D
onready var particles := $WindLines
onready var back_particles := $WindBackground


# Functions:
#---------------------------------------
func _ready() -> void:
	var col_shape_extents = _col_shape.shape.extents

	particles.visibility_rect = Rect2(-col_shape_extents, col_shape_extents * 2)
	particles.process_material.direction = Vector3(wind_dir.x, wind_dir.y, 0)
	particles.process_material.emission_box_extents = Vector3(col_shape_extents.x, col_shape_extents.y, 1)

	back_particles.visibility_rect = Rect2(-col_shape_extents, col_shape_extents * 2)
	back_particles.process_material.direction = Vector3(wind_dir.x, wind_dir.y, 0)
	back_particles.process_material.emission_box_extents = Vector3(col_shape_extents.x,col_shape_extents.y, 1)

	particles.emitting = true
	back_particles.emitting = true


func _physics_process(delta: float) -> void:
	var bodies := get_overlapping_bodies()
	
	var applied_force = wind_dir * push_force

	for body in bodies:
		# print(body.name)

		if body.has_method("apply_wind"):
			body.apply_wind(applied_force)
			# body.call_deferred("apply_wind", applied_force)
			

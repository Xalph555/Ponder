#--------------------------------------#
# LeafDefaultValues Script             #
#--------------------------------------#
extends Resource
class_name LeafDefaultValues


# Variables:
#---------------------------------------
export(float) var gravity := 60.0

export(float) var acceleration := 5.0
export(float) var max_speed := 180.0

export(float) var in_air_friction_x := 0.009
export(float) var in_air_friction_y := 0.035

export(float) var wind_force_multiplier := 4.0
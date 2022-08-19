#--------------------------------------#
# PlayerDefaultValues Script           #
#--------------------------------------#

extends Resource
class_name PlayerDefaultValues


# Variables:
#---------------------------------------
export(float) var acceleration := 50.0
export(float) var max_speed := 400.0

export(float) var on_floor_friction := 0.25
export(float) var in_air_friction := 0.2

export(float) var jump_height := 38.0
export(float) var jump_time_to_peak := 0.4
export(float) var jump_time_to_descent := 0.4
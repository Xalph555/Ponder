extends StaticBody2D


export(float) var max_health = 5
onready var _current_health = max_health


func get_health() -> float:
	return _current_health

func set_health(amount : float) -> void:
	if amount >= 0:
		_current_health = amount

func add_health(amount : float) -> void:
	_current_health += amount	

	# print("Breakable has been damaged: ", amount)
	# print("Current health: ", _current_health)
	
	if _current_health < 0:
		call_deferred("free")
	
	if _current_health > max_health:
		_current_health = max_health
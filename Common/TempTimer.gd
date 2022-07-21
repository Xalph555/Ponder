#--------------------------------------#
# Temp Timer Script                    #
#--------------------------------------#
extends Reference
class_name TempTimer


class FrameTimer extends Node:
	signal timeout

	var seconds := 0.1

	func _process(delta: float) -> void:
		seconds -= delta

		if seconds <= 0:
			emit_signal("timeout")
			queue_free()


static func start_timer(node : Node, sec : float = 0.1) -> FrameTimer:
	var t := FrameTimer.new()
	t.seconds = sec
	node.add_child(t)

	return t

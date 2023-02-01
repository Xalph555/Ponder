extends StaticBody2D

export(PackedScene) var rope_node_scene

export(float) var rope_length := 20.0

onready var length_visualisation := $Area2D/CollisionShape2D

var node_refs := []


func _ready() -> void:
	# pass
	var start_node = rope_node_scene.instance()
	add_child(start_node)
	start_node.init(self)

	node_refs.append(start_node)

	var node_length = start_node.segment_length
	var num_nodes = ceil(rope_length / node_length)

	print("Number of nodes in rope: ", num_nodes)

	print("Start attached node: ", node_refs.back().attached_node)

	for i in num_nodes - 1:
		var new_node = rope_node_scene.instance()
		add_child(new_node)
		new_node.set_as_toplevel(true)
		new_node.global_position = self.global_position
		new_node.init(node_refs.back())

		node_refs.append(new_node)

		print("New node attached node: ", node_refs.back().attached_node)
	

	length_visualisation.shape.radius = rope_length

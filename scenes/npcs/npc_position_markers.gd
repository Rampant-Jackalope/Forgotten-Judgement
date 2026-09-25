extends Node

class_name NpcPositionMarkers

func get_marker(id: String) -> Node3D:
	return get_node_or_null(id)

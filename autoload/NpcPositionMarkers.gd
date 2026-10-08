extends Node3D

var _positions: Dictionary[String, NpcMarker] = {}

func add(marker: NpcMarker) -> void:
	assert(!_positions.has(marker.identifier), "Cannot add NpcMarker with id: %s as it is already taken" % marker.identifier)
	_positions[marker.identifier] = marker

func remove(identifier: String) -> bool:
	return _positions.erase(identifier)

func transition(identifier: String, npc: Node3D) -> void:
	assert(_positions.has(identifier), "No Npc marker with identifier %s" % identifier)	
	ScreenFader.transition_npc(npc, _positions[identifier].global_position)

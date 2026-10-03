extends Node3D

var _positions: Dictionary[String, PlayerMarker] = {}

func add(marker: PlayerMarker) -> bool:
	if _positions.has(marker.identifier): return false
	_positions[marker.identifier] = marker
	return true

func remove(identifier: String) -> bool:
	return _positions.erase(identifier)

func transition(identifier: String) -> void:
	assert(_positions.has(identifier), "No player marker with identifier %s" % identifier)	
	_positions[identifier].transition()

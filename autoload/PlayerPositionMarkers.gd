extends Node3D

var _positions: Dictionary[String, PlayerMarker] = {}

func add(marker: PlayerMarker) -> void:
	assert(!_positions.has(marker.identifier), "Cannot add PlayerMarker with id: %s as it is already taken" % marker.identifier)
	_positions[marker.identifier] = marker

func remove(identifier: String) -> bool:
	return _positions.erase(identifier)

func transition(identifier: String) -> void:
	assert(_positions.has(identifier), "No player marker with identifier %s" % identifier)	
	_positions[identifier].transition()

func get_marker(identifier: String) -> PlayerMarker:
	assert(_positions.has(identifier), "No player marker with identifier %s" % identifier)	
	return _positions[identifier]

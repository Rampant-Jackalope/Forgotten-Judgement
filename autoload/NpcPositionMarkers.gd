extends Node3D

var _positions: Dictionary[String, NpcMarker] = {}
var _npc_list: Dictionary[DialogicFlags.Npc, Node3D]

func register_npc(npc: DialogicFlags.Npc, root_node: Node3D) -> void:
	_npc_list[npc] = root_node

func add(marker: NpcMarker) -> void:
	assert(!_positions.has(marker.identifier), "Cannot add NpcMarker with id: %s as it is already taken" % marker.identifier)
	_positions[marker.identifier] = marker

func remove(identifier: String) -> bool:
	return _positions.erase(identifier)

func transition(identifier: String, npc: DialogicFlags.Npc) -> void:
	assert(_positions.has(identifier), "No Npc marker with identifier %s" % identifier)	
	assert(_npc_list.has(npc), "The " + DialogicFlags.Npc.keys()[npc] + " key is not registered")
	var new_global_pos = _positions[identifier].global_position
	ScreenFader.transition_npc(_npc_list[npc], new_global_pos)
	GameState.data[npc] = new_global_pos 

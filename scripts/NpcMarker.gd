extends Marker3D 
class_name NpcMarker 

@export var identifier: String

func _ready() -> void:
	NpcPositionMarkers.add(self)
func _exit_tree() -> void:
	NpcPositionMarkers.remove(self.identifier)
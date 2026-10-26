extends Marker3D
class_name PlayerMarker

@export var identifier: String
@export var look_direction: Vector3

func _ready() -> void:
	PlayerPositionMarkers.add(self)
func _exit_tree() -> void:
	PlayerPositionMarkers.remove(self.identifier)

func transition() -> void:
	ScreenFader.transition_player(self.global_position, self.look_direction)
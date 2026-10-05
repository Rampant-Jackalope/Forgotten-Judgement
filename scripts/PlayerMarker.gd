extends Marker3D
class_name PlayerMarker

@export var identifier: String
@export var look_direction: Vector3

func _ready() -> void:
	PlayerPositionMarkers.add(self)

func transition() -> void:
	ScreenFader.transition_player(self.global_position, self.look_direction)

extends Marker3D
class_name PlayerMarker

@export var identifier: String
@export var look_direction: Vector3

func _ready() -> void:
	assert(PlayerPositionMarkers.add(self), "Failed to add player marker with identifier %s, possible duplicate" % identifier)

func transition() -> void:
	ScreenFader.transition_player(self.global_position, self.look_direction)

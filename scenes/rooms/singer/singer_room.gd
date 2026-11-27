extends Node3D

func _on_callback_door_interacted(_door: Node3D, _interactor: Interactor, _pop: Callable) -> void:
	if Dialogic.VAR.SINGER.ENTERED_AUDITORIUM:
		PlayerPositionMarkers.transition("Backstage")
		return

	PlayerPositionMarkers.transition("Singer_Outside")

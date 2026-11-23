extends Node3D

func _on_callback_door_interacted(_door: Node3D, _interactor: Interactor, _pop: Callable) -> void:
	PlayerPositionMarkers.transition("Singer_Inside")

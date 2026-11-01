extends Node3D

func _on_callback_door_interacted(_door: Node3D, _interactor: Interactor, _pop: Callable) -> void:
	print("transitioning to inside overworker room")
	PlayerPositionMarkers.transition("Overworker_Inside")

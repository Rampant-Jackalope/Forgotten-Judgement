extends GridMap

func _on_mounted_button_button_pressed(_button: Node3D, _interactor: Interactor, _pop: Callable) -> void:
	PlayerPositionMarkers.transition("Lift_Bottom")

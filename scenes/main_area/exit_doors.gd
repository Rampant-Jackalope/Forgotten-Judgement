extends Node3D

func _on_interacted(_door: Node3D, _interactor: Interactor, _pop: Callable) -> void:
	Util.get_player().run_locked_dialogue("misc-popups", "exit_door_locked")

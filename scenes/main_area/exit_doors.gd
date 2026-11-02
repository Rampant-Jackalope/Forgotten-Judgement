extends Node3D

func _on_interacted(_door: Node3D, interactor: Interactor, _pop: Callable) -> void:
	interactor.player.run_locked_dialogue("misc-popups", "exit_door_locked")

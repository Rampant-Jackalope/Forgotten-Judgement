extends Node3D

func _on_double_callback_door_interacted(_door_l: Node3D, _door_r: Node3D, interactor: Interactor, _pop: Callable) -> void:
	interactor.player.run_locked_dialogue("misc-popups", "exit_door_locked")

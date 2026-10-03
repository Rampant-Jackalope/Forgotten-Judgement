extends Node3D


func _on_callback_door_interacted(door: Node3D, interactor: Interactor, pop: Callable) -> void:
	Util.get_player().run_locked_dialogue("misc-popups", "exit_door_locked")

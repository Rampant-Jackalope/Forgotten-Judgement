extends Node3D

func _on_side_dependant_callback_door_b_interacted(_door: Node3D, interactor: Interactor, _pop: Callable) -> void:
	pass
	# TODO: tp da player

func _on_side_dependant_callback_door_a_interacted(_door: Node3D, interactor: Interactor, _pop: Callable) -> void:
		interactor.player.run_locked_dialogue("misc-popups", "backstage_door_locked")

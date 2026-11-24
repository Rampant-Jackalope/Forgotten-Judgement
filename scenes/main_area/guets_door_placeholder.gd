extends Node3D

func _on_callback_door_interacted(_door: Node3D, _interactor: Interactor, _pop: Callable) -> void:	
	pass
	# TODO: remove after refactor done
	# Dialogic.VAR.set_variable("misc.GuestName", self.name)
	# Util.get_player().run_locked_dialogue("misc-popups", "guest_door_interaction_placeholder")

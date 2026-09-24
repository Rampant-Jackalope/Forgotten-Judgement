extends Node3D

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	interactor.player.run_locked_dialogue("michael_jackson/main")

func _on_dialogic_event(action: String) -> void:
	match action:
		"fight":
			get_tree().change_scene_to_file("res://scenes/fights/michael/michael_fight.tscn")
		_:
			push_error("Invalid action " + action)

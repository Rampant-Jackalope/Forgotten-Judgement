extends Node3D

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	Util.run_locked_dialogue("michael_jackson/main")

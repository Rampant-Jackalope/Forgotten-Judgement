extends Node3D

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	interactor.player.run_locked_dialogue("overworker/main")

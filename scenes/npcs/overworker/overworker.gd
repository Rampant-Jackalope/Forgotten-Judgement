@tool
extends ScaffoldedNpc 

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	pass
	# TODO: remove after refactor done
	# if !Dialogic.VAR.overworker.HasMetOverworker:
	# 	interactor.player.run_locked_dialogue("overworker/main", "first_interaction")
	# elif Dialogic.VAR.overworker.HasFoughtOverworker:
	# 	interactor.player.run_locked_dialogue("overworker/main", "idle_angry")
	# else:
	# 	interactor.player.run_locked_dialogue("overworker/main", "idle_neutral")

extends Node3D

var is_interacting: bool = false

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:

	if is_interacting:
		return
	
	is_interacting = true
	
	interactor.warning_count = min(interactor.warning_count + 1, 3)
	
	match interactor.warning_count:
		1:
			await interactor.player.run_locked_dialogue("overworker-warning1")
		2:
			await interactor.player.run_locked_dialogue("overworker-warning2")
		3:
			await interactor.player.run_locked_dialogue("overworker-warning3")
			interactor.warning_count = 0
			return 

	await get_tree().create_timer(0.5).timeout
	is_interacting = false

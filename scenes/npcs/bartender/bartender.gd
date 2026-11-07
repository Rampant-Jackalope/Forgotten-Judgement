extends Node3D

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	if Dialogic.VAR.bartender.DemoDone:
		interactor.player.run_locked_dialogue("bartender", "demo_done")

	# Player has already spoken to the overworker
	elif Dialogic.VAR.overworker.HasMetOverworker:
		interactor.player.run_locked_dialogue("bartender", "Has_met_overworker")
	
	# Player has spoken to the bartender, but not yet to the overworker
	elif Dialogic.VAR.bartender.HasMetBartender:
		interactor.player.run_locked_dialogue("bartender", "Has_not_met_overworker")
	
	# First time meeting the bartender (introduction)
	else:
		interactor.player.run_locked_dialogue("bartender", "Introduction_bartender")	
	

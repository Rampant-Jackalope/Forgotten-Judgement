extends Node3D

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	# 1. Player has already spoken to the overworker
	if Dialogic.VAR.overworker.HasMetOverworker:
		interactor.player.run_locked_dialogue("bartender", "Has_met_overworker")
	
	# 2. Player has spoken to the bartender, but not yet to the overworker
	elif Dialogic.VAR.bartender.HasMetBartender:
		interactor.player.run_locked_dialogue("bartender", "Has_not_met_overworker")
	
	# 3. First time meeting the bartender (introduction)
	else:
		interactor.player.run_locked_dialogue("bartender", "Introduction_bartender")	
	

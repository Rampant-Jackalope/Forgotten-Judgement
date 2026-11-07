extends Node3D

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	if Dialogic.VAR.bartender.HasMetBartender:
		if (!Dialogic.VAR.singer.HAS_STAGE_KEY && Dialogic.VAR.singer.HAS_TALKED_TO) || !Dialogic.VAR.bartender.DemoDone:
			interactor.player.run_locked_dialogue("bartender", "idle_demo_active")
		else:
			interactor.player.run_locked_dialogue("bartender", "idle_demo_done")
	else:
		interactor.player.run_locked_dialogue("bartender", "Introduction_bartender")	
	

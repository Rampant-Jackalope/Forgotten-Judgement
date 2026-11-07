extends Node3D

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	if Dialogic.VAR.singer.HasMetBartender:
		if (!Inventory.has_item("backstage_key") && Dialogic.VAR.singer.HAS_TALKED_TO) || !Dialogic.VAR.overworker.HasMetOverworker:
			interactor.player.run_locked_dialogue("bartender", "idle_demo_active")
		else:
			interactor.player.run_locked_dialogue("bartender", "idle_demo_done")
	else:
		interactor.player.run_locked_dialogue("bartender", "Introduction_bartender")	
	

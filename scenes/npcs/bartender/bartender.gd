extends Node3D

var _has_played_post_fight: bool = false

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	# Check if the player has already met the bartender
	if Dialogic.VAR.bartender.HasMetBartender:
		# Play post-fight dialogue ONLY ONCE right after the rat fight is completed
		if Dialogic.VAR.bartender.RatFightCompleted and not _has_played_post_fight:
			_has_played_post_fight = true
			interactor.player.run_locked_dialogue("bartender", "introduction_after_rat_defeated")
			
		# Regular idle dialogue branches for all subsequent interactions
		elif (!Dialogic.VAR.singer.HAS_STAGE_KEY && Dialogic.VAR.singer.HAS_TALKED_TO) || !Dialogic.VAR.bartender.DemoDone:
			interactor.player.run_locked_dialogue("bartender", "idle_demo_active")
		else:
			interactor.player.run_locked_dialogue("bartender", "idle_demo_done")
			
	else:
		# First time meeting: play introduction dialogue and switch to the rat fight
		await interactor.player.run_locked_dialogue("bartender", "Introduction_bartender")
		Dialogic.VAR.bartender.HasMetBartender = true
		Dialogic.VAR.bartender.RatFightCompleted = false
		WorldManager.set_world_to_2d("rat_fight")
		
		# Wait until the rat fight is completed in 2D
		while not Dialogic.VAR.bartender.RatFightCompleted:
			await get_tree().create_timer(0.1).timeout
			
		# Give the 3D world a brief moment to settle, then play the post-fight dialogue automatically
		await get_tree().create_timer(0.5).timeout
		if not _has_played_post_fight:
			_has_played_post_fight = true
			interactor.player.run_locked_dialogue("bartender", "introduction_after_rat_defeated")

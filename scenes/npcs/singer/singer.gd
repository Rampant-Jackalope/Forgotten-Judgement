@tool
extends ScaffoldedNpc 

func _ready() -> void:
	WorldManager.instance.world_changed.connect(_on_world_change)

func _on_world_change(in_2d: bool) -> void:
	if in_2d: return
	
	await get_tree().process_frame
	if DialogicFlags.has_fought(DialogicFlags.Npc.SINGER) and !Dialogic.VAR.SINGER.INTRO_DONE:
		await Util.get_player().run_locked_dialogue("singer/post_fight")
		NpcPositionMarkers.transition("Singer_Room", DialogicFlags.Npc.SINGER)
		Dialogic.VAR.SINGER.INTRO_DONE = true

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	if !DialogicFlags.has_talked_to(DialogicFlags.Npc.SINGER):
		await interactor.player.run_locked_dialogue("singer/intro")
		DialogicFlags.set_talked_to(DialogicFlags.Npc.SINGER, true)
		if DialogicFlags.is_current_emotional_state(DialogicFlags.Npc.SINGER, DialogicFlags.EmotionalState.ANGRY):
			WorldManager.set_world_to_2d("singer_fight")
		# timeline sets `SINGER.INTRO_DONE` so that `_on_world_change()` gets toggled at the right time
		return

	# TODO: add other dialogue

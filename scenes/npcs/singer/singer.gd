@tool
extends ScaffoldedNpc 

func _ready() -> void:
	WorldManager.instance.world_changed.connect(_on_world_change)

func _on_world_change(in_2d: bool) -> void:
	if in_2d: return
	
	await get_tree().process_frame
	if DialogicFlags.has_fought(DialogicFlags.Npc.SINGER): 
		DialogicFlags.set_door_locked(DialogicFlags.Npc.SINGER, true)
		if !Dialogic.VAR.SINGER.INTRO_DONE:
			await Util.get_player().run_locked_dialogue("singer/post_fight_stage")
			NpcPositionMarkers.transition("Singer_Room", DialogicFlags.Npc.SINGER)
			Dialogic.VAR.SINGER.INTRO_DONE = true
		else:
			await Util.get_player().run_locked_dialogue("singer/post_fight_room")
			PlayerPositionMarkers.transition("Singer_Outside")

func fight_if_angry() -> void:
	if DialogicFlags.is_current_emotional_state(DialogicFlags.Npc.SINGER, DialogicFlags.EmotionalState.ANGRY):
		WorldManager.set_world_to_2d("singer_fight")

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	if !DialogicFlags.has_talked_to(DialogicFlags.Npc.SINGER):
		await interactor.player.run_locked_dialogue("singer/intro")
		fight_if_angry()
		DialogicFlags.set_talked_to(DialogicFlags.Npc.SINGER, true)
		# timeline sets `SINGER.INTRO_DONE` so that `_on_world_change()` gets toggled at the right time
		return

	if !DialogicFlags.has_fought(DialogicFlags.Npc.SINGER) and !Dialogic.VAR.SINGER.ROOM_INTRO_DONE:
		await interactor.player.run_locked_dialogue("singer/room_intro")
		fight_if_angry()
		Dialogic.VAR.SINGER.ROOM_INTRO_DONE = true
		return

	interactor.player.run_locked_dialogue("singer/idle")

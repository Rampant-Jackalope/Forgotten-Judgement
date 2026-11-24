@tool
extends ScaffoldedNpc 

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	if !DialogicFlags.has_talked_to(DialogicFlags.NPC.OVERWORKER):
		interactor.player.run_locked_dialogue("overworker/intro")
		DialogicFlags.set_talked_to(DialogicFlags.NPC.OVERWORKER, true)

	var label = "neutral"
	if DialogicFlags.is_current_emotional_state(DialogicFlags.Npc.OVERWORKER, DialogicFlags.EmotionalState.ANNOYED):
		label = "annoyed"

	interactor.player.run_locked_dialogue("overworker/idle", label)

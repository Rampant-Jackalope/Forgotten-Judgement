@tool
extends ScaffoldedNpc 

var _origin: Transform3D ## this is the original position of the NPC, used for resetting it back to its original position if needed.

func _ready() -> void:
	_origin = global_transform

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	if !DialogicFlags.has_talked_to(DialogicFlags.Npc.SINGER):
		await interactor.player.run_locked_dialogue("singer/intro")
		DialogicFlags.set_talked_to(DialogicFlags.Npc.SINGER, true)
		if DialogicFlags.is_current_emotional_state(DialogicFlags.Npc.SINGER, DialogicFlags.EmotionalState.ANGRY):
			WorldManager.set_world_to_2d("singer_fight")
		NpcPositionMarkers.transition("Singer_Room", DialogicFlags.Npc.SINGER)
		return
	# TODO: add other dialogue

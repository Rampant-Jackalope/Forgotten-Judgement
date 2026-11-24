@tool
extends ScaffoldedNpc 

func _ready() -> void:
	if WorldManager.instance:
		WorldManager.instance.world_changed.connect(_on_world_changed)

func _on_world_changed(in_2d: bool) -> void:
	if in_2d || !DialogicFlags.has_fought(DialogicFlags.Npc.OVERWORKER): return

	await get_tree().process_frame
	if DialogicFlags.has_won_fight(DialogicFlags.Npc.OVERWORKER):
		Util.get_player().run_locked_dialogue("overworker/post_fight_win")
	else: 
		Util.get_player().run_locked_dialogue("overworker/post_fight_loss")
	
func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	if !DialogicFlags.has_talked_to(DialogicFlags.Npc.OVERWORKER):
		interactor.player.run_locked_dialogue("overworker/intro")
		DialogicFlags.set_talked_to(DialogicFlags.Npc.OVERWORKER, true)

	var label = "neutral"
	if DialogicFlags.is_current_emotional_state(DialogicFlags.Npc.OVERWORKER, DialogicFlags.EmotionalState.ANNOYED):
		label = "annoyed"

	interactor.player.run_locked_dialogue("overworker/idle", label)

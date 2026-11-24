@tool
extends ScaffoldedNpc

var _player: Node = null
var _has_played_post_fight: bool = false

func _ready() -> void:
	if WorldManager.instance:
		WorldManager.instance.world_changed.connect(_on_world_changed)

# via the signal instead of directly after `WorldManager.set_world_to_2d("rat_fight")` so there are no timing issues with initialization
func _on_world_changed(in_2d: bool) -> void:
	if in_2d or _has_played_post_fight: return

	if DialogicFlags.has_talked_to(DialogicFlags.Npc.BARTENDER) and DialogicFlags.has_won_fight(DialogicFlags.Npc.RAT):
		_has_played_post_fight = true

		# Wait one frame for the 3D world and player node to fully re-enable
		await get_tree().process_frame
		if _player and _player.has_method("run_locked_dialogue"):
			_player.run_locked_dialogue("bartender/intro", "post_rat_trauma")

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	_player = interactor.player
	if !DialogicFlags.has_talked_to(DialogicFlags.Npc.BARTENDER):
		await interactor.player.run_locked_dialogue("bartender/intro")
		DialogicFlags.set_talked_to(DialogicFlags.Npc.BARTENDER, true)
		WorldManager.set_world_to_2d("rat_fight")
	
	else:
		if !DialogicFlags.has_won_fight(DialogicFlags.Npc.RAT):
			await interactor.player.run_locked_dialogue("bartender/intro", "rat_attack")
			WorldManager.set_world_to_2d("rat_fight")
		else:
			await interactor.player.run_locked_dialogue("bartender/idle")

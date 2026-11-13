@tool
extends ScaffoldedNpc

var _player: Node = null
var _has_played_post_fight: bool = false

func _ready() -> void:
	if WorldManager.instance:
		WorldManager.instance.world_changed.connect(_on_world_changed)

func _on_world_changed(in_2d: bool) -> void:
	if in_2d or _has_played_post_fight:
		return
		
	if Dialogic.VAR.bartender.HasMetBartender and Dialogic.VAR.bartender.RatFightCompleted:
		_has_played_post_fight = true
		
		# Wait one frame for the 3D world and player node to fully re-enable
		await get_tree().process_frame
		if _player and _player.has_method("run_locked_dialogue"):
			_player.run_locked_dialogue("bartender", "introduction_after_rat_defeated")

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	_player = interactor.player
	if Dialogic.VAR.bartender.HasMetBartender:
		if (!Dialogic.VAR.singer.HAS_STAGE_KEY && Dialogic.VAR.singer.HAS_TALKED_TO) || !Dialogic.VAR.bartender.DemoDone:
			interactor.player.run_locked_dialogue("bartender", "idle_demo_active")
		else:
			interactor.player.run_locked_dialogue("bartender", "idle_demo_done")
	else:
		await interactor.player.run_locked_dialogue("bartender", "Introduction_bartender")
		Dialogic.VAR.bartender.HasMetBartender = true
		Dialogic.VAR.bartender.RatFightCompleted = false
		WorldManager.set_world_to_2d("rat_fight")

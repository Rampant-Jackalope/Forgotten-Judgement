extends Node3D

static var warning_count: int = 0
var is_interacting: bool = false

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:

	if is_interacting:
		return
	
	is_interacting = true
	
	match warning_count:
		0:
			warning_count += 1
			interactor.player.run_locked_dialogue("overworker-warning1")
		1:
			warning_count += 1
			interactor.player.run_locked_dialogue("overworker-warning2")
		_:
			interactor.player.run_locked_dialogue("overworker-warning3")
			await Dialogic.timeline_ended
			warning_count = 0
			call_deferred("_change_to_fight_scene")
			return 

	await get_tree().create_timer(0.5).timeout
	is_interacting = false

func _change_to_fight_scene() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.change_scene_to_file("res://scenes/fights/overworker/overworker_fight.tscn")

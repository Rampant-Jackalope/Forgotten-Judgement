extends Node3D

static var warning_count: int = 0

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
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

func _change_to_fight_scene() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.change_scene_to_file("res://scenes/fights/overworker/overworker_fight.tscn")

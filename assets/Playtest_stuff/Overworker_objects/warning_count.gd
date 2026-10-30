extends Node3D

var is_interacting: bool = false

func _ready() -> void:

	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	if is_interacting:
		return
	
	is_interacting = true
	
	await interactor.player.run_locked_dialogue("overworker-warning1")
	
	await get_tree().create_timer(0.5).timeout
	is_interacting = false

func _on_dialogic_signal(argument: Dictionary) -> void:

	if argument.get("subject") == "overworker" and argument.get("action") == "fight":
		_start_overworker_fight()

func _start_overworker_fight() -> void:

	Dialogic.VAR.overworker.overworker_warnings = 0
	get_tree().change_scene_to_file("res://scenes/fights/overworker/overworker_fight.tscn")

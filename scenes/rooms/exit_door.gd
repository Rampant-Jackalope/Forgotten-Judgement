extends Node3D

var interaction_count := 0

func _on_interactable_interacted(_pop: Callable) -> void:
	Util.run_locked_dialogue("misc-popups", "exit_door_locked")

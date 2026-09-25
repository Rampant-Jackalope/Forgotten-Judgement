extends Node3D

var _origin: Transform3D # this is the original position of the NPC, used for resetting it back to its original position if needed.

func _ready() -> void:
	_origin = global_transform

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	interactor.player.run_locked_dialogue("michael_jackson/main")

func _on_dialogic_event(action: String) -> void:
	match action:
		"fight":
			get_tree().change_scene_to_file("res://scenes/fights/michael_fight.tscn")
		"bar":
			PlayerUtil.transition_npc(self, Util.get_npc_marker("MichaelBarMarker").global_position)
		"stage":
			PlayerUtil.transition_npc(self, _origin.origin)
		_:
			push_error("Invalid action " + action)
	

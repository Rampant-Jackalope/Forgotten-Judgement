@tool
extends ScaffoldedNpc 

var _origin: Transform3D ## this is the original position of the NPC, used for resetting it back to its original position if needed.

func _ready() -> void:
	_origin = global_transform

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	pass
	# TODO: remove after refactor done
	# interactor.player.run_locked_dialogue("singer/main")

func _on_dialogic_event(_action: String) -> void:
	pass
	# TODO: remove after refactor done
	# match action:
	# 	"fight":
	# 		WorldManager.set_world_to_2d("singer_fight")
	# 	"bar":
	# 		NpcPositionMarkers.transition("Michael_Bar", self)
	# 	"stage":
	# 		NpcPositionMarkers.transition("Michael_Stage", self)
	# 	_:
	# 		push_error("Invalid action " + action)
	#

extends Node

@export var resident: DialogicFlags.NPC
@export var locked: bool = false
@export var callback_door: Node3D
@export var player_marker_id: String

func _ready() -> void:
	assert(callback_door != null, "No callback door assigned")
	assert(callback_door.has_signal("interacted"), "Assigned callback door is not really a callback door")
	assert(resident != null, "No resident assigned to this door")
	assert(PlayerPositionMarkers.get_marker(player_marker_id) != null, "Invalid playermarker assigned") # can possibly fail due to timing issues if that becomes a problem change this ig

	callback_door.interacted.connect()

func _on_interacted(_door: Node3D, interactor: Interactor, _pop: Callable) -> void:
	if DialogicFlags.is_door_locked(resident):
		Dialogic.VAR.GOBAL.SCRATCH = Util.get_npc_name(resident)
		await interactor.player.run_locked_dialogue("misc-popups", "locked_door")
		return

	PlayerPositionMarkers.transition(player_marker_id)

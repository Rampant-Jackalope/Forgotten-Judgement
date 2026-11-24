extends Node

@export var resident: DialogicFlags.Npc
@export var locked: bool = false
@export var callback_door: Node3D
@export var player_marker_id: String

# TODO: remove after all rooms are linked
# this is purely a placeholder so that the assigned doors don't panic
# placing a node in the scene somewhere is a pain and we'll deff forget where in the 3d space its placed
static var _markers_spawned := false
func _enter_tree() -> void:
	if _markers_spawned:
		return
	_markers_spawned = true

	var ids = ["Hobo_Inside", "Enki_Inside", "Child_Inside", "Couple_Inside"]
	for id in ids:
		var instance = PlayerMarker.new()
		instance.identifier = id
		add_child(instance)
		instance.global_position = Vector3(-2, 3.9, 6.5)

func _ready() -> void:
	assert(callback_door != null, "No callback door assigned")
	assert(callback_door.has_signal("interacted"), "Assigned callback door is not really a callback door")
	assert(resident != null, "No resident assigned to this door")
	assert(!player_marker_id.is_empty(), "No player marker id assigned")

	# Directly asserting this can possibly fail due to timing issues
	# so just warn as a heads up ig ¯\_(ツ)_/¯
	if !PlayerPositionMarkers.has_marker(player_marker_id):
		push_warning("Invalid playermarker assigned")

	DialogicFlags.set_door_locked(resident, locked)
	callback_door.interacted.connect(_on_interacted)

func _on_interacted(_door: Node3D, interactor: Interactor, _pop: Callable) -> void:
	if DialogicFlags.is_door_locked(resident):
		Dialogic.VAR.GLOBAL.SCRATCH = Util.get_npc_name(resident)
		await interactor.player.run_locked_dialogue("misc-popups", "locked_door")
		return

	PlayerPositionMarkers.transition(player_marker_id)

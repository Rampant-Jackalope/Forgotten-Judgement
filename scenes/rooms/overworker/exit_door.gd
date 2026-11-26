extends Node3D

func _on_callback_door_interacted(_door: Node3D, _interactor: Interactor, _pop: Callable) -> void:
	if _earned_no_touch_reward():
		Dialogic.VAR.OVERWORKER.UNLOCKED_TALK = true
		PlayerStats.add_empathy()

	PlayerPositionMarkers.transition("Overworker_Outside")

func _earned_no_touch_reward() -> bool:
	if not DialogicFlags.has_talked_to(DialogicFlags.Npc.OVERWORKER):
		return false
	if Dialogic.VAR.OVERWORKER.TOUCH_COUNT != 0:
		return false
	# reward is one-time, and pointless if he's already resolved
	if Dialogic.VAR.OVERWORKER.UNLOCKED_TALK or DialogicFlags.has_reached_happy_ending(DialogicFlags.Npc.OVERWORKER):
		return false
	return true

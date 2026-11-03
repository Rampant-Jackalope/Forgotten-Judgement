extends Node
## Autoload "FlagWatcher".
##
## Reacts to Dialogic variables changing, e.g. showing
## "(you can now open the backstage door)" the moment michael.HAS_STAGE_KEY becomes true.
##
## How it works: it keeps a snapshot of all Dialogic variables and, whenever no dialogue
## is running, compares that snapshot with the current values (before/after comparison).
## While a dialogue IS running the snapshot is left alone, so anything changed mid-dialogue
## is detected (and its popup shown) right after that dialogue ends.
##
## Snapshots are used instead of Dialogic.VAR.variable_changed because that signal only
## fires for `set` events / VAR.set_variable(); `Dialogic.VAR.some.flag = x` from GDScript
## changes the value silently.
##
## Reason for adding: This allows us to notify players whenever a variable has changed.
## Perhaps logic like this can also be used for a diary/logbook.

## Emitted (outside of dialogue) for every Dialogic variable whose value changed.
## `path` is the dotted variable name, e.g. "michael.HAS_STAGE_KEY".
signal flag_changed(path: String, old_value: Variant, new_value: Variant)

## Popups shown when a variable becomes true: variable path -> [timeline, label].
## One line per popup.
const POPUPS := {
	"michael.HAS_STAGE_KEY": ["misc-popups", "backstage_door_unlocked"],
}

var _snapshot: Dictionary = {}
var _has_snapshot := false
var _queue: Array[Array] = []


func _process(_delta: float) -> void:
	if _is_dialogue_busy():
		return

	if not _has_snapshot:
		resync()
	elif Dialogic.VAR.var_storage != _snapshot: # deep comparison
		_diff(_snapshot, Dialogic.VAR.var_storage, "")
		resync()

	if not _queue.is_empty():
		_show_next_popup()


## Accepts the current values as the new baseline without firing anything.
## Call this after loading a save, so every loaded flag doesn't pop up at once.
func resync() -> void:
	_snapshot = Dialogic.VAR.var_storage.duplicate(true)
	_has_snapshot = true


func _diff(old: Dictionary, new: Dictionary, prefix: String) -> void:
	for key in new:
		var path := prefix + str(key)
		var old_value: Variant = old.get(key)
		var new_value: Variant = new[key]
		if new_value is Dictionary:
			_diff(old_value if old_value is Dictionary else {}, new_value, path + ".")
		# typeof check first: comparing e.g. bool with int using != errors in Godot 4
		elif typeof(old_value) != typeof(new_value) or old_value != new_value:
			_on_flag_changed(path, old_value, new_value)


func _on_flag_changed(path: String, old_value: Variant, new_value: Variant) -> void:
	flag_changed.emit(path, old_value, new_value)
	if new_value is bool and new_value and POPUPS.has(path):
		_queue.push_back(POPUPS[path])


func _show_next_popup() -> void:
	var player := _get_player()
	if player == null:
		return # not in the world scene (menu, fight, ...): try again once the player exists
	var popup: Array = _queue.pop_front()
	# Not awaited: run_locked_dialogue() sets dialogue_locked right away, which keeps
	# _process() idle until this popup is done. The next queued popup follows after.
	player.run_locked_dialogue(popup[0], popup[1])


func _is_dialogue_busy() -> bool:
	if Dialogic.current_timeline != null:
		return true
	# Also covers the frame between Dialogic.start() and the timeline actually starting.
	var player := _get_player()
	return player != null and player.dialogue_locked


## Like Util.get_player(), but returns null instead of erroring outside the world scene.
func _get_player() -> Player3D:
	return get_tree().root.get_node_or_null("World/Player3D") as Player3D

# TODO: change from autoload to class you can assign
extends Node
## Autoload "FlagWatcher".
##
## Reacts to Dialogic variables changing, e.g. showing
## "(you can now open the backstage door)" the moment singer.HAS_STAGE_KEY becomes true.
##
## Snapshots are used instead of Dialogic.VAR.variable_changed because that signal only
## fires for `set` events / VAR.set_variable(); `Dialogic.VAR.some.flag = x` from GDScript
## changes the value silently.
##
## Reason for adding: This allows us to notify players whenever a variable has changed.
## Perhaps logic like this can also be used for a diary/logbook.

## Emitted (outside of dialogue) for every Dialogic variable whose value changed.
## `path` is the dotted variable name, e.g. "singer.HAS_STAGE_KEY".
signal flag_changed(path: String, old_value: Variant, new_value: Variant)


## Popups shown when a variable becomes true: variable path -> [timeline, label].
## One line per popup.
var POPUPS: Dictionary[String, PopupDef] = {
	"singer.HAS_STAGE_KEY": PopupDef.new("misc-popups", "backstage_door_unlocked"),
}

var _snapshot: Dictionary = {}
var _has_snapshot := false
var _queue: Array[PopupDef] = []

func _ready() -> void:
	POPUPS.make_read_only()

func _process(_delta: float) -> void:
	if _is_dialogue_busy():
		return

	if not _has_snapshot:
		resync()
	elif Dialogic.VAR.var_storage != _snapshot: # deep comparison
		_diff(_snapshot, Dialogic.VAR.var_storage, "")
		resync()

	if not _queue.is_empty() and _can_show_popup():
		_show_popup(_queue.pop_front())


## Accepts the current values as the new baseline without firing anything.
## Call this after loading a save, so every loaded flag doesn't pop up at once.
func resync() -> void:
	_snapshot = Dialogic.VAR.var_storage.duplicate(true)
	_has_snapshot = true


# TODO: Seperate responsibilities of comparing dictionaries and emitting signals
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


func _show_popup(popup: PopupDef) -> void:
	Util.get_player().run_locked_dialogue(popup.timeline, popup.label)


func _is_dialogue_busy() -> bool:
	if Dialogic.current_timeline != null:
		return true
	# Also covers the frame between Dialogic.start() and the timeline actually starting.
	var player := Util.get_player_or_null()
	return player != null and player.dialogue_locked

## No player (main menu) or 3D world disabled (2D fight, pause): try again later
func _can_show_popup() -> bool:
	var player := Util.get_player_or_null()
	return player != null and player.can_process()

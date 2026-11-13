extends Node

## Emitted right before saving. Connect to quickly save before write is finalized
signal about_to_save
signal save_done

const SAVE_PATH := "user://player_state.json"

enum DataKey {
	PLAYER_POSITION,
	LOAD_SAVE,
	ITEMS,
	SHOW_AUTO_SAVE_INDICATOR # TODO: move to settings
}

## Only keys listed here are saved and loaded. The values are the defaults.
## Keys are written to the file by enum NAME, so reordering or inserting enum
## values won't break old saves (renaming one will).
## NOTE: when too many values are added to this list just start creating classes/objects to nest them under
var data: Dictionary = {
	DataKey.PLAYER_POSITION: Vector3(0, 0, 8),
	DataKey.LOAD_SAVE: false,
	DataKey.ITEMS: [] as Array[ItemData],
	DataKey.SHOW_AUTO_SAVE_INDICATOR: true # TODO: move to settings
}

var _defaults := data.duplicate(true)

func _ready() -> void:
	get_tree().auto_accept_quit = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# TODO: add confirm UI
		save_to_disk()
		get_tree().quit()

# NOTE: when using `get_tree().quit()` be sure to save cuzz apparently that does not run the _exit_tree() functions
func save_to_disk(path: String = SAVE_PATH) -> Error:
	about_to_save.emit()

	var out := { "data": { }, "dialogic": { } }
	for key in data:
		out["data"][DataKey.find_key(key)] = var_to_str(data[key])
	var vars := _get_dialogic_vars()
	for key in vars:
		out["dialogic"][key] = var_to_str(vars[key])

	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		save_done.emit()
		return FileAccess.get_open_error()

	f.store_string(JSON.stringify(out))

	save_done.emit()
	return OK

func load_from_disk(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path): return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary): return false

	# only keys that exist in `data` are restored, everything else is ignored
	var saved: Dictionary = parsed.get("data", { })
	for key in data:
		var k: String = DataKey.find_key(key)
		if saved.has(k):
			data[key] = str_to_var(saved[k])

	if data.has(DataKey.ITEMS):
		Inventory.clear()
		for item in data[DataKey.ITEMS]:
			if item is ItemData:
				Inventory.add(item)

	var loaded := { }
	var saved_vars: Dictionary = parsed.get("dialogic", { })
	for key in saved_vars:
		loaded[key] = str_to_var(saved_vars[key])
	_set_dialogic_vars(loaded)
	return true

func erase_save(path: String = SAVE_PATH, reset_memory: bool = true) -> Error:
	var err := OK
	if FileAccess.file_exists(path):
		err = DirAccess.remove_absolute(path)
	if reset_memory:
		data = _defaults.duplicate(true)
		var d = get_node_or_null("/root/Dialogic")
		if d:
			d.VAR.reset() # documented: resets all variables to the editor's values
	return err

# Dialogic
# Variables live in Dialogic.VAR.var_storage, a nested dict:
#   { "singer": { "RESPECT": 0 }, "misc": { "GuestName": "" } }
# They're saved flat by dotted path ("singer.RESPECT").

func _get_dialogic_vars() -> Dictionary:
	# untyped on purpose: looked up by path so this still parses without the plugin
	var d = get_node_or_null("/root/Dialogic")
	var out := { }
	if d == null:
		push_warning("GameState: /root/Dialogic not found, is the plugin enabled?")
		return out
	_flatten(d.VAR.var_storage, "", out)
	return out

func _flatten(folder: Dictionary, prefix: String, out: Dictionary) -> void:
	for k in folder:
		if folder[k] is Dictionary:
			_flatten(folder[k], prefix + k + ".", out)
		else:
			out[prefix + k] = folder[k]

func _set_dialogic_vars(vars: Dictionary) -> void:
	var d = get_node_or_null("/root/Dialogic")
	if d == null:
		push_warning("GameState: /root/Dialogic not found, skipping Dialogic variables")
		return
	for path in vars:
		var parts: PackedStringArray = path.split(".")
		var folder: Dictionary = d.VAR.var_storage
		var found := true
		for i in parts.size() - 1:
			if folder.get(parts[i]) is Dictionary:
				folder = folder[parts[i]]
			else:
				found = false
				break
		# only restore variables that still exist in the project (`l_name` as to not shadow `name`)
		var l_name := parts[parts.size() - 1]
		if found and folder.has(l_name):
			folder[l_name] = vars[path]

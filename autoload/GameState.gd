extends Node

const SAVE_PATH := "user://player_state.json"

enum DataKey {
	PLAYER_POSITION
}

## Only keys listed here are saved and loaded. The values are the defaults.
## NOTE: when too many values are added to this list just start creating classes/objects to nest them under
## ```
## var data: Dictionary = {
## 	PLAYER_POSITION: Vector3(0, 0, 8),
##  SETTINGS: { "fov": 90, "dpi_scaler": 1.5, "color_blindness": Blind.RED_BLUE }
## }
## ```
var data: Dictionary = {
	"player_global_position": Vector3(0, 0, 8),
}

func save_to_disk(path: String = SAVE_PATH) -> Error:
	var out := { "data": { }, "dialogic": { } }
	for key in data:
		out["data"][key] = var_to_str(data[key])
	var vars := _get_dialogic_vars()
	for key in vars:
		out["dialogic"][key] = var_to_str(vars[key])

	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(out, "\t"))
	return OK

func load_from_disk(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return false

	# only keys that exist in `data` are restored, everything else is ignored
	var saved: Dictionary = parsed.get("data", { })
	for key in data:
		if saved.has(key):
			data[key] = str_to_var(saved[key])

	var loaded := { }
	var saved_vars: Dictionary = parsed.get("dialogic", { })
	for key in saved_vars:
		loaded[key] = str_to_var(saved_vars[key])
	_set_dialogic_vars(loaded)
	return true

# Dialogic
# Variables live in Dialogic.VAR.var_storage, a nested dict:
#   { "michael": { "RESPECT": 0 }, "misc": { "GuestName": "" } }
# They're saved flat by dotted path ("michael.RESPECT").

func _get_dialogic_vars() -> Dictionary:
	# untyped on purpose: looked up by path so this still parses without the plugin
	var d = get_node_or_null("/root/Dialogic")
	var out := { }
	if d == null:
		push_warning("PlayerState: /root/Dialogic not found, is the plugin enabled?")
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
		push_warning("PlayerState: /root/Dialogic not found, skipping Dialogic variables")
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

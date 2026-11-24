extends Node

enum NPC {
	BARTENDER,
	OVERWORKER,
	SINGER,
	HOBO,
	COUPLE_GUY,
	COUPLE_GIRL,
	ENKI,
	CHILD,
	RAT
}

const _TALKED_TO := "GLOBAL.TALKED_TO"
const _HAS_FOUGHT := "GLOBAL.HAS_FOUGHT"
const _DOOR_LOCKED := "GLOBAL.DOOR_LOCKED"

func _has(var_path: String, key: int) -> bool:
	return _read(var_path).has(key)

func _extra(var_path: String, key: int, default: Variant = null) -> Variant:
	return _read(var_path).get(key, default)

func _set_var(var_path: String, key: int, present: bool, extra: Variant = true) -> void:
	var dict := _read(var_path)
	if present:
		dict[key] = extra
	elif not dict.erase(key):
		return
	Dialogic.VAR.set_variable(var_path, var_to_str(dict))

func _read(var_path: String) -> Dictionary:
	var raw: Variant = Dialogic.VAR.get_variable(var_path, "")
	if raw is String and not raw.is_empty():
		var parsed: Variant = str_to_var(raw)
		if parsed is Dictionary:
			return parsed
	return {}

# SECTION: Public Interfaces (Unique to flags so they read nicer)
# functions are not inline bc for some reason it fucks with the shitty LSP

# Interaction
func has_talked_to(npc: NPC) -> bool:
	return _has(_TALKED_TO, npc)
func set_talked_to(npc: NPC, met: bool = true) -> void:
	_set_var(_TALKED_TO, npc, met)

# Fighting
func has_fought(npc: NPC) -> bool:
	return _has(_HAS_FOUGHT, npc)
func has_won_fight(npc: NPC) -> bool:
	return _extra(_HAS_FOUGHT, npc, false)
func set_fought(npc: NPC, won: bool) -> void:
	_set_var(_HAS_FOUGHT, npc, true, won)
func clear_fought(npc: NPC) -> void:
	_set_var(_HAS_FOUGHT, npc, false)

# Door
func is_door_locked(npc: NPC) -> bool:
	return _has(_DOOR_LOCKED, npc)
func set_door_locked(npc: NPC, locked: bool = true) -> void:
	_set_var(_DOOR_LOCKED, npc, locked)

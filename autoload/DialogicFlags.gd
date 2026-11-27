extends Node

enum Npc {
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

enum EmotionalState {
	NEUTRAL,
	SAD,
	ANNOYED,
	ANGRY,
	HAPPY,
}

const _TALKED_TO := "GLOBAL.TALKED_TO"
const _HAS_FOUGHT := "GLOBAL.HAS_FOUGHT"
const _DOOR_LOCKED := "GLOBAL.DOOR_LOCKED"
const _EMOTIONAL_STATE := "GLOBAL.EMOTIONAL_STATE"
const _HAPPY_ENDING := "GLOBAL.HAPPY_ENDING"

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
func has_talked_to(npc: Npc) -> bool:
	return _has(_TALKED_TO, npc)
func set_talked_to(npc: Npc, met: bool = true) -> void:
	_set_var(_TALKED_TO, npc, met)

# Fighting
func has_fought(npc: Npc) -> bool:
	return _has(_HAS_FOUGHT, npc)
func has_won_fight(npc: Npc) -> bool:
	return _extra(_HAS_FOUGHT, npc, false)
func set_fought(npc: Npc, won: bool) -> void:
	_set_var(_HAS_FOUGHT, npc, true, won)
func clear_fought(npc: Npc) -> void:
	_set_var(_HAS_FOUGHT, npc, false)

# Door
func is_door_locked(npc: Npc) -> bool:
	return _has(_DOOR_LOCKED, npc)
func set_door_locked(npc: Npc, locked: bool = true) -> void:
	_set_var(_DOOR_LOCKED, npc, locked)

# Emotional State
func is_current_emotional_state(npc: Npc, emotion: EmotionalState) -> bool:
	return _extra(_EMOTIONAL_STATE, npc, EmotionalState.NEUTRAL) == emotion
func set_emotional_state(npc: Npc, emotion: EmotionalState) -> void:
	_set_var(_EMOTIONAL_STATE, npc, true, emotion)


# Happy Ending
func has_reached_happy_ending(npc: Npc) -> bool:
	return _has(_HAPPY_ENDING, npc)
func set_happy_ending(npc: Npc, happy: bool = true) -> void:
	_set_var(_HAPPY_ENDING, npc, happy)

# SECTION: Dialogic-facing wrappers (take Npc / state names as strings)

func _npc(npc_name: String) -> Npc:
	assert(Npc.has(npc_name), "unknown npc: " + npc_name)
	return Npc[npc_name]

func _emotion(emotion_name: String) -> EmotionalState:
	assert(EmotionalState.has(emotion_name), "unknown emotion: " + emotion_name)
	return EmotionalState[emotion_name]

# Interaction
func talked_to(npc_name: String) -> bool:
	return has_talked_to(_npc(npc_name))
func set_talked(npc_name: String, met: bool = true) -> void:
	set_talked_to(_npc(npc_name), met)

# Fighting
func fought(npc_name: String) -> bool:
	return has_fought(_npc(npc_name))
func won_fight(npc_name: String) -> bool:
	return has_won_fight(_npc(npc_name))
func set_fight(npc_name: String, won: bool) -> void:
	set_fought(_npc(npc_name), won)
func clear_fight(npc_name: String) -> void:
	clear_fought(_npc(npc_name))

# Door
func door_locked(npc_name: String) -> bool:
	return is_door_locked(_npc(npc_name))
func lock_door(npc_name: String, locked: bool = true) -> void:
	set_door_locked(_npc(npc_name), locked)

# Emotional State
func feels(npc_name: String, emotion_name: String) -> bool:
	return is_current_emotional_state(_npc(npc_name), _emotion(emotion_name))
func set_feels(npc_name: String, emotion_name: String) -> void:
	set_emotional_state(_npc(npc_name), _emotion(emotion_name))

# Happy Ending
func reached_happy_ending(npc_name: String) -> bool:
	return has_reached_happy_ending(_npc(npc_name))
func set_is_happy_ending(npc_name: String, happy: bool = true) -> void:
	set_happy_ending(_npc(npc_name), happy)

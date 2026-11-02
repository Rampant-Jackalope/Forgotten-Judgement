class_name InputStash
static var _stashed := { }

static func disable_action(action: StringName) -> void:
	if _stashed.has(action):
		return
	_stashed[action] = InputMap.action_get_events(action)
	InputMap.action_erase_events(action)

static func enable_action(action: StringName) -> void:
	if not _stashed.has(action):
		return
	for ev in _stashed[action]:
		InputMap.action_add_event(action, ev)
	_stashed.erase(action)

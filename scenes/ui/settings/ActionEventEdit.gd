class_name ActionEventEdit extends TextEdit

@export var reset_button: Button

@export var action: StringName
var _default_event: InputEvent
var _current_event: InputEvent:
	set(event):
		_current_event = event

		var is_default = event == _default_event or (event and _default_event and event.is_match(_default_event))

		self.text = event.as_text() if event else "Unset"
		reset_button.visible = !is_default

		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event if event else _default_event)

		if is_default:
			Settings.controls.erase(action)
		else:
			Settings.controls.set(action, event)

var _was_focused: bool = false
var _focused: bool = false:
	set(value):
		_focused = value
		set_deferred("_was_focused", value)

func _enter_tree() -> void:
	assert(reset_button)
	assert(action)
	assert(InputMap.get_action_description(action))

	self.placeholder_text = "Press any key"
	self.selecting_enabled = false
	self.drag_and_drop_selection_enabled = false
	self.scroll_fit_content_width = true
	self.scroll_fit_content_height = true

	var events = ProjectSettings.get_setting("input/" + action).events
	if events.size() > 1: push_warning("Action '%s' has multiple events; will cause undefined behaviour" % action)

	if not events.is_empty():
		_default_event = events[0]

	if Settings.controls.has(action):
		_current_event = Settings.controls[action]
	else:
		_current_event = _default_event

	self.focus_entered.connect(func(): _focused = true)
	self.focus_exited.connect(func(): _focused = false)

	self.focus_entered.connect(func(): self.text = "")

	reset_button.pressed.connect(reset)

func _input(event: InputEvent) -> void:
	if not _focused: return

	if not (event is InputEventKey or event is InputEventMouseButton): return

	if event is InputEventKey and event.keycode in [
		Key.KEY_CTRL,
		Key.KEY_SHIFT,
		Key.KEY_META,
		Key.KEY_ALT,
	] and event.is_pressed(): return
	elif not event.is_pressed(): return

	self.release_focus()
	_current_event = event
func _gui_input(event: InputEvent) -> void:
	if _was_focused and event is InputEventMouseButton: _input(event)

func reset() -> void:
	_current_event = _default_event
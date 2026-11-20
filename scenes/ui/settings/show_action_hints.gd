extends Control

@export var input: CheckButton

func _enter_tree() -> void:
	assert(input)

	input.button_pressed = Settings.show_action_hints
	input.toggled.connect(func(v): Settings.show_action_hints = v)

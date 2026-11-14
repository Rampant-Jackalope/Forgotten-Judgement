extends Control

@export var input: CheckButton

func _enter_tree() -> void:
	assert(input)

	input.button_pressed = Settings.quick_restart
	input.toggled.connect(func(v): Settings.quick_restart = v)

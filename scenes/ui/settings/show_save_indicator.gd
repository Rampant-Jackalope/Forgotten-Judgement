extends Control

@export var input: CheckButton

func _enter_tree() -> void:
	assert(input)

	input.button_pressed = Settings.show_save_indicator
	input.toggled.connect(func(v): Settings.show_save_indicator = v)

extends Control

@export var input: OptionButton

func _enter_tree() -> void:
	assert(input)

	input.selected = Settings.window_mode
	input.item_selected.connect(func(v): Settings.window_mode = v as Settings.WindowMode)

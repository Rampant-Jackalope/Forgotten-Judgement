extends Control

@export var input: OptionButton

func _enter_tree() -> void:
	assert(input)

	input.selected = Settings.anti_aliasing
	input.item_selected.connect(func(v): Settings.anti_aliasing = v as Settings.AntiAliasingMode)

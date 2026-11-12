extends Control

@export var input: OptionButton

func _enter_tree() -> void:
	assert(input)

	input.selected = Settings.v_sync
	input.item_selected.connect(func(v): Settings.v_sync = v as Settings.VSyncMode)

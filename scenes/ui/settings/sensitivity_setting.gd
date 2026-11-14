extends Control

@export var input: SpinBox

func _enter_tree() -> void:
	assert(input)

	input.value = Settings.sensitivity
	input.value_changed.connect(func(v): Settings.sensitivity = v)

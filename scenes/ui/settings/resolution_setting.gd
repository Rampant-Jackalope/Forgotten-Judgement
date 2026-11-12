extends Control

@export var input_x: SpinBox
@export var input_y: SpinBox

func _enter_tree() -> void:
	assert(input_x)
	assert(input_y)

	input_x.value = Settings.resolution.x
	input_y.value = Settings.resolution.y

	input_x.value_changed.connect(func(x): Settings.resolution.x = x)
	input_y.value_changed.connect(func(y): Settings.resolution.y = y)

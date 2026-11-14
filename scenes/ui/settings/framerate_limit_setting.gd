extends Control

@export var input: SpinBox

func _enter_tree() -> void:
	assert(input)

	input.value = Settings.framerate_limit
	input.value_changed.connect(func(v): Settings.framerate_limit = v)
	# update_input_display.call_deferred()
	# input.value_changed.connect(update_input_display, CONNECT_DEFERRED)

# func update_input_display():
# 	var v = input.value
# 	print(v)
# 	input.get_line_edit().text = "Unlimited" if v <= 0.0 else str(v)

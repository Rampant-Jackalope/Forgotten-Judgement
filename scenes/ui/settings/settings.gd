extends Control

func close():
	queue_free()
	Settings.save_settings.call_deferred()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
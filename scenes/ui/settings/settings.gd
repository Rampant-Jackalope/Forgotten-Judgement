extends Control

func close():
	queue_free()
	Settings.save_settings.call_deferred()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		close()

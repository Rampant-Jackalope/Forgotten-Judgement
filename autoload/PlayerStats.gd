extends Node

# Dialogic variables (define APATHY and EMPATHY as numbers in the Dialogic variables editor)
const APATHY := "GLOBAL.APATHY"
const EMPATHY := "GLOBAL.EMPATHY"

func get_apathy() -> int:
	return int(Dialogic.VAR.get_variable(APATHY))

func get_empathy() -> int:
	return int(Dialogic.VAR.get_variable(EMPATHY))

func add_apathy(amount: int = 1) -> void:
	Dialogic.VAR.set_variable(APATHY, get_apathy() + amount)
	_debug_popup("+%d Apathy" % amount, Color.RED)

func add_empathy(amount: int = 1) -> void:
	Dialogic.VAR.set_variable(EMPATHY, get_empathy() + amount)
	_debug_popup("+%d Empathy" % amount, Color.GREEN)

func _debug_popup(text: String, color: Color) -> void:
	if not OS.is_debug_build():
		return
	var scene := get_tree().current_scene
	if not scene:
		return

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", color)
	label.position = Vector2(20, 20)
	scene.add_child(label)

	var tween := label.create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(label.queue_free)

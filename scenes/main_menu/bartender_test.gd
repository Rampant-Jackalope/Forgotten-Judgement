extends Node

# Vul hier de exacte naam van je Dialogic Timeline in
@export var timeline_name: String = "bartender_timeline"

func _ready() -> void:
	# Start de Dialogic storyline
	Dialogic.start("timelines/timeline")

func _input(event: InputEvent) -> void:
	# Sluit de game direct af bij het indrukken van ESC
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

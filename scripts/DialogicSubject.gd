class_name DialogicSubject
extends Node

@export var subject: String

func _ready() -> void:
	if subject == null:
		return push_error("No subject given")
	Dialogic.signal_event.connect(func(info):
		if info.subject == subject:
			recieved.emit(info.action)
	)

signal recieved(action: String)

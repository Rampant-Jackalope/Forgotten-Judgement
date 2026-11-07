class_name PopupDef
extends RefCounted
## A popup to show which Dialogic timeline to run and starting at which label.


var timeline : String
var label : String

func _init(p_timeline : String, p_label: String) -> void:
	timeline = p_timeline
	label = p_label

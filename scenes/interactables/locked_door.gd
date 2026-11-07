extends "res://scenes/interactables/open_close_door.gd"
## An open/close door that only opens while the Dialogic variable `flag` is true.
## Otherwise it plays `locked_label` from `locked_timeline`.

@export var flag: String = "" ## Dialogic variable, e.g. "singer.HAS_STAGE_KEY"
@export var locked_timeline: String = "misc-popups"
@export var locked_label: String = "" ## Label in locked_timeline, e.g. "backstage_door_locked"


func _ready() -> void:
	super()
	assert(Dialogic.VAR.has(flag), "LockedDoor '%s': unknown Dialogic variable '%s'" % [name, flag])
	assert(locked_label != "", "LockedDoor '%s': no locked_label set" % name)


func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	if not Dialogic.VAR.get_variable(flag):
		interactor.player.run_locked_dialogue(locked_timeline, locked_label)
		return
	super(interactor, pop)

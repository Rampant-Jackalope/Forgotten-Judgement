extends "res://scenes/interactables/open_close_door.gd"
## An open/close door that only opens while the Dialogic variable `flag` is true.
## Otherwise it plays `locked_label` from `locked_timeline`.

@export var key_item_id: StringName ## Item ID of the unlocking key
@export var locked_timeline: String = "misc-popups"
@export var locked_label: String = "" ## Label in locked_timeline, e.g. "backstage_door_locked"

var _locked: bool = true

func _ready() -> void:
	super()
	assert(locked_label != "", "LockedDoor '%s': no locked_label set" % name)

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	if _locked:
		if Inventory.has_item(key_item_id):
			Inventory.remove(key_item_id)
			_locked = false
		else:
			interactor.player.run_locked_dialogue(locked_timeline, locked_label)
			return
	super(interactor, pop)
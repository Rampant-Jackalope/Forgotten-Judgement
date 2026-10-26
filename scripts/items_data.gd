class_name ItemData
extends Resource
## Definition of an item type. Shared between every reference, so NO per-instance state here.
## Create one .tres per item (e.g. resources/backstage_key.tres, type = Resource, script = this).

@export var id: StringName ## Stable key for code/Dialogic checks, e.g. &"backstage_key"
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var world_scene: PackedScene ## Optional: model/pickup scene, for dropping or holding the item

## Override in subclasses for items that do something when used.
## Return true if the item was consumed.
func use(_user: Node) -> bool:
	return false

## Single place for the "Name\nDescription" text that hotbar.gd and menu-buttons.gd both build by hand.
func get_display_text() -> String:
	var n := item_name if item_name != "" else "Item"
	return n if description == "" else n + "\n" + description

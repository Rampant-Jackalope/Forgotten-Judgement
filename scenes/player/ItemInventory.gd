class_name ItemInventory
extends Node
## Single owner of "what am I holding". UI (hotbar, pause menu) only listens to signals.
## Note: I registered as autoload "Inventory", but perhaps it also works if you just make it a child of the player.
# TODO: add inventory as child of player instead of autoload.

@export var slot_count := 3

signal slot_changed(index: int, item: ItemData)   ## emitted whenever a slot's contents change
signal selected_changed(index: int, item: ItemData)

var slots: Array[ItemData] = []
var selected_index: int = 0

func _ready() -> void:
	slots.resize(slot_count) # all null

func add(item: ItemData) -> bool:
	assert(item != null, "ItemInventory.add() called with null")
	var i := slots.find(null)
	if i == -1:
		return false # full
	slots[i] = item
	slot_changed.emit(i, item)
	if i == selected_index:
		selected_changed.emit(i, item)
	return true

func remove(id: StringName) -> bool:
	var i := _find_item_index(id)
	if i == -1:
		return false
	slots[i] = null
	slot_changed.emit(i, null)
	if i == selected_index:
		selected_changed.emit(i, null)
	return true

func has_item(id: StringName) -> bool:
	return _find_item_index(id) != -1

func select(index: int) -> void:
	assert(index >= 0 and index < slot_count, "slot index out of range")
	selected_index = index
	selected_changed.emit(index, slots[index])

func get_selected() -> ItemData:
	return slots[selected_index]

## Use the held item. Consumed items are removed.
## Note: I wonder about the semantics of "use" vs "consume".
func use_selected(user: Node) -> void:
	var item := get_selected()
	if item != null and item.use(user):
		slots[selected_index] = null
		slot_changed.emit(selected_index, null)
		selected_changed.emit(selected_index, null)

func _find_item_index(id: StringName) -> int:
	for i in slots.size():
		if slots[i] != null and slots[i].id == id:
			return i
	return -1

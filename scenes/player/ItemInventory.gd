class_name ItemInventory
extends Node

var items: Array[Item] = []

func add_item(item: Item) -> void:
	items[items.size()] = item

func has_item(id: String) -> bool:
	return false # TODO: Implement

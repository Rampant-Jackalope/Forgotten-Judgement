@abstract class_name Item
extends Area3D

# When a player actually interacts with an item it should grab the first item in the queue.
# Instead of running its own intended behavior, this is to avoid two items being active at the same time.
# NOTE: fucking doubt any items will be placed near each other to where this will be needed
# also even if that would happen, this could make it annoying if you want to pick up a specific item
static var interaction_queue: ItemQueue = ItemQueue.new()

@export var item_icon: Texture2D = null

var is_highlighted: bool = false

# shitty wrapper to enforce push for Queue-like behavior
class ItemQueue:
	var arr: Array[Item] = []

	func push(item: Item) -> void:
		arr.push_back(item)

	func pop() -> Item:
		return arr.pop_back()

	func peek() -> Item:
		return arr[0]

	func peek_back() -> Item:
		return arr[arr.size() - 1]

	func erase(item: Item) -> void:
		arr.erase(item)

	func is_priority(item: Item) -> bool:
		return arr.find(item) == 0

	func get_arr() -> Array:
		return arr

	func size() -> int:
		return arr.size()

func _enter_tree() -> void:
	self.area_entered.connect(
		func(_area: Area3D) -> void:
			Item.interaction_queue.push(self),
	)
	self.area_exited.connect(
		func(_area: Area3D) -> void:
			Item.interaction_queue.erase(self),
	)

func _process(_delta: float) -> void:
	process_interaction()
	process_highlight()

# ------------------
# boilerplate functions to throw into _process() or wherever, when an item needs custom _process() behavior


# TODO: potentially fix after get_player() stub is fixed
func process_interaction() -> void:
	if Input.is_action_just_pressed("interact"):
		if Util.get_player().get_interaction_range().overlaps_area(self):
			Item.interaction_queue.pop().run_interaction()

func process_highlight() -> void:
	var should_be_highlighted = Item.interaction_queue.is_priority(self)

	if should_be_highlighted != self.is_highlighted:
		if should_be_highlighted:
			_highlight_on()
		else:
			_highlight_off()

# ------------------
# Public && Abstract functions
# aka just throw shit in here that other APIs need such as QOL `Obtained Items` interface

func get_item_icon() -> Texture2D:
	return self.item_icon

@abstract func run_interaction() -> void

# Abstract cuzz I ain't doing highlighting rn
@abstract func _highlight_off() -> void

# Abstract cuzz I ain't doing highlighting rn
@abstract func _highlight_on() -> void

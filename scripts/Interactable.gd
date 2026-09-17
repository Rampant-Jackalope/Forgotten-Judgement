class_name Interactable
extends Area3D

@export var look_target: Node3D ## Node3D that the player looks at when interacting

# When a player actually interacts with an item it should grab the first item in the queue.
# Instead of running its own intended behavior, this is to avoid two items being active at the same time.
# NOTE: fucking doubt any items will be placed near each other to where this will be needed
# also even if that would happen, this could make it annoying if you want to pick up a specific item
static var interaction_queue: InteractQueue = InteractQueue.new()

var is_highlighted: bool = false

# shitty wrapper to enforce push for Queue-like behavior
class InteractQueue:
	var arr: Array[Interactable] = []

	func push(item: Interactable) -> void:
		arr.push_back(item)

	func pop() -> Interactable:
		return arr.pop_back()

	func peek() -> Interactable:
		if arr.size() > 0:
			return arr[0]
		else:
			return null

	func peek_back() -> Interactable:
		return arr[arr.size() - 1]

	func erase(item: Interactable) -> void:
		arr.erase(item)

	func is_priority(item: Interactable) -> bool:
		return arr.find(item) == 0

	func get_arr() -> Array:
		return arr

	func size() -> int:
		return arr.size()

func _enter_tree() -> void:
	self.area_entered.connect(
		func(_area: Area3D) -> void:
			Interactable.interaction_queue.push(self),
	)
	self.area_exited.connect(
		func(_area: Area3D) -> void:
			Interactable.interaction_queue.erase(self),
	)
	self.collision_mask = 1 << 2
	self.collision_layer = 1 << 2

	if look_target != null:
		self.interacted.connect(func(interactor: Interactor, _pop):
			var controller: PlayerController3D = interactor.get_node("../PlayerController3D")
			if controller != null:
				controller.smooth_look_at(look_target.global_position)
		)

func _process(_delta: float) -> void:
	process_interaction()
	process_highlight()

# ------------------
# boilerplate functions to throw into _process() or wherever, when an item needs custom _process() behavior

func process_interaction() -> void:
	if Input.is_action_just_pressed("interact"):
		if Interactable.interaction_queue.size() > 0:
			var val := Interactable.interaction_queue.peek()
			if val != null:
				val.interacted.emit(Util.get_player().get_node("Player3D").interactor, Interactable.interaction_queue.pop)

func process_highlight() -> void:
	var should_be_highlighted = Interactable.interaction_queue.is_priority(self)

	if should_be_highlighted != self.is_highlighted:
		if should_be_highlighted:
			highlight_on.emit()
		else:
			highlight_off.emit()

# ------------------
# Public && Abstract functions
# aka just throw shit in here that other APIs need such as QOL `Obtained Items` interface

func get_item_icon() -> Texture2D:
	return self.item_icon

signal interacted(interactor: Interactor, pop: Callable)

# Abstract cuzz I ain't doing highlighting rn
signal highlight_off()

# Abstract cuzz I ain't doing highlighting rn
signal highlight_on()

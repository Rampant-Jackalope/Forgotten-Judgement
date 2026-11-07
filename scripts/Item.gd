class_name Item
extends Node3D
## > [!NOTE]
## > the following should be a children of this Item node:
## >   Model / Sprite3D
## >   , HighlightSprite (Sprite3D) -> assign to highlight_sprite
## >   , Interactable (Area3D, Interactable.gd) + CollisionShape3D -> assign to interactable

@export var data: ItemData
@export var interactable: Interactable
@export var highlight_sprite: Sprite3D

## Override this to define if an item can spawn in the world or not.
## For stuff such as unique items that can only be spawned once or have already been consumed.
func _can_spawn() -> bool:
	return !Inventory.has_item(data.id)

func _ready() -> void:
	assert(data != null, "Item '%s' has no ItemData assigned." % name)
	assert(interactable != null, "Item '%s' has no Interactable assigned." % name)

	if !_can_spawn():
		queue_free()

	if highlight_sprite != null:
		highlight_sprite.hide()
		interactable.highlight_on.connect(highlight_sprite.show)
		interactable.highlight_off.connect(highlight_sprite.hide)

	interactable.interacted.connect(_on_interacted)

func _on_interacted(_interactor: Interactor, pop: Callable) -> void:
	if Inventory.add(data): # autoload; swap for Util.get_player().inventory if you prefer
		pop.call()          # remove from the interaction queue so it can't fire again
		queue_free()
	else:
		Util.show_temp_richlabel(self, "Inventory full") # reuse existing helper

func get_item_icon() -> Texture2D:
	return data.icon

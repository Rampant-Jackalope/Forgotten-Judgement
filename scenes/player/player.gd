class_name Player
extends CharacterBody3D

@onready var controller: PlayerController = PlayerController.new()
@onready var interactor: Interactor = Interactor.new()
@onready var inventory: ItemInventory = ItemInventory.new()

func _ready() -> void:
	controller.cam_pivot = $CamPivot
	controller.camera = $CamPivot/Camera3D
	controller.collider = $CollisionShape3D
	controller.body = self

	add_child(controller)
	add_child(interactor)
	add_child(inventory)

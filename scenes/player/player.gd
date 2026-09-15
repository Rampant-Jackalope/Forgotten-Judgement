class_name Player
extends CharacterBody3D

func _ready() -> void:
	var controller = PlayerController.new()
	controller.cam_pivot = $CamPivot
	controller.camera = $CamPivot/Camera3D
	controller.collider = $CollisionShape3D
	controller.body = self
	var interactor = Interactor.new()
	var inventory = ItemInventory.new()

	add_child(controller)
	add_child(interactor)
	add_child(inventory)

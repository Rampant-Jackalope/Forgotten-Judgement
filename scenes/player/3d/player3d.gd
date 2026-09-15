class_name Player3D
extends CharacterBody3D

@onready var controller: PlayerController3D = PlayerController3D.new()
@onready var interactor: Interactor = Interactor.new()

func _ready() -> void:
	controller.cam_pivot = $CamPivot
	controller.camera = $CamPivot/Camera3D
	controller.collider = $CollisionShape3D
	controller.body = self

	add_child(controller)
	add_child(interactor)

func activate() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_INHERIT
	$crosshair.show() # for some reason it does not inherit the parent's visibility
	show()

func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	$crosshair.hide() # for some reason it does not inherit the parent's visibility
	hide()

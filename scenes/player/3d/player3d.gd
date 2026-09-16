class_name Player3D
extends CharacterBody3D

@onready var controller: PlayerController3D = $PlayerController3D
@onready var interactor: Interactor = Interactor.new()

func _ready() -> void:
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

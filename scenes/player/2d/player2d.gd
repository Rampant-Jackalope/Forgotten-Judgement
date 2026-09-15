class_name Player2D
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var controller: PlayerController2D = PlayerController2D.new()

func _ready() -> void:
	add_child(controller)
	controller.assign_body(self)
	controller.assign_sprite(sprite)

func activate() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	process_mode = Node.PROCESS_MODE_INHERIT
	show()

func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

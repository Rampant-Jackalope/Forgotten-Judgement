class_name Player2D
extends CharacterBody2D

func activate() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	process_mode = Node.PROCESS_MODE_INHERIT
	show()

func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

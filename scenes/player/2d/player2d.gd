class_name Player2D
extends CharacterBody2D

func _process(_delta: float) -> void:
	pass

func activate() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	process_mode = Node.PROCESS_MODE_INHERIT
	show()

func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

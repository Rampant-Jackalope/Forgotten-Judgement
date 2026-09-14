extends Node3D

@onready var child := self.get_child(0)

func _ready() -> void:
	child.left_clicked.connect(_on_interactable_door_left_clicked)

func _on_interactable_door_left_clicked(_hit_position: Vector3, _normal: Vector3) -> void:
	Util.run_locked_dialogue("misc-popups", "exit_door_locked")
	Dialogic.VAR.bartender.TRIED_TO_EXIT = true

extends Node3D

@onready var child := self.get_child(0)

func _ready() -> void:
	child.toggle()

func _on_interactable_door_left_clicked(hit_position: Vector3, normal: Vector3) -> void:
	child.toggle()

extends Node

@onready var child := get_child(0)

func _ready() -> void:
	child.left_clicked.connect(_on_interactable_door_left_clicked)

func _on_interactable_door_left_clicked(_hit_position: Vector3, _normal: Vector3) -> void:
	Util.show_temp_richlabel(self, "[color=orange]Beep Boop you are teleported to " + self.name + "'s room[/color]")

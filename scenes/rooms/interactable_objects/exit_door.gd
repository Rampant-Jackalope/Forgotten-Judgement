extends Node3D

@onready var child := self.get_child(0)

func _ready() -> void:
	child.left_clicked.connect(_on_interactable_door_left_clicked)

func _on_interactable_door_left_clicked(hit_position: Vector3, normal: Vector3) -> void:
	var text: String = "[color=red]The door is locked[/color]"
	Util.show_temp_richlabel(self, text)
	Dialogic.VAR.set("TRIED_TO_EXIT", true)

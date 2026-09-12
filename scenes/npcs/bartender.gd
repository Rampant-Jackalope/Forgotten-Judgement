extends Node3D

func _on_interactable_3d_left_clicked(_hit_position: Vector3, _normal: Vector3) -> void:
	Util.run_locked_dialogue("bartender/main")

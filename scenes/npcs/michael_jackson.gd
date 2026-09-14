extends Node3D

func _on_interactable_3d_left_clicked(hit_position: Vector3, normal: Vector3) -> void:
	Util.run_locked_dialogue("michael_jackson/main")

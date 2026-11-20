extends Node3D

@export var mesh: MeshInstance3D

func _ready() -> void:
	assert(mesh != null, "No MeshInstance3D assigned")

func _on_interactable_interacted(interactor: Interactor, _pop: Callable) -> void:
	var player = interactor.player as Player3D
	player.run_locked_dialogue("misc-popups", "lethe_interaction")

func _on_interactable_highlight_on() -> void:
	mesh.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	mesh.set_instance_shader_parameter("enabled", false)

extends Node3D

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE PreSylizedButton
# THIS IS BECAUSE THE HIGHLIGHT SHADER NEEDS TO BE CONNECTED TO THE 'Button' MESH

@onready var animation_player: AnimationPlayer = get_node("PreSylizedButton/AnimationPlayer")
@onready var button_mesh = get_node("PreSylizedButton/Button")

func _ready() -> void:
	assert(animation_player, "Could not locate AnimationPlayer on mounted button")
	assert(button_mesh, "Could not locate Button Mesh on mounted button")

signal button_pressed(button: Node3D, interactor: Interactor, pop: Callable)

func _on_interactable_highlight_on() -> void:
	button_mesh.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	button_mesh.set_instance_shader_parameter("enabled", false)

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	if !animation_player.is_playing():
		animation_player.play("Press")
		await animation_player.animation_finished

	button_pressed.emit(self, interactor, pop)

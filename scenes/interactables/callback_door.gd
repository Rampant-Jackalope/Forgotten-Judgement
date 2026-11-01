extends Node3D

@onready var animation_player = get_node("DoorAnimated/AnimationPlayer")
@onready var door_mesh = get_node("DoorAnimated/Door")

@export var invert_open_direction: bool = false 

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone'/'mesh' NODE.

signal interacted(door: Node3D, interactor: Interactor, pop: Callable)

func _ready():
	assert(animation_player != null, "Animation player not found")
	assert(door_mesh != null, "Door mesh not found")

	# ensure correct state 
	animation_player.play_backwards("Open_neg")
	_on_interactable_highlight_off()

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	interacted.emit(self, interactor, pop)

func _on_interactable_highlight_on() -> void:
	door_mesh.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	door_mesh.set_instance_shader_parameter("enabled", false)

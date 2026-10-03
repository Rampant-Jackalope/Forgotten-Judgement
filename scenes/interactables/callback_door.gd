extends Node3D

@onready var animation_player = get_node("Lone_Door_Animated/AnimationPlayer")
@onready var door_mesh = get_node("Lone_Door_Animated/Armature/Skeleton3D/Door")

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone' NODE.

# INFO: asset has wrong animation names.
# Renaming through code causes errors that I do not know how to resolve.
# These are the correct name -> actions
# Open -> Closed State
# ArmatureAction -> Open Animation
@onready var closed_state := "Open"
@onready var open_animation := "ArmatureAction"

signal interacted(door: Node3D, interactor: Interactor, pop: Callable)

func _ready():
	assert(animation_player != null, "Animation player not found")
	assert(door_mesh != null, "Door mesh not found")

	# ensure correct state 
	animation_player.play(closed_state)
	_on_interactable_highlight_off()

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	interacted.emit(self, interactor, pop)

func _on_interactable_highlight_on() -> void:
	door_mesh.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	door_mesh.set_instance_shader_parameter("enabled", false)

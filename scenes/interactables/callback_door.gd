extends Node3D

@export var highlight_thickness = 2.0

@onready var animation_player = get_node("Lone_Door_Animated/AnimationPlayer")

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
	animation_player.play(closed_state) # ensure closed state 

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	interacted.emit(self, interactor, pop)

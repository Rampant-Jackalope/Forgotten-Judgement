extends Node3D

@export var highlight_thickness = 2.0

@onready var animation_player = get_node("Lone_Door_Animated/AnimationPlayer")

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone' NODE.

enum State {
	CLOSED,
	OPEN
}

var state = State.CLOSED

# INFO: asset has wrong animation names.
# Renaming through code causes errors that I do not know how to resolve.
# These are the correct name -> actions
# Open -> Closed State
# ArmatureAction -> Open Animation
@onready var _closed_state := "Open"
@onready var _open_animation := "ArmatureAction"

func _ready():
	assert(animation_player != null, "Animation player not found")
	animation_player.play(_closed_state) # ensure closed state 

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	if state == State.CLOSED:
		if !animation_player.is_playing():
			state = State.OPEN
			animation_player.play(_open_animation)
			await animation_player.animation_finished
	else:
		if !animation_player.is_playing():
			state = State.CLOSED
			animation_player.play_backwards(_open_animation)
			await animation_player.animation_finished

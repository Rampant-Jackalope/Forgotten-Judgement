extends Node3D

@onready var animation_player = get_node("DoorAnimated/AnimationPlayer")
@onready var door_mesh = get_node("DoorAnimated/Door")

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone'/'mesh' NODE.

enum State {
	CLOSED,
	OPEN,
}

var state = State.CLOSED

func _ready():
	assert(animation_player != null, "Animation player not found")
	assert(door_mesh != null, "Door mesh not found")

	# ensure correct state
	animation_player.play_backwards("Open")
	_on_interactable_highlight_off()

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	if state == State.CLOSED:
		if !animation_player.is_playing():
			state = State.OPEN
			animation_player.play("Open")
			await animation_player.animation_finished
	else:
		if !animation_player.is_playing():
			state = State.CLOSED
			animation_player.play_backwards("Open")
			await animation_player.animation_finished

func _on_interactable_highlight_on() -> void:
	door_mesh.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	door_mesh.set_instance_shader_parameter("enabled", false)

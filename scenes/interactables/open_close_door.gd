extends Node3D

@export var animation_player: AnimationPlayer
@export var door_mesh: MeshInstance3D
@export var collision_shape: CollisionShape3D
@export var invert_open_direction: bool = false 

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone'/'mesh' NODE.

enum State {
	CLOSED,
	OPEN,
}

var state = State.CLOSED

func get_animation() -> String:
	if self.invert_open_direction:
		return "Open_neg"
	
	return "Open_pos"

func _ready():
	assert(animation_player != null, "Animation player not found")
	assert(door_mesh != null, "Door mesh not found")

	_on_interactable_highlight_off()

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	if state == State.CLOSED:
		if !animation_player.is_playing():
			state = State.OPEN
			animation_player.play(get_animation())
			collision_shape.set_deferred("disabled", true)
			await animation_player.animation_finished
			collision_shape.set_deferred("disabled", false)
		return

	if !animation_player.is_playing():
		state = State.CLOSED
		animation_player.play_backwards(get_animation())
		collision_shape.set_deferred("disabled", true)
		await animation_player.animation_finished
		collision_shape.set_deferred("disabled", false)

func _on_interactable_highlight_on() -> void:
	door_mesh.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	door_mesh.set_instance_shader_parameter("enabled", false)

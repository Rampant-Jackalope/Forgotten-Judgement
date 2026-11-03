extends Node3D

@onready var animation_player_1 = get_node("R/AnimationPlayer")
@onready var animation_player_2 = get_node("L/AnimationPlayer")
@onready var door_mesh_1 = get_node("R/Door")
@onready var door_mesh_2 = get_node("L/Door")
@onready var collision_shape_1: CollisionShape3D = $R/Door/LookTarget/Interactable/CollisionShape3D
@onready var collision_shape_2: CollisionShape3D = $R/Door/LookTarget/Interactable/CollisionShape3D
var r_open = "Open_neg"
var l_open = "Open_pos"

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone'/'mesh' NODE.

enum State {
	CLOSED,
	OPEN,
}

var state = State.CLOSED

func _ready():
	assert(animation_player_1 != null, "Animation player 1 not found")
	assert(animation_player_2 != null, "Animation player 2  not found")
	assert(door_mesh_1 != null, "Door mesh 1 not found")
	assert(door_mesh_2 != null, "Door mesh 2 not found")

	_on_interactable_highlight_off()

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	if state == State.CLOSED:
		if !animation_player_1.is_playing() || !animation_player_1.is_playing():
			state = State.OPEN
			animation_player_1.play(r_open)
			animation_player_2.play(l_open)

			collision_shape_1.set_deferred("disabled", true)
			collision_shape_2.set_deferred("disabled", true)

			await animation_player_1.animation_finished
			await animation_player_2.animation_finished

			collision_shape_1.set_deferred("disabled", false)
			collision_shape_2.set_deferred("disabled", false)
		return

	if !animation_player_1.is_playing() || !animation_player_2.is_playing():
		state = State.CLOSED
		animation_player_1.play_backwards(r_open)
		animation_player_2.play_backwards(l_open)

		collision_shape_1.set_deferred("disabled", true)
		collision_shape_2.set_deferred("disabled", true)

		await animation_player_1.animation_finished
		await animation_player_2.animation_finished

		collision_shape_1.set_deferred("disabled", false)
		collision_shape_2.set_deferred("disabled", false)

func _on_interactable_highlight_on() -> void:
	door_mesh_1.set_instance_shader_parameter("enabled", true)
	door_mesh_2.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	door_mesh_1.set_instance_shader_parameter("enabled", false)
	door_mesh_2.set_instance_shader_parameter("enabled", false)

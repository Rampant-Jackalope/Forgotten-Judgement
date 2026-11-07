extends Node3D

@export var invert_open_direction: bool = false

@export_group("Right Door")
@export var animation_player_r: AnimationPlayer
@export var door_mesh_r: MeshInstance3D
@export var collision_shape_r: CollisionShape3D

@export_group("Left Door")
@export var animation_player_l: AnimationPlayer
@export var door_mesh_l: MeshInstance3D
@export var collision_shape_l: CollisionShape3D

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone'/'mesh' NODE.

enum State {
	CLOSED,
	OPEN,
}

var state = State.CLOSED

func _on_interactable_2_interacted(interactor: Interactor, pop: Callable) -> void:
	pass # Replace with function body.


class DoorAnimation:
	var R: String
	var L: String

	func _init(_r: String, _l: String) -> void:
		R = _r
		L = _l


func get_animation() -> DoorAnimation:
	if invert_open_direction:
		return DoorAnimation.new("Open_pos", "Open_neg")

	return DoorAnimation.new("Open_neg", "Open_pos")

func _ready():
	assert(animation_player_r != null, "Animation player R not found")
	assert(animation_player_l != null, "Animation player L not found")
	assert(animation_player_r != animation_player_l, "R and L share the same AnimationPlayer")
	assert(door_mesh_r != null, "Door mesh R not found")
	assert(door_mesh_l != null, "Door mesh L not found")
	assert(collision_shape_r != null, "Door Collision shape R not found")
	assert(collision_shape_l != null, "Door Collision shape L not found")

	_on_interactable_highlight_off()

func _is_animating() -> bool:
	return animation_player_r.is_playing() or animation_player_l.is_playing()

func _set_collision_disabled(value: bool) -> void:
	collision_shape_r.set_deferred("disabled", value)
	collision_shape_l.set_deferred("disabled", value)

# Only awaits a player that is still playing, so it can't hang
# on a signal that has already fired.
func _wait_for_animations() -> void:
	if animation_player_r.is_playing():
		await animation_player_r.animation_finished
	if animation_player_l.is_playing():
		await animation_player_l.animation_finished

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	if _is_animating():
		return

	var animation = get_animation()

	if state == State.CLOSED:
		state = State.OPEN
		animation_player_r.play(animation.R)
		animation_player_l.play(animation.L)
	else:
		state = State.CLOSED
		animation_player_r.play_backwards(animation.R)
		animation_player_l.play_backwards(animation.L)

	_set_collision_disabled(true)
	await _wait_for_animations()
	_set_collision_disabled(false)

func _on_interactable_highlight_on() -> void:
	door_mesh_r.set_instance_shader_parameter("enabled", true)
	door_mesh_l.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	door_mesh_r.set_instance_shader_parameter("enabled", false)
	door_mesh_l.set_instance_shader_parameter("enabled", false)

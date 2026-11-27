@tool
extends Node3D

@export var animation_player: AnimationPlayer
@export var door_mesh: MeshInstance3D
@export var invert_open_direction: bool = false

@export var a_color: Color = Color.RED:
	set(value):
		a_color = value
		_update_colors()

@export var b_color: Color = Color.GREEN:
	set(value):
		b_color = value
		_update_colors()

func _update_colors() -> void:
	if not is_inside_tree():
		return
	var a_shape := get_node_or_null("DoorAnimated/DoorAniimated/A/Interactable/CollisionShape3D") as CollisionShape3D
	var b_shape := get_node_or_null("DoorAnimated/DoorAniimated/B/Interactable/CollisionShape3D") as CollisionShape3D
	if a_shape:
		a_shape.debug_color = a_color
	if b_shape:
		b_shape.debug_color = b_color

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone'/'mesh' NODE.

signal b_interacted(door: Node3D, interactor: Interactor, pop: Callable)
signal a_interacted(door: Node3D, interactor: Interactor, pop: Callable)

func _ready():
	assert(animation_player != null, "Animation player not found")
	assert(door_mesh != null, "Door mesh not found")
	_update_colors()

	_on_interactable_highlight_off()

func _on_a_interact(interactor: Interactor, pop: Callable) -> void:
	a_interacted.emit(self, interactor, pop)

func _on_b_interact(interactor: Interactor, pop: Callable) -> void:
	b_interacted.emit(self, interactor, pop)

func _on_interactable_highlight_on() -> void:
	door_mesh.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	door_mesh.set_instance_shader_parameter("enabled", false)

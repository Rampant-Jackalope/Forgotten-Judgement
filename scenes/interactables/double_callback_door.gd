extends Node3D

@onready var door_r: Node3D = $R
@onready var door_l: Node3D = $L

@export_group("Right Door")
@export var door_mesh_r: MeshInstance3D
@export var collision_shape_r: CollisionShape3D

@export_group("Left Door")
@export var door_mesh_l: MeshInstance3D
@export var collision_shape_l: CollisionShape3D

signal interacted(door_l: Node3D, door_r: Node3D, interactor: Interactor, pop: Callable)

# NOTE:
# EDITABLE CHILDREN IS ON FOR THE Lone_Door_Animated
# THIS IS BECAUSE THE 'LookTarget' && 'Interactable' NEEDS TO FOLLOW THE DOOR ANIMATION AND THUS NEEDS TO BE UNDER THE 'Bone'/'mesh' NODE.

func _ready():
	assert(door_mesh_r != null, "Door mesh R not found")
	assert(door_mesh_l != null, "Door mesh L not found")
	assert(collision_shape_r != null, "Door Collision shape R not found")
	assert(collision_shape_l != null, "Door Collision shape L not found")

	_on_interactable_highlight_off()

func _set_collision_disabled(value: bool) -> void:
	collision_shape_r.set_deferred("disabled", value)
	collision_shape_l.set_deferred("disabled", value)

func _on_interactable_interacted(interactor: Interactor, pop: Callable) -> void:
	interacted.emit(door_l, door_r, interactor, pop)

func _on_interactable_highlight_on() -> void:
	door_mesh_r.set_instance_shader_parameter("enabled", true)
	door_mesh_l.set_instance_shader_parameter("enabled", true)

func _on_interactable_highlight_off() -> void:
	door_mesh_r.set_instance_shader_parameter("enabled", false)
	door_mesh_l.set_instance_shader_parameter("enabled", false)

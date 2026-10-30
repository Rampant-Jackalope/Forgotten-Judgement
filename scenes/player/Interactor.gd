class_name Interactor
extends Area3D

@export var player: CharacterBody3D ## Can be used by `Interactables` to access the player node

@export_flags_2d_physics var layer: int = 4
@export_flags_2d_physics var mask: int = 4

# Track the warning count here to prevent shared state issues across multiple overworkers
var warning_count: int = 0

func _ready() -> void:
	self.collision_mask = 4
	self.collision_layer = 4

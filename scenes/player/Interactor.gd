class_name Interactor
extends Node3D

@export var interaction_layer: int = 2

@export var interact_range: float = 3

@export var area_parent: Node3D = self

func _ready() -> void:
	var area = Area3D.new()
	area.collision_mask = 1 << interaction_layer

	var collision_shape = CollisionShape3D.new()

	var sphere = SphereShape3D.new()
	sphere.radius = interact_range

	area_parent.add_child(area)
	area.add_child(collision_shape)
	collision_shape.shape = sphere

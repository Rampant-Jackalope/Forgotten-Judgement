@tool
class_name ProjectileModifier
extends Node

## Reusable "juice" component. Drop instances of subclasses into a
## ProjectileBase's `modifiers` array in the inspector.

## Called once, right after the projectile enters the tree.
func start(_projectile: ProjectileBase) -> void:
	pass

## Called every physics frame, after apply_motion().
func process_modifier(_delta: float, _projectile: ProjectileBase) -> void:
	pass

## Shorthand for checking for life, this is to guard against timing issues cuzz fucking godot
static func is_alive(projectile: ProjectileBase) -> bool:
	return is_instance_valid(projectile) and projectile.is_inside_tree()

@tool
class_name ProjectileModifier
extends Node

## Reusable "juice" component. Drop instances of subclasses into a
## ProjectileBase's `modifiers` array in the inspector.
## This one is the generic version for ones that are not specific to fights.
## Called once, right after the projectile enters the tree.

func start(_projectile: ProjectileBase) -> void:
	pass

## Called every physics frame, after apply_motion().
func process_modifier(_delta: float, _projectile: ProjectileBase) -> void:
	pass

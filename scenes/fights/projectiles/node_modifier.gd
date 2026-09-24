@tool
class_name NodeModifier
extends Node

## Same contract as ProjectileModifier, but as a Node can be added as a child
## of a specific projectile scene. Used for one-off
## gimmick for a single fight and isn't worth making a reusable
## Resource for. ProjectileBase auto-detects children like this in
## _enter_tree and folds them into the same modifiers loop.

func start(_projectile: ProjectileBase) -> void:
	pass

func process_modifier(_delta: float, _projectile: ProjectileBase) -> void:
	pass

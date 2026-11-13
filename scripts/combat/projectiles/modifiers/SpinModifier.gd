@tool
class_name SpinModifier
extends ProjectileModifier

## Continuous rotation. Cheap way to make a static sprite read as
## "dangerous and moving fast" good on linear or homing projectiles.

@export var degrees_per_second: float = 360.0

func process_modifier(delta: float, projectile: ProjectileBase) -> void:
	projectile.rotation += deg_to_rad(degrees_per_second) * delta

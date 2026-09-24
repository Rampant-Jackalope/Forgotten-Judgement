@tool
class_name DelayedHitboxModifier
extends ProjectileModifier

@export var delay: float = 0.4
@export var active_time: float = 0.1

func start(projectile: ProjectileBase) -> void:
	var tween := projectile.get_tree().create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func() -> void:
		projectile.activate_hitbox()
	)
	tween.tween_interval(active_time)
	tween.tween_callback(func() -> void:
		projectile.deactivate_hitbox()
	)

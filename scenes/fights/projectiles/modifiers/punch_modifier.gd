@tool
class_name PunchModifier
extends ProjectileModifier

## Scales the projectile up toward the player, activates the hitbox right
## at the peak (the "punch" moment), then eases back down.

@export var peak_scale: float = 1.8
@export var scale_up_time: float = 0.25
@export var scale_down_time: float = 0.15
## How long the hitbox stays live once activated, at the apex.
@export var hitbox_active_time: float = 0.08

func start(projectile: ProjectileBase) -> void:
	var base_scale := projectile.scale
	var tween := projectile.get_tree().create_tween()
	tween.tween_property(projectile, "scale", base_scale * peak_scale, scale_up_time)
	tween.tween_callback(func() -> void:
		projectile.activate_hitbox()
	)
	tween.tween_interval(hitbox_active_time)
	tween.tween_callback(func() -> void:
		projectile.deactivate_hitbox()
	)
	tween.tween_property(projectile, "scale", base_scale, scale_down_time)

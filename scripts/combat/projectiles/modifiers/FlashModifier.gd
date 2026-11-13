@tool
class_name FlashModifier
extends ProjectileModifier

## Pulses modulate color, looping for the projectile's lifetime. Cheap
## telegraph pair with PunchModifier so the flash reads as a "wind-up"
## before the hit lands.

@export var flash_color: Color = Color(1.5, 1.5, 1.5, 1.0)
@export var flash_time: float = 0.15

func start(projectile: ProjectileBase) -> void:
	if not is_alive(projectile): return
	var base_color := projectile.modulate
	var tween := projectile.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(projectile, "modulate", flash_color, flash_time)
	tween.tween_property(projectile, "modulate", base_color, flash_time)

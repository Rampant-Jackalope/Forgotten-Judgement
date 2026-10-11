@tool
class_name PunchModifier
extends ProjectileModifier

## Scales the projectile up toward the player, activates the hitbox right
## at the peak (the "punch" moment), then eases back down.

@export var peak_scale: float = 1.8
@export var scale_up_time: float = 0.25
@export var scale_down_time: float = 0.15

func start(projectile: ProjectileBase) -> void:
	for connection in projectile.hitbox.body_entered.get_connections():
		projectile.hitbox.body_entered.disconnect(connection.callable)

	var base_scale := projectile.scale

	var scale_up_tween := projectile.get_tree().create_tween()
	scale_up_tween.bind_node(projectile)
	scale_up_tween.tween_property(projectile, "scale", base_scale * peak_scale, scale_up_time)
	await scale_up_tween.finished

	if not is_instance_valid(projectile):
		return

	projectile.scan_hits()

	var scale_down_tween := projectile.get_tree().create_tween()
	scale_down_tween.bind_node(projectile)
	scale_down_tween.tween_property(projectile, "scale", base_scale, scale_down_time)
	await scale_down_tween.finished

	projectile.queue_free()

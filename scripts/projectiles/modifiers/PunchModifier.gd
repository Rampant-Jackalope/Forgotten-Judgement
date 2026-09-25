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

	var scale_up_tween := projectile.get_tree().create_tween()
	scale_up_tween.bind_node(projectile)
	scale_up_tween.tween_property(projectile, "scale", base_scale * peak_scale, scale_up_time)
	await scale_up_tween.finished

	if not is_instance_valid(projectile):
		return

	projectile.activate_hitbox()

	var active_timer := Timer.new()
	active_timer.one_shot = true
	active_timer.wait_time = hitbox_active_time
	projectile.add_child(active_timer)
	active_timer.start()

	await projectile.get_tree().physics_frame

	if active_timer.time_left > 0.0:
		await active_timer.timeout

	active_timer.queue_free()

	if not is_instance_valid(projectile):
		return

	projectile.deactivate_hitbox()

	var scale_down_tween := projectile.get_tree().create_tween()
	scale_down_tween.bind_node(projectile)
	scale_down_tween.tween_property(projectile, "scale", base_scale, scale_down_time)

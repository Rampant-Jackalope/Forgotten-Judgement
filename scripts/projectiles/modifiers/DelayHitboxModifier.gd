@tool
class_name DelayedHitboxModifier
extends ProjectileModifier

@export var delay: float = 0.4
@export var active_time: float = 0.1

func start(projectile: ProjectileBase) -> void:
	await _delayed_activate(projectile)

func _delayed_activate(projectile: ProjectileBase) -> void:
	await projectile.get_tree().create_timer(delay).timeout

	if not is_instance_valid(projectile):
		return

	projectile.activate_hitbox()

	var active_timer := Timer.new()
	active_timer.one_shot = true
	active_timer.wait_time = active_time
	projectile.add_child(active_timer)
	active_timer.start()

	await projectile.get_tree().physics_frame

	if active_timer.time_left > 0.0:
		await active_timer.timeout

	active_timer.queue_free()

	if is_instance_valid(projectile):
		projectile.deactivate_hitbox()

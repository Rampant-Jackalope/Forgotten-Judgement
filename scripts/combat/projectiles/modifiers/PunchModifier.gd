@tool
class_name PunchModifier
extends ProjectileModifier

## Scales the projectile up toward the player, activates the hitbox right
## at the peak (the "punch" moment), then eases back down.

@export var peak_scale: float = 1.8
@export var scale_up_time: float = 0.25
@export var scale_down_time: float = 0.15
@export var audio_player: AudioStreamPlayer2D

func start(projectile: ProjectileBase) -> void:
	if not is_alive(projectile): return

	for connection in projectile.hitbox.body_entered.get_connections():
		projectile.hitbox.body_entered.disconnect(connection.callable)

	var base_scale := projectile.scale

	var scale_up_tween := projectile.create_tween()
	scale_up_tween.tween_property(projectile, "scale", base_scale * peak_scale, scale_up_time)
	await scale_up_tween.finished
	if not is_alive(projectile): return

	if audio_player: audio_player.play()
	projectile.scan_hits()
	if not is_alive(projectile): return

	var scale_down_tween := projectile.create_tween()
	scale_down_tween.tween_property(projectile, "scale", base_scale, scale_down_time)
	await scale_down_tween.finished
	if not is_alive(projectile): return

	projectile.modulate.a = 0

	if audio_player and audio_player.playing:
		await audio_player.finished
		if not is_instance_valid(projectile): return

	projectile.queue_free()

@tool
class_name LinearProjectile
extends ProjectileBase

@export var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 400.0
@export var normalize: bool = true

func apply_motion(delta: float) -> void:
	var dir := direction.normalized() if normalize else direction
	position += dir * speed * delta

func _on_timer_timeout() -> void:
	queue_free()

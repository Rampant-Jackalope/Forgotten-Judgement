@tool
class_name LinearProjectile
extends ProjectileBase

@export var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 400.0

func apply_motion(delta: float) -> void:
	position += direction.normalized() * speed * delta

func _on_timer_timeout() -> void:
	queue_free()

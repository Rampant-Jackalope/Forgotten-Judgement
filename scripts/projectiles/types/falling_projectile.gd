@tool
class_name FallingProjectile
extends ProjectileBase

@export var gravity: float = 980.0
@export var initial_velocity: Vector2 = Vector2.ZERO

var velocity: Vector2

func _enter_tree() -> void:
	super._enter_tree()
	velocity = initial_velocity
	activate_hitbox()

func apply_motion(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta

func _on_timer_timeout() -> void:
	queue_free()

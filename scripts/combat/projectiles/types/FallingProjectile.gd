@tool
class_name FallingProjectile
extends ProjectileBase

@export var gravity: Vector2 = Vector2(.0, 980.0)
@export var initial_velocity: Vector2 = Vector2.ZERO

var velocity: Vector2

func _enter_tree() -> void:
	super._enter_tree()
	hitbox.body_entered.connect(_on_projectile_hit)
	velocity = initial_velocity

func apply_motion(delta: float) -> void:
	velocity += gravity * delta
	position += velocity * delta

func _on_timer_timeout() -> void:
	queue_free()

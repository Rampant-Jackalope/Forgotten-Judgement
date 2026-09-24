@tool
class_name HomingProjectile
extends ProjectileBase

@export var speed: float = 300.0
## How fast it can turn, in units/sec of velocity change. Low = lazy curve,
## high = basically a laser-guided beeline.
@export var turn_rate: float = 3.0
@export var initial_velocity: Vector2 = Vector2.ZERO

var velocity: Vector2

func _enter_tree() -> void:
	super._enter_tree()
	velocity = initial_velocity

func apply_motion(delta: float) -> void:
	if body:
		var desired := (body.global_position - global_position).normalized() * speed
		velocity = velocity.move_toward(desired, turn_rate * speed * delta)
	position += velocity * delta

func _on_timer_timeout() -> void:
	queue_free()

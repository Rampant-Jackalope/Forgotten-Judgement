class_name PlayerController2D
extends Node2D

@export var body: CharacterBody2D
@export var cursor: Node2D
@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D

@export var move_speed := 2500.0
@export var float_height_percentage: float = 0.0

enum State {
	MOVING,
	ATTACKING,
	BLOCKING,
}

var state: State = State.MOVING

signal attacked(screen_position: Vector2)

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	handle_movement()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _process(_delta: float) -> void:
	handle_movement()
	handle_action_input()

func _on_animation_finished() -> void:
	if state == State.ATTACKING:
		state = State.MOVING
		sprite.play("idle")
	if state == State.BLOCKING:
		state = State.MOVING
		sprite.play("idle")

func handle_movement() -> void:
	cursor.position = get_global_mouse_position()

	var viewport_size := get_viewport().get_visible_rect().size
	var float_height := viewport_size.y * (1.0 - float_height_percentage)
	if body.position.y != float_height:
		body.position.y = float_height

	var half_extents: Vector2 = (collision_shape.shape.get_rect().size / 2.0) * collision_shape.global_scale
	body.position.x = clamp(cursor.position.x, half_extents.x, viewport_size.x - half_extents.x)

func is_blocking() -> bool:
	return state == State.BLOCKING

func handle_action_input() -> void:
	if Input.is_action_just_pressed("block"):
		if state == State.MOVING:
			sprite.play("block")
			state = State.BLOCKING
	elif Input.is_action_just_pressed("attack"):
		state = State.ATTACKING
		sprite.play("attack")
		attacked.emit(get_global_mouse_position())

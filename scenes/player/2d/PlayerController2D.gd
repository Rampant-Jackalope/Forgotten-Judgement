class_name PlayerController2D
extends Node2D

@export var body: CharacterBody2D
@export var cursor: Node2D
@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D

@export var move_speed := 2500.0
@export var float_height_percentage: float = 0.0

@export var stamina: Stamina
@export var attack_consume_percentage: float = 0.2
@export var block_consume_percentage: float = 0.1

var attack_consume_value: int
var block_consume_value: int

enum State {
	MOVING,
	ATTACKING,
	BLOCKING,
}

var state: State = State.MOVING

signal attacked(screen_position: Vector2)

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

	assert(stamina)
	
	attack_consume_value = ceil(stamina.max_stamina * attack_consume_percentage)
	block_consume_value = ceil(stamina.max_stamina * block_consume_percentage)

	handle_movement(0)
	
func _process(delta: float) -> void:
	handle_movement(delta)
	handle_action_input()

func _on_animation_finished() -> void:
	if state == State.ATTACKING:
		state = State.MOVING
		sprite.play("idle")
	if state == State.BLOCKING:
		state = State.MOVING
		sprite.play("idle")

func handle_movement(delta: float) -> void:
	cursor.position = get_global_mouse_position()

	var viewport_size := get_viewport().get_visible_rect().size
	var float_height := viewport_size.y * (1.0 - float_height_percentage)
	if body.position.y != float_height:
		body.position.y = float_height

	var speed_multiplier := 0.7 if state == State.BLOCKING else 1.0

	var x_move_dir = Input.get_axis("move_left", "move_right")
	body.position.x += x_move_dir * move_speed * speed_multiplier * delta

	var half_extents: Vector2 = (collision_shape.shape.get_rect().size / 2.0) * collision_shape.global_scale
	body.position.x = clamp(body.position.x, half_extents.x, viewport_size.x - half_extents.x)

func is_blocking() -> bool:
	return state == State.BLOCKING

func handle_action_input() -> void:
	if Input.is_action_just_pressed("block"):
		if state == State.MOVING:
			sprite.play("block")
			state = State.BLOCKING
			if not stamina.try_consume(block_consume_value):
				print("Not enough stamina to block!")
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed("attack"):
		state = State.ATTACKING
		sprite.play("attack")
		if not stamina.try_consume(attack_consume_value):
			print("Not enough stamina to attack!")
		get_viewport().set_input_as_handled()
		attacked.emit(get_global_mouse_position())

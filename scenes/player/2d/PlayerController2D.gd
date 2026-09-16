class_name PlayerController2D
extends Node2D

@onready var body := $'..'
@onready var sprite := $'../AnimatedSprite2D'
@onready var collision_shape := $'../CollisionShape2D'

@export var move_speed := 2500.0
@export var float_height_percentage: float = 0.1

enum Mode {
	MOVING,
	ATTACK,
	DEFEND,
}

var state: Mode = Mode.MOVING

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	handle_movement(0)

# For now the placeholder actions are
# Attack (L-Click/Spacebar), forces attack animation preventing block
# Block (R-Click, D), block as long as the block button is pressed and slow down movement to 70%
# Move, default state
func _process(delta: float) -> void:
	handle_movement(delta)
	handle_action_input()

func _on_animation_finished() -> void:
	if state == Mode.ATTACK:
		state = Mode.MOVING
		sprite.play("move")

func handle_movement(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var float_height := viewport_size.y * (1.0 - float_height_percentage)
	if body.position.y != float_height:
		body.position.y = float_height

	var speed_multiplier := 0.7 if state == Mode.DEFEND else 1.0

	var x_move_dir = Input.get_axis("ui_left", "ui_right")
	body.position.x += x_move_dir * move_speed * speed_multiplier * delta

	var half_extents: Vector2 = (collision_shape.shape.get_rect().size / 2.0) * collision_shape.global_scale
	body.position.x = clamp(body.position.x, half_extents.x, viewport_size.x - half_extents.x)

func handle_action_input() -> void:
	if Input.is_action_pressed("block"):
		if sprite.animation != "attack":
			sprite.play("block")
			state = Mode.DEFEND
	elif Input.is_action_just_pressed("attack"):
		sprite.play("attack")
		state = Mode.ATTACK
	else:
		if sprite.animation != "attack":
			sprite.play("move")
			state = Mode.MOVING

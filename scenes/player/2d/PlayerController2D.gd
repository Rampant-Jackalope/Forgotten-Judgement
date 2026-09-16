class_name PlayerController2D
extends Node2D

var body: CharacterBody2D
var sprite: AnimatedSprite2D
var collision_shape: CollisionShape2D

var move_speed := 2500.0
var float_height_percentage: float = 0.1

enum Mode {
	MOVING,
	ATTACK,
	DEFEND,
}

var state: Mode = Mode.MOVING

# For now the placeholder actions are
# Attack (L-Click), forces attack animation preventing block
# Block (R-Click), block as long as the block button is pressed and slow down movement to 70%
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

	var half_extents := (collision_shape.shape.get_rect().size / 2.0) * collision_shape.global_scale
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

# ---------
# setters cuzz sprite and body are set after _ready() has run

func assign_sprite(real_sprite: AnimatedSprite2D) -> void:
	self.sprite = real_sprite
	sprite.animation_finished.connect(_on_animation_finished)

func assign_body(real_body: CharacterBody2D) -> void:
	self.body = real_body
	body.position = get_global_mouse_position()

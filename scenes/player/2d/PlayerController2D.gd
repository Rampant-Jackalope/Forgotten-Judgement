class_name PlayerController2D
extends Node2D

var body: CharacterBody2D
var sprite: AnimatedSprite2D

@export var mouse_speed := 5000.0

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
	var target = get_global_mouse_position()
	var multiplier: float = 0.7 if state == Mode.DEFEND else 1.0
	body.position = body.position.move_toward(target, (multiplier * mouse_speed) * delta)

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

func _on_animation_finished() -> void:
	if state == Mode.ATTACK:
		state = Mode.MOVING
		sprite.play("move")

# ---------
# setters cuzz sprite and body are set after _ready() has run

func assign_sprite(real_sprite: AnimatedSprite2D) -> void:
	self.sprite = real_sprite
	sprite.animation_finished.connect(_on_animation_finished)

func assign_body(real_body: CharacterBody2D) -> void:
	self.body = real_body
	body.position = get_global_mouse_position()

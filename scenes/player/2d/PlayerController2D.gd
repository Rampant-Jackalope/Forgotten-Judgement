class_name PlayerController2D
extends Node2D

@export var body: CharacterBody2D
@export var cursor: Node2D
@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D
@export var attack_hitbox: Area2D

@export var move_speed := 2500.0
@export var float_height_percentage: float = 0.0

@export var stamina: Stamina
@export var attack_stamina_cost: int = 2
@export var block_stamina_cost: int = 1

enum State {
	MOVING,
	ATTACKING,
	BLOCKING,
}

var state: State = State.MOVING

func _ready() -> void:
	# Connect animation finished signal and initialize player position and mouse mode
	sprite.animation_finished.connect(_on_animation_finished)
	handle_movement()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	
	assert(stamina != null, "Stamina component is not assigned in PlayerController2D!")
	assert(attack_hitbox != null, "No attack hitbox assigned")

func _process(_delta: float) -> void:
	handle_movement()
	handle_action_input()

# Reset player state back to MOVING once attack or block animations finish
func _on_animation_finished() -> void:
	if state == State.ATTACKING or state == State.BLOCKING:
		state = State.MOVING
		sprite.play("idle")

# Update cursor tracking and constrain player horizontal movement within the viewport
func handle_movement() -> void:
	cursor.position = get_global_mouse_position()

	var viewport_size := get_viewport().get_visible_rect().size
	var float_height := viewport_size.y * (1.0 - float_height_percentage)
	if body.position.y != float_height:
		body.position.y = float_height

	var half_extents: Vector2 = (collision_shape.shape.get_rect().size / 2.0) * collision_shape.global_scale
	body.position.x = clamp(cursor.position.x, half_extents.x, viewport_size.x - half_extents.x)

# Returns true if the player is currently in the blocking state
func is_blocking() -> bool:
	return state == State.BLOCKING

# Process player combat inputs and attempt to consume stamina for actions
func handle_action_input() -> void:
	if Input.is_action_just_pressed("block"):
		get_viewport().set_input_as_handled()
		# Use try_block so the stamina component reports "block" if consumption fails
		if state == State.MOVING and stamina.try_block(block_stamina_cost):
			sprite.play("block")
			state = State.BLOCKING

	elif Input.is_action_just_pressed("attack"):
		get_viewport().set_input_as_handled()
		# Use try_attack so the stamina component reports "attack" if consumption fails
		if state == State.MOVING and stamina.try_attack(attack_stamina_cost):
			state = State.ATTACKING
			sprite.play("attack")
			if attack_hitbox.has_overlapping_areas():
				attack(attack_hitbox.get_overlapping_areas()[0]) # attack() can trigger a world switch that removes this node from the tree, so do not add code after this

# Deal damage to the target's Health component if found
func attack(target: Area2D) -> void:
	var health = Util.find_most_related(target, func(v): return v is Health) as Health
	if health:
		health.damage(10)

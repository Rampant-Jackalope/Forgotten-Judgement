extends CharacterBody2D

@export var health: Health
@export var stamina: Stamina

func _ready() -> void:
	assert(health)
	assert(stamina)

	health.became_empty.connect(died.emit)

signal died()
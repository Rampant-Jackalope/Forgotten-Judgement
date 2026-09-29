extends CharacterBody2D

@export var health: Health

func _ready() -> void:
	assert(health)
	health.became_empty.connect(died.emit)

signal died()

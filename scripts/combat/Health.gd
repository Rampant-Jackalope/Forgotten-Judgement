class_name Health
extends Node

@export var max_health: int
var _health: int = max_health

func _ready() -> void:
	assert(max_health)

func set_health(health: int):
	var old = _health
	_health = clamp(health, 0, max_health)
	changed.emit(old, _health)
	if _health <= 0:
		became_empty.emit()
func get_health() -> int:
	return _health

func change_health(amount: int):
	set_health(_health + amount)

func heal(amount: int):
	if amount < 0:
		push_error("Attempt to heal a negative amount")
	change_health(amount)
func damage(amount: int):
	if amount < 0:
		push_error("Attempt to damage a negative amount")
	change_health(-amount)

signal changed(old: int, new: int)
signal became_empty()
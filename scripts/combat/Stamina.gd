class_name Stamina
extends Node

@export var max_stamina: int
@export var regen_rate: float ## Stamina/second that is passively regenerated
@export var regen_cooldown: float = 0.0 ## Cooldown in seconds after consuming until regen kicks in
var _stamina: float = max_stamina
var _should_regen: bool = true
var _cooldown_timer: Timer = Timer.new()

func _init() -> void:
	_cooldown_timer.wait_time = regen_cooldown
	_cooldown_timer.one_shot = true
	add_child(_cooldown_timer)

func _ready() -> void:
	assert(max_stamina && max_stamina >= 0)
	assert(regen_rate && regen_rate >= 0)

	_cooldown_timer.timeout.connect(func(): _should_regen = true)

func _process(delta: float) -> void:
	if regen_rate > 0 and _should_regen:
		_stamina = clamp(_stamina + regen_rate * delta, 0, max_stamina)
		if _stamina == max_stamina:
			became_full.emit()

func try_consume(amount: int) -> bool:
	if _stamina >= amount:
		_stamina -= amount
		_cooldown_timer.start() # Resets cooldown timer on consumption
		return true
	return false
	

signal consume_failed(amount: int)
signal became_full()

class_name Stamina
extends Node

signal changed(old_stamina: float, new_stamina: float)
signal consume_failed(amount: int)
signal became_full()

@export var max_stamina: int
@export var regen_rate: float ## Stamina/second that is passively regenerated
@export var regen_cooldown: float = 0.0 ## Cooldown in seconds after consuming until regen kicks in

var _stamina: float
var _should_regen: bool = true
var _cooldown_timer: Timer = Timer.new()

func _ready() -> void:
	assert(max_stamina && max_stamina >= 0)
	assert(regen_rate && regen_rate >= 0)

	_cooldown_timer.wait_time = regen_cooldown
	_cooldown_timer.one_shot = true
	add_child(_cooldown_timer)

	_set_stamina(float(max_stamina))
	_cooldown_timer.timeout.connect(func(): _should_regen = true)

func _process(delta: float) -> void:
	if regen_rate > 0 and _should_regen and _stamina < max_stamina:
		_set_stamina(_stamina + regen_rate * delta)

func try_consume(amount: int) -> bool:
	if _stamina >= amount:
		_set_stamina(_stamina - amount)
		_should_regen = false
		_cooldown_timer.start() # Resets cooldown timer on consumption
		return true
	consume_failed.emit(amount)
	return false

func get_stamina() -> float:
	return _stamina

func _set_stamina(value: float) -> void:
	value = clampf(value, 0.0, float(max_stamina))
	if _stamina == value: return

	var old_stamina: float = _stamina
	_stamina = value
	changed.emit(old_stamina, _stamina)

	if _stamina == float(max_stamina):
		became_full.emit()
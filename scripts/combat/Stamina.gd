class_name Stamina
extends Node

# Signals for stamina changes, consumption failures, and reaching max stamina
signal changed(old_stamina: float, new_stamina: float)
signal consume_failed(amount: int, action_name: String)
signal became_full()

@export var max_stamina: int
@export var regen_rate: float ## Stamina per second that is passively regenerated
@export var regen_cooldown: float = 0.0 ## Cooldown in seconds after consuming until passive regen starts again

var _stamina: float
var _should_regen: bool = true
var _cooldown_timer: Timer = Timer.new()

func _ready() -> void:
	assert(max_stamina and max_stamina >= 0)
	assert(regen_rate and regen_rate >= 0)

	# Setup the cooldown timer for passive regeneration
	_cooldown_timer.wait_time = regen_cooldown
	_cooldown_timer.one_shot = true
	add_child(_cooldown_timer)

	# Initialize stamina to full value
	_set_stamina(float(max_stamina))
	_cooldown_timer.timeout.connect(func(): _should_regen = true)

func _process(delta: float) -> void:
	# Passively regenerate stamina if allowed and below maximum
	if regen_rate > 0 and _should_regen and _stamina < max_stamina:
		_set_stamina(_stamina + regen_rate * delta)

# Core function to try consuming stamina for a specific action (requires explicit action name)
func try_consume(amount: int, action_name: String) -> bool:
	if _stamina >= amount:
		_set_stamina(_stamina - amount)
		_should_regen = false
		_cooldown_timer.start()
		return true
	
	# Emit failure signal with the specific action name if not enough stamina
	consume_failed.emit(amount, action_name)
	return false

# Dedicated helper function for attacking
func try_attack(amount: int) -> bool:
	return try_consume(amount, "attack")

# Dedicated helper function for blocking
func try_block(amount: int) -> bool:
	return try_consume(amount, "block")

# Returns the current stamina value
func get_stamina() -> float:
	return _stamina

# Internal helper to set stamina and handle signals
func _set_stamina(value: float) -> void:
	value = clampf(value, 0.0, float(max_stamina))
	if _stamina == value:
		return

	var old_stamina: float = _stamina
	_stamina = value
	changed.emit(old_stamina, _stamina)

	# Trigger became_full signal when stamina reaches maximum
	if _stamina == float(max_stamina):
		became_full.emit()

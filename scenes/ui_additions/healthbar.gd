extends Control

# Reference to the Health node exported to the Inspector
@export var health: Health

# Threshold ratio for low health status (0.20 = 20%)
@export var low_health_threshold: float = 0.2

# Color definitions
@export var normal_color: Color = Color.RED
@export var warning_color: Color = Color.YELLOW

@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	assert(health, "No health component assigned")
	_setup_health()

func _setup_health() -> void:	
	var current_hp: int = health.get_health()
	@warning_ignore("integer_division")
	progress_bar.value = (current_hp / health.max_health) * 100
	_update_bar_color(current_hp)
	
	health.changed.connect(_on_health_changed)

func _on_health_changed(_old: int, new: int) -> void:
	# Update the progress bar value whenever health changes
	@warning_ignore("integer_division")
	progress_bar.value = (new / health.max_health) * 100
	_update_bar_color(new)

func _update_bar_color(current_health: int) -> void:
	# Calculate ratio between current health and max health
	@warning_ignore("integer_division")
	var health_ratio: float = current_health / health.max_health
	
	# Change color to warning color if below threshold
	if health_ratio <= low_health_threshold:
		progress_bar.modulate = warning_color
	else:
		progress_bar.modulate = normal_color

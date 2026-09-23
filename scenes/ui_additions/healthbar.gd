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
	if health:
		_setup_health()

func _setup_health() -> void:
	# Ensure max_value is properly set (defaulting to 100 if max_health is not set yet)
	var max_hp: int = health.max_health if health.max_health > 0 else 100
	progress_bar.max_value = max_hp
	
	# Explicitly set the starting value to max_health (or current health if set)
	var current_hp: int = health.get_health()
	if current_hp <= 0 and max_hp > 0:
		current_hp = max_hp
		
	progress_bar.value = current_hp
	
	# Update color based on initial health value
	_update_bar_color(current_hp)
	
	# Connect to the changed signal emitted by Health.gd
	health.changed.connect(_on_health_changed)

func _on_health_changed(_old: int, new: int) -> void:
	# Update the progress bar value whenever health changes
	progress_bar.value = new
	_update_bar_color(new)

func _update_bar_color(current_health: int) -> void:
	# Calculate ratio between current health and max health
	var health_ratio: float = float(current_health) / float(health.max_health)
	
	# Change color to warning color if below threshold
	if health_ratio <= low_health_threshold:
		progress_bar.modulate = warning_color
	else:
		progress_bar.modulate = normal_color

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
	assert(health != null, "No health component assigned to Healthbar!")
	_setup_health()

func _setup_health() -> void:	
	progress_bar.max_value = health.max_health
	
	var current_hp: int = health.get_health()
	progress_bar.value = current_hp
	
	var health_ratio: float = float(current_hp) / float(health.max_health)
	_update_bar_color(health_ratio)
	
	health.changed.connect(_on_health_changed)

func _on_health_changed(_old: int, new: int) -> void:
	progress_bar.value = new
	
	var health_ratio: float = float(new) / float(health.max_health)
	_update_bar_color(health_ratio)

func _update_bar_color(health_ratio: float) -> void:
	if health_ratio <= low_health_threshold:
		progress_bar.modulate = warning_color
	else:
		progress_bar.modulate = normal_color

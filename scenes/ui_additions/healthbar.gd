extends Control

@export var health: Health
@export var low_health_threshold: float = 0.2

@export var normal_color: Color = Color.RED
@export var warning_color: Color = Color.YELLOW

@onready var progress_bar: TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	assert(health != null, "No health component assigned to Healthbar!")
	
	if progress_bar == null:
		push_error("TextureProgressBar node not found under Healthbar!")
		return
		
	_setup_health()

func _setup_health() -> void:
	progress_bar.max_value = float(health.max_health)
	
	var current_hp: int = health.get_health()
	progress_bar.value = float(current_hp)
	
	var health_ratio: float = float(current_hp) / float(health.max_health)
	_update_bar_color(health_ratio)
	
	health.changed.connect(_on_health_changed)

func _on_health_changed(_old: int, new: int) -> void:
	progress_bar.value = float(new)
	
	var health_ratio: float = float(new) / float(health.max_health)
	_update_bar_color(health_ratio)

func _update_bar_color(health_ratio: float) -> void:
	if health_ratio <= low_health_threshold:
		progress_bar.tint_progress = warning_color
	else:
		progress_bar.tint_progress = normal_color

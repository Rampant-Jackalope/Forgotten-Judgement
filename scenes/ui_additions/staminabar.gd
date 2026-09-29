extends Control

# Reference to the Stamina node exported to the Inspector
@export var stamina: Stamina

# Threshold ratio for low stamina status (0.20 = 20%)
@export var low_stamina_threshold: float = 0.2

# Color definitions
@export var normal_color: Color = Color.GREEN
@export var warning_color: Color = Color.SEA_GREEN

@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	assert(stamina, "No stamina assigned")
	_update_stamina_ui()

func _process(_delta: float) -> void:
	_update_stamina_ui()

func _update_stamina_ui() -> void:
	var max_sp: float = float(stamina.max_stamina) if stamina.max_stamina > 0 else 100.0
	var stamina_ratio: float = stamina.get_stamina() / max_sp

	progress_bar.value = stamina_ratio * 100.0
	_update_bar_color(stamina_ratio)

func _update_bar_color(stamina_ratio: float) -> void:
	# Change color to warning color if stamina is low
	if stamina_ratio <= low_stamina_threshold:
		progress_bar.modulate = warning_color
	else:
		progress_bar.modulate = normal_color

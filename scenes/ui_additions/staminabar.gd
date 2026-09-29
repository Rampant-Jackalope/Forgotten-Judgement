extends Control

# Reference to the Stamina node exported to the Inspector
@export var stamina: Stamina

# Threshold ratio for low stamina status (0.20 = 20%)
@export var low_stamina_threshold: float = 0.2

# Color definitions (Main color red, warning color blue)
@export var normal_color: Color = Color.GREEN
@export var warning_color: Color = Color.SEA_GREEN

@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	assert(stamina, "No stamina assigned")
	_update_bar_color(stamina.get_stamina())

func _process(_delta: float) -> void:
	# Update progress bar continuously as stamina regenerates
	progress_bar.value = (stamina.get_stamina() / stamina.max_stamina) * 100
	_update_bar_color(stamina.get_stamina())

func _update_bar_color(current_stamina: float) -> void:
	@warning_ignore("integer_division")
	var stamina_ratio: float = current_stamina / stamina.max_stamina
	
	# Change color to warning color (blue) if stamina is low
	if stamina_ratio <= low_stamina_threshold:
		progress_bar.modulate = warning_color
	else:
		progress_bar.modulate = normal_color

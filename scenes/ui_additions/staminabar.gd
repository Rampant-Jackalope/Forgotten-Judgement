extends Control

# Reference to the Stamina node exported to the Inspector
@export var stamina: Stamina

# Threshold ratio for low stamina status (0.20 = 20%)
@export var low_stamina_threshold: float = 0.2

# Color definitions (Main color red, warning color blue)
@export var normal_color: Color = Color.GREEN
@export var warning_color: Color = Color.SEA_GREEN

# --- Choose 1 of the 2 options below ---
# OPTION 1: If the root node itself is the ProgressBar:
# @onready var progress_bar: ProgressBar = self

# OPTION 2: If ProgressBar is a child node (adjust "ProgressBar" to match your Scene Tree):
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	if stamina:
		_setup_stamina()

func _setup_stamina() -> void:
	# Fallback to 100 if max_stamina is not set in the Inspector
	var max_sp: int = stamina.max_stamina if stamina.max_stamina > 0 else 100
	progress_bar.max_value = max_sp
	
	# Start full by default (100 or max_stamina)
	progress_bar.value = max_sp
	_update_bar_color(max_sp)

func _process(_delta: float) -> void:
	if stamina and progress_bar:
		# Update progress bar continuously as stamina regenerates
		progress_bar.value = stamina._stamina
		_update_bar_color(stamina._stamina)

func _update_bar_color(current_stamina: float) -> void:
	var max_sp: float = float(stamina.max_stamina if stamina.max_stamina > 0 else 100)
	var stamina_ratio: float = current_stamina / max_sp
	
	# Change color to warning color (blue) if stamina is low
	if stamina_ratio <= low_stamina_threshold:
		progress_bar.modulate = warning_color
	else:
		progress_bar.modulate = normal_color

extends Control

@export_category("Health Bar Settings")
## Reference to the Health resource component that manages health values.
@export var health: Health

## Threshold ratio (0.0 to 1.0) below which the health bar switches to warning color.
@export var low_health_threshold: float = 0.2

@export_group("Colors")
@export var normal_color: Color = Color.RED
@export var warning_color: Color = Color.YELLOW

@export_group("Subtitle")
## Subtitle text displayed below or on the health bar.
@export var subtitle_text: String = "":
	set(value):
		subtitle_text = value
		_update_subtitle()

## Modulation tint applied to the subtitle label.
@export var subtitle_modulate: Color = Color.WHITE:
	set(value):
		subtitle_modulate = value
		_update_subtitle()

@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var label: Label = $Label

func _ready() -> void:
	assert(health != null, "No health component assigned to Healthbar!")
	
	if progress_bar == null:
		push_error("TextureProgressBar node not found under Healthbar!")
		return
		
	_setup_health()
	_update_subtitle()

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

func _update_subtitle() -> void:
	if not is_node_ready():
		return
	
	if label:
		label.text = subtitle_text
		label.modulate = subtitle_modulate
		label.visible = not subtitle_text.is_empty()
		
		label.add_theme_color_override("font_outline_color", Color.DARK_RED)
		label.add_theme_constant_override("outline_size", 3)

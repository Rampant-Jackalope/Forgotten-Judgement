extends Control

@export_category("Health Bar Settings")
## Reference to the Health resource component that manages health values.
@export var health: Health

## Threshold ratio (0.0 to 1.0) below which the health bar switches to warning color.
@export var low_health_threshold: float = 0.2

@export_group("Colors")
@export var normal_color: Color = Color.RED
@export var warning_color: Color = Color.YELLOW

@export_group("Audio")
## Sound played when health decreases.
@export var damage_sound: AudioStream:
	set(value):
		damage_sound = value
		_update_audio()

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
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var _flash_tween: Tween

func _ready() -> void:
	assert(health != null, "No health component assigned to Healthbar!")
	
	if progress_bar == null:
		push_error("TextureProgressBar node not found under Healthbar!")
		return
		
	_setup_health()
	_update_subtitle()
	_update_audio()

func _setup_health() -> void:
	progress_bar.max_value = float(health.max_health)
	
	var current_hp: int = health.get_health()
	progress_bar.value = float(current_hp)
	
	var health_ratio: float = float(current_hp) / float(health.max_health)
	_update_bar_color(health_ratio)
	
	health.changed.connect(_on_health_changed)

func _on_health_changed(old: int, new: int) -> void:
	progress_bar.value = float(new)
	
	var health_ratio: float = float(new) / float(health.max_health)
	_update_bar_color(health_ratio)
	
	if new < old:
		flash()
		audio_player.play()

func _update_bar_color(health_ratio: float) -> void:
	if _flash_tween and _flash_tween.is_running():
		return
	
	if health_ratio <= low_health_threshold:
		progress_bar.tint_progress = warning_color
	else:
		progress_bar.tint_progress = normal_color

func flash(duration: float = 0.35, color: Color = Color(3, 3, 3)) -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	
	var base_color: Color = _get_current_bar_color()
	progress_bar.pivot_offset = progress_bar.size / 2.0
	progress_bar.tint_progress = color
	progress_bar.scale = Vector2.ONE * 1.08
	
	_flash_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_interval(0.06) # hold the flash so it registers
	_flash_tween.tween_property(progress_bar, "tint_progress", base_color, duration)
	_flash_tween.parallel().tween_property(progress_bar, "scale", Vector2.ONE, duration)

func _get_current_bar_color() -> Color:
	var ratio: float = progress_bar.value / progress_bar.max_value
	return warning_color if ratio <= low_health_threshold else normal_color

func _update_audio() -> void:
	# Setters can fire before the scene tree is ready, so bail until then.
	# Also don't overwrite a stream set directly on the node with null.
	if not is_node_ready() or damage_sound == null:
		return

	audio_player.stream = damage_sound

func _update_subtitle() -> void:
	if not is_node_ready():
		return
	
	if label:
		label.text = subtitle_text
		label.modulate = subtitle_modulate
		label.visible = not subtitle_text.is_empty()
		
		label.add_theme_color_override("font_outline_color", Color.DARK_RED)
		label.add_theme_constant_override("outline_size", 3)

extends Control

enum LabelPlacement {
	BOTTOM_LEFT,
	BOTTOM_MIDDLE,
	BOTTOM_RIGHT,
	TOP_LEFT,
	TOP_MIDDLE,
	TOP_RIGHT,
}

@export_category("Stamina Bar Settings")
## Reference to the Stamina resource component that manages stamina values.
@export var stamina: Stamina

## Threshold ratio (0.0 to 1.0) below which the stamina bar switches to warning color.
@export var low_stamina_threshold: float = 0.2

## Maximum number of visual segment dividers to draw on the progress bar.
@export var max_segments_to_draw: int = 10

@export_group("Colors")
@export var normal_color: Color = Color.GREEN
@export var warning_color: Color = Color.SEA_GREEN
## Over-bright values (above 1.0) blow the texture out toward white.
@export var flash_color: Color = Color(3, 3, 3)
@export var line_color: Color = Color(0.0, 0.0, 0.0, 0.5)

@export_group("Audio")
## Sound played when a stamina consume attempt fails.
@export var fail_sound: AudioStream:
	set(value):
		fail_sound = value
		_update_audio()

@export_group("Subtitle")
## Subtitle text displayed below or on the stamina bar.
@export var subtitle_text: String = "":
	set(value):
		subtitle_text = value
		_update_subtitle()

## Modulation tint applied to the subtitle label.
@export var subtitle_modulate: Color = Color.WHITE:
	set(value):
		subtitle_modulate = value
		_update_subtitle()

## Where the subtitle sits relative to the progress bar.
@export var label_placement: LabelPlacement = LabelPlacement.TOP_RIGHT:
	set(value):
		label_placement = value
		_update_label_position()

## Extra pixel offset applied after placement (nudge it off the bar's frame).
@export var label_offset: Vector2 = Vector2.ZERO:
	set(value):
		label_offset = value
		_update_label_position()

@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var label: Label = $Label
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var _flash_tween: Tween

func _ready() -> void:
	assert(stamina != null, "No stamina component assigned to Staminabar!")

	if progress_bar == null:
		push_error("TextureProgressBar node not found under Staminabar!")
		return

	stamina.changed.connect(_on_stamina_changed)
	stamina.consume_failed.connect(_on_stamina_consume_failed)

	_update_ui(stamina.get_stamina())
	_update_subtitle()
	_update_audio()

func _draw() -> void:
	var max_sp: int = stamina.max_stamina if stamina else 0
	if max_sp <= 1 or max_sp > max_segments_to_draw:
		return

	var bar_rect: Rect2 = progress_bar.get_rect()
	var step_x: float = bar_rect.size.x / float(max_sp)

	for i in range(1, max_sp):
		var x_pos: float = bar_rect.position.x + (step_x * float(i))
		var start_pt := Vector2(x_pos, bar_rect.position.y)
		var end_pt := Vector2(x_pos, bar_rect.position.y + bar_rect.size.y)
		draw_line(start_pt, end_pt, line_color, 1.5)

func _on_stamina_changed(_old_stamina: float, new_stamina: float) -> void:
	_update_ui(new_stamina)

func _on_stamina_consume_failed(_amount: int) -> void:
	flash(0.35, flash_color)
	audio_player.play()

func _update_ui(current_stamina: float) -> void:
	var max_sp: float = _get_max_stamina()
	var stamina_ratio: float = current_stamina / max_sp

	progress_bar.max_value = max_sp
	progress_bar.value = current_stamina
	_update_bar_color(stamina_ratio)

	queue_redraw()

func _update_bar_color(stamina_ratio: float) -> void:
	if _flash_tween and _flash_tween.is_running():
		return

	if stamina_ratio <= low_stamina_threshold:
		progress_bar.tint_progress = warning_color
	else:
		progress_bar.tint_progress = normal_color

func flash(duration: float = 0.35, color: Color = Color(3, 3, 3)) -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	var target_color: Color = _get_base_color()
	progress_bar.pivot_offset = progress_bar.size / 2.0
	progress_bar.tint_progress = color
	progress_bar.scale = Vector2.ONE * 1.08

	_flash_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_interval(0.06) # hold the flash so it registers
	_flash_tween.tween_property(progress_bar, "tint_progress", target_color, duration)
	_flash_tween.parallel().tween_property(progress_bar, "scale", Vector2.ONE, duration)

func _get_base_color() -> Color:
	var ratio: float = stamina.get_stamina() / _get_max_stamina()
	return warning_color if ratio <= low_stamina_threshold else normal_color

func _get_max_stamina() -> float:
	return float(stamina.max_stamina) if stamina.max_stamina > 0 else 100.0

func _update_audio() -> void:
	# Setters can fire before the scene tree is ready, so bail until then.
	# Also don't overwrite a stream set directly on the node with null.
	if not is_node_ready() or fail_sound == null:
		return

	audio_player.stream = fail_sound

func _update_label_position() -> void:
	if not is_node_ready() or label == null or progress_bar == null:
		return

	var label_size: Vector2 = label.get_combined_minimum_size()
	label.size = label_size

	var bar_rect: Rect2 = progress_bar.get_rect()
	var x: float
	var y: float

	match label_placement:
		LabelPlacement.TOP_LEFT, LabelPlacement.BOTTOM_LEFT:
			x = bar_rect.position.x
		LabelPlacement.TOP_MIDDLE, LabelPlacement.BOTTOM_MIDDLE:
			x = bar_rect.position.x + (bar_rect.size.x - label_size.x) / 2.0
		LabelPlacement.TOP_RIGHT, LabelPlacement.BOTTOM_RIGHT:
			x = bar_rect.end.x - label_size.x
		_:
			assert(false, "Unhandled LabelPlacement: %d" % label_placement)
	
	match label_placement:
		LabelPlacement.TOP_LEFT, LabelPlacement.TOP_MIDDLE, LabelPlacement.TOP_RIGHT:
			y = bar_rect.position.y - label_size.y
		LabelPlacement.BOTTOM_LEFT, LabelPlacement.BOTTOM_MIDDLE, LabelPlacement.BOTTOM_RIGHT:
			y = bar_rect.end.y
		_:
			assert(false, "Unhandled LabelPlacement: %d" % label_placement)

	label.position = Vector2(x, y) + label_offset

func _update_subtitle() -> void:
	if not is_node_ready():
		return

	if label:
		label.text = subtitle_text
		label.modulate = subtitle_modulate
		label.visible = not subtitle_text.is_empty()

		label.add_theme_color_override("font_outline_color", Color.DARK_GREEN)
		label.add_theme_constant_override("outline_size", 3)

		_update_label_position()

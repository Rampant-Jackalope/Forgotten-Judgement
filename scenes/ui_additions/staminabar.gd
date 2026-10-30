extends Control

@export var stamina: Stamina

@export var low_stamina_threshold: float = 0.2

@export var normal_color: Color = Color.GREEN
@export var warning_color: Color = Color.SEA_GREEN
@export var flash_color: Color = Color.RED
@export var line_color: Color = Color(0.0, 0.0, 0.0, 0.5)

@export var max_segments_to_draw: int = 10

@export var subtitle_text: String = "":
	set(value):
		subtitle_text = value
		_update_subtitle()

@export var subtitle_color: Color = Color.WHITE:
	set(value):
		subtitle_color = value
		_update_subtitle()

@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var label: Label = $Label

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
	_flash_red()

func _update_ui(current_stamina: float) -> void:
	var max_sp: float = float(stamina.max_stamina) if stamina.max_stamina > 0 else 100.0
	var stamina_ratio: float = current_stamina / max_sp

	progress_bar.max_value = float(max_sp)
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

func _flash_red() -> void:
	if _flash_tween and _flash_tween.is_running():
		_flash_tween.kill()

	var max_sp: float = float(stamina.max_stamina) if stamina.max_stamina > 0 else 100.0
	var target_color: Color = warning_color if (stamina.get_stamina() / max_sp) <= low_stamina_threshold else normal_color

	_flash_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	progress_bar.tint_progress = flash_color
	_flash_tween.tween_property(progress_bar, "tint_progress", target_color, 0.25)

func _update_subtitle() -> void:
	if not is_node_ready():
		return
	
	if label:
		label.text = subtitle_text
		label.modulate = subtitle_color
		label.visible = not subtitle_text.is_empty()
		
		label.add_theme_color_override("font_outline_color", Color.DARK_GREEN)
		label.add_theme_constant_override("outline_size", 3)

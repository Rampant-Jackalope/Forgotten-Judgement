extends CanvasLayer

@onready var tutorial_label: Label = $PanelContainer/TutorialLabel
@onready var arrow_1: Control = $Arrow1
@onready var arrow_2: Control = $Arrow2

enum TutorialStep { UI_EXPLANATION, ACTION_CHECKLIST, ENEMY_PREVIEW, DONE }
var _step: TutorialStep = TutorialStep.UI_EXPLANATION

var _has_moved: bool = false
var _has_shielded: bool = false
var _has_attacked: bool = false
var _initial_mouse_pos: Vector2 = Vector2.ZERO

var _attack_descriptions: Array[String] = [
	"Scratch attack hits you on 50% of the screen",
	"Poison falls from the sky and you have to dodge or block it"
]
var _current_preview_index: int = 0
var _is_playing_demo: bool = false

func _ready() -> void:
	visible = true
	if tutorial_label:
		tutorial_label.add_theme_font_size_override("font_size", 26)
	_update_ui()

func _process(_delta: float) -> void:
	if _step == TutorialStep.DONE or _is_playing_demo:
		return

	match _step:
		TutorialStep.UI_EXPLANATION:
			if Input.is_action_just_pressed("ui_accept"):
				_step = TutorialStep.ACTION_CHECKLIST
				_initial_mouse_pos = get_viewport().get_mouse_position()
				_update_ui()

		TutorialStep.ACTION_CHECKLIST:
			var updated := false

			if not _has_moved and get_viewport().get_mouse_position().distance_to(_initial_mouse_pos) > 30.0:
				_has_moved = true
				updated = true

			if not _has_shielded and Input.is_action_just_pressed("block"):
				_has_shielded = true
				updated = true

			if not _has_attacked and Input.is_action_just_pressed("attack"):
				_has_attacked = true
				updated = true

			if updated:
				_update_ui()
				if _has_moved and _has_shielded and _has_attacked:
					_is_playing_demo = true
					await get_tree().create_timer(0.5).timeout
					_is_playing_demo = false
					_start_enemy_preview()

		TutorialStep.ENEMY_PREVIEW:
			if Input.is_action_just_pressed("ui_accept"):
				_trigger_and_advance_preview()

func _start_enemy_preview() -> void:
	_step = TutorialStep.ENEMY_PREVIEW
	_current_preview_index = 0
	_update_ui()

func _trigger_and_advance_preview() -> void:
	_is_playing_demo = true
	_update_ui()
	
	var fight_root = get_parent()
	if fight_root and fight_root.has_method("demo_single_attack"):
		await fight_root.demo_single_attack(_current_preview_index)
		
	_is_playing_demo = false
	_current_preview_index += 1
	
	var total_attacks = fight_root.get_attack_count() if fight_root and fight_root.has_method("get_attack_count") else _attack_descriptions.size()
	
	if _current_preview_index >= total_attacks or _current_preview_index >= _attack_descriptions.size():
		_finish_tutorial()
	else:
		_update_ui()

func _update_ui() -> void:
	if not tutorial_label:
		return

	match _step:
		TutorialStep.UI_EXPLANATION:
			tutorial_label.text = (
				"COMBAT BASICS:\n" +
				"• Bottom-left: Your Health & Stamina.\n" +
				"• Top: Enemy's Health.\n\n" +
				"[Press SPACE to continue]"
			)
			if arrow_1: arrow_1.visible = true
			if arrow_2: arrow_2.visible = true

		TutorialStep.ACTION_CHECKLIST:
			tutorial_label.text = (
				"TRY YOUR CONTROLS:\n" +
				("%s Move/Dodge (MOVE MOUSE)\n" % ("[✔]" if _has_moved else "[  ]")) +
				("%s Shield (RIGHT CLICK)\n" % ("[✔]" if _has_shielded else "[  ]")) +
				("%s Attack (LEFT CLICK)" % ("[✔]" if _has_attacked else "[  ]"))
			)
			if arrow_1: arrow_1.visible = false
			if arrow_2: arrow_2.visible = false

		TutorialStep.ENEMY_PREVIEW:
			var desc = _attack_descriptions[_current_preview_index] if _current_preview_index < _attack_descriptions.size() else "Get ready for battle!"
			var prompt = "\n\n[Experiencing attack...]" if _is_playing_demo else "\n\n[Press SPACE to experience attack]"
			tutorial_label.text = "ENEMY ATTACK:\n" + desc + prompt
			
			if arrow_1: arrow_1.visible = false
			if arrow_2: arrow_2.visible = false

func _finish_tutorial() -> void:
	_step = TutorialStep.DONE
	if tutorial_label:
		tutorial_label.text = "GET READY! HERE IT COMES!"
		
	await get_tree().create_timer(3.0).timeout
	visible = false
	
	var fight_root = get_parent()
	if fight_root and fight_root.has_method("start_combat"):
		fight_root.start_combat()

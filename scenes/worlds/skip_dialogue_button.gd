
# TODO: bind to Dialogic styling (then the canvas layer can also be removed)

class_name SkipButton
extends Button

enum Mode {
	TOGGLE,
	HOLD,
	SINGLE,
}

@export var mode: Mode = Mode.SINGLE:
	set(value):
		mode = value
		if is_node_ready():
			_apply_mode()

func _ready() -> void:
	hide()
	text = "Skip"
	toggled.connect(_on_toggled)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

	# TODO: add better handling of these
	Util.get_player().locked_dialogue.connect(func(): show())
	Util.get_player().unlocked_dialogue.connect(func(): hide())

	if Dialogic.Choices.has_signal("question_shown"):
		Dialogic.Choices.question_shown.connect(_on_question_shown)
	else:
		push_warning(
			"SkipButton: Dialogic.Choices has no 'question_shown' signal, SINGLE mode won't stop at choices."
		)

	_apply_mode()

func _apply_mode() -> void:
	Dialogic.Inputs.auto_skip.enabled = false
	toggle_mode = (mode != Mode.HOLD)
	set_pressed_no_signal(false)

func _on_toggled(p_pressed: bool) -> void:
	# TOGGLE and SINGLE both start/stop on click
	if mode != Mode.HOLD:
		Dialogic.Inputs.auto_skip.enabled = p_pressed

func _on_button_down() -> void:
	if mode == Mode.HOLD:
		Dialogic.Inputs.auto_skip.enabled = true

func _on_button_up() -> void:
	if mode == Mode.HOLD:
		Dialogic.Inputs.auto_skip.enabled = false

func _on_question_shown(_info: Dictionary) -> void:
	# SINGLE: a choice appeared, so stop skipping until clicked again
	if mode == Mode.SINGLE:
		Dialogic.Inputs.auto_skip.enabled = false
		set_pressed_no_signal(false)

func _process(_delta: float) -> void:
	# Keep the button's look in sync if skipping gets cancelled elsewhere
	if mode != Mode.HOLD and button_pressed != Dialogic.Inputs.auto_skip.enabled:
		set_pressed_no_signal(Dialogic.Inputs.auto_skip.enabled)

func _exit_tree() -> void:
	Dialogic.Inputs.auto_skip.enabled = false

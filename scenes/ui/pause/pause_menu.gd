class_name PauseMenu
extends CanvasLayer

signal opened
signal closed

@export var main_menu_scene: PackedScene
@export var back_to_menu_button: Button
@export var settings_button: Button
@export var settings_scene: PackedScene
@export var save_button: Button
@export var quit_button: Button

var _prev_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS # must keep running while the tree is paused
	hide()

	assert(back_to_menu_button != null, "BackToMenuButton not assigned in PauseMenu.")
	assert(quit_button != null, "QuitButton not assigned in PauseMenu.")
	assert(main_menu_scene != null, "main_menu_scene not assigned in PauseMenu.")
	assert(save_button != null, "Save button not assigned in PauseMenu")
	assert(settings_button != null, "Settings button not assigned in PauseMenu.")
	assert(settings_scene != null, "settings_scene not assigned in PauseMenu.")

	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	save_button.pressed.connect(GameState.save_to_disk)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo() and not Util.is_dialogue_active():
		toggle()

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func open() -> void:
	if visible:
		return
	_prev_mouse_mode = Input.mouse_mode # remember it so we don't force CAPTURED in 2D worlds
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	opened.emit()

func close() -> void:
	if not visible:
		return
	hide()
	get_tree().paused = false
	Input.mouse_mode = _prev_mouse_mode
	closed.emit()

func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_settings_pressed() -> void:
	var instance = settings_scene.instantiate() as Node
	add_child(instance)

func _on_quit_pressed() -> void:
	GameState.save_to_disk()
	get_tree().quit()

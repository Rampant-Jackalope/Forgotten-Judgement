extends MarginContainer

# Correct path to your main menu scene
const MAIN_MENU_SCENE_PATH = "res://scenes/main_menu/user_interface.tscn"

@onready var back_to_menu_button: Button = $MainButtons/BackToMenuButton
@onready var quit_button: Button = $MainButtons/QuitButton

func _ready() -> void:
	# Ensure this container processes input even when the game is paused
	process_mode = PROCESS_MODE_ALWAYS
	
	# Start hidden
	hide()
	
	# Connect button signals
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	# Toggle the menu on ESC press using _input to bypass UI focus blockage
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause_menu()

func toggle_pause_menu() -> void:
	var is_paused = not visible
	visible = is_paused
	get_tree().paused = is_paused

	# Release the mouse cursor so you can click the buttons
	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_back_to_menu_pressed() -> void:
	# Unpause before switching scenes to prevent freeze states
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()

extends Control

@onready var main_buttons: VBoxContainer = $MainMenu/MarginContainer/MainButtons
@onready var start_button: Button = $MainMenu/MarginContainer/MainButtons/StartButton
@onready var load_button: Button = $MainMenu/MarginContainer/MainButtons/LoadButton
@onready var quit_button: Button = $MainMenu/MarginContainer/MainButtons/QuitButton

@onready var main_menu_video: VideoStreamPlayer = $MainMenu/MainMenuVideo

@onready var sound_main_menu: AudioStreamPlayer = $SoundMainMenu
@onready var sound_scroll: AudioStreamPlayer = $SoundScroll
@onready var sound_quit: AudioStreamPlayer = $SoundQuit
@onready var sound_confirm: AudioStreamPlayer = $SoundConfirm

func _ready() -> void:
	
	main_menu_video.play()
	main_menu_video.finished.connect(main_menu_video.play)
	
	sound_main_menu.play()
	
	for btn in [start_button, load_button, quit_button]:
		btn.mouse_entered.connect(sound_scroll.play)

	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(func(): sound_confirm.play())
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
	sound_confirm.play()
	await sound_confirm.finished
	get_tree().change_scene_to_file("res://scenes/3d-demo-root.tscn")

func _on_quit_button_pressed() -> void:
	sound_quit.play()
	await sound_quit.finished
	get_tree().quit()

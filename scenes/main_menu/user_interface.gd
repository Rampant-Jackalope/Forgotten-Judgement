extends Control

# Paden naar de interface-elementen
@onready var main_buttons: VBoxContainer = $MainMenu/MarginContainer/MainButtons
@onready var start_button: Button = $MainMenu/MarginContainer/MainButtons/StartButton
@onready var load_button: Button = $MainMenu/MarginContainer/MainButtons/LoadButton
@onready var quit_button: Button = $MainMenu/MarginContainer/MainButtons/QuitButton

# Geluidsspelers
@onready var sound_main_menu: AudioStreamPlayer = $SoundMainMenu
@onready var sound_scroll: AudioStreamPlayer = $SoundScroll
@onready var sound_quit: AudioStreamPlayer = $SoundQuit
@onready var sound_confirm: AudioStreamPlayer = $SoundConfirm

func _ready() -> void:
	sound_main_menu.play()
	
	# Knoppen direct koppelen met callbacks en hover-geluid
	for btn in [start_button, load_button, quit_button]:
		btn.mouse_entered.connect(sound_scroll.play)

	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
	sound_confirm.play()
	await sound_confirm.finished
	GameState.erase_save()
	get_tree().change_scene_to_file("res://scenes/worlds/world_manager.tscn")

func _on_quit_button_pressed() -> void:
	sound_quit.play()
	await sound_quit.finished
	GameState.save_to_disk()
	get_tree().quit()

func _on_load_button_pressed() -> void:
	sound_confirm.play()
	GameState.data[GameState.DataKey.LOAD_SAVE] = true
	await sound_confirm.finished
	get_tree().change_scene_to_file("res://scenes/worlds/world_manager.tscn")

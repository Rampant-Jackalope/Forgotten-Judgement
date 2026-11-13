extends Control

@export_group("Interface")
@export var main_buttons: VBoxContainer
@export var start_button: Button
@export var load_button: Button
@export var settings_button: Button
@export var quit_button: Button

@export_group("Audio Players")
@export var sound_main_menu: AudioStreamPlayer
@export var sound_scroll: AudioStreamPlayer
@export var sound_quit: AudioStreamPlayer
@export var sound_confirm: AudioStreamPlayer

@export_file(".tscn") var settings_scene: String

func _enter_tree() -> void:
	assert(main_buttons)
	assert(start_button)
	assert(load_button)
	assert(settings_button)
	assert(quit_button)

	assert(sound_main_menu)
	assert(sound_scroll)
	assert(sound_quit)
	assert(sound_confirm)

	assert(load(settings_scene))

func _ready() -> void:
	sound_main_menu.play()
	
	# Knoppen direct koppelen met callbacks en hover-geluid

	var buttons = Util.get_descendants_depthfirst(main_buttons, func(v): return v is Button) as Array[Button]
	for button in buttons:
		button.mouse_entered.connect(sound_scroll.play)

	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
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
	Settings.save_settings()
	get_tree().quit()

func _on_load_button_pressed() -> void:
	sound_confirm.play()
	GameState.data[GameState.DataKey.LOAD_SAVE] = true
	await sound_confirm.finished
	get_tree().change_scene_to_file("res://scenes/worlds/world_manager.tscn")

func _on_settings_button_pressed() -> void:
	sound_confirm.play()
	var instance = load(settings_scene).instantiate() as Node
	add_child(instance)
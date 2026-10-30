extends Node

var apathy: int = 0
var empathy: int = 0

# Replace the paths with the actual paths to your audio files!
var apathy_sound = preload("res://assets/sounds/bell_apathy_sound.mp3")
var empathy_sound = preload("res://assets/sounds/Ding - Sound Effect.mp3")

func add_apathy(amount: int = 1) -> void:
	apathy += amount
	show_popup("+1 Apathy", Color.RED, apathy_sound)

func add_empathy(amount: int = 1) -> void:
	empathy += amount
	show_popup("+1 Empathy", Color.GREEN, empathy_sound)

func show_popup(text: String, text_color: Color, sound: AudioStream) -> void:
	# 1. Play the specific sound for the choice
	if sound:
		var player = AudioStreamPlayer.new()
		player.stream = sound
		get_tree().root.add_child(player)
		player.play()
		get_tree().create_timer(3.0).timeout.connect(player.queue_free)

	# 2. Display the popup label on the top-left of the screen
	var current_scene = get_tree().current_scene
	if current_scene:
		var label = Label.new()
		label.text = text
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", text_color)
		
		# Set position to TOP LEFT with a margin
		label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		label.position.x += 20
		label.position.y += 20
		
		current_scene.add_child(label)
		
		# Stay fully visible for 1.5s, then fade out over 1.5s
		var tween = label.create_tween()
		tween.tween_interval(1.5)
		tween.tween_property(label, "modulate:a", 0.0, 1.5).from(1.0)
		tween.tween_callback(label.queue_free)
		
func change_to_fight_scene() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.change_scene_to_file("res://scenes/fights/overworker/overworker_fight.tscn")

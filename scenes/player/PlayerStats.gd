extends Node

var apathy: int = 0
var empathy: int = 0

var stat_sound = preload("res://assets/sounds/Ding - Sound Effect.mp3")

func add_apathy(amount: int = 1) -> void:
	apathy += amount
	show_popup("+1 Apathy", Color.RED)

func add_empathy(amount: int = 1) -> void:
	empathy += amount
	show_popup("+1 Empathy", Color.GREEN)

func show_popup(text: String, text_color: Color) -> void:

	if stat_sound:
		var player = AudioStreamPlayer.new()
		player.stream = stat_sound
		get_tree().root.add_child(player)
		player.play()

		get_tree().create_timer(3.0).timeout.connect(player.queue_free)

	var current_scene = get_tree().current_scene
	if current_scene:
		var label = Label.new()
		label.text = text
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", text_color)
		
		label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		label.position.x += 20
		label.position.y += 20
		
		current_scene.add_child(label)
		
		var tween = label.create_tween()
		tween.tween_interval(1.5) # Wait 1.5 seconds before starting the fade
		tween.tween_property(label, "modulate:a", 0.0, 1.5).from(1.0) # Fade out in 1.5 seconds
		tween.tween_callback(label.queue_free)

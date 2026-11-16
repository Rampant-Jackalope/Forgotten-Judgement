extends CharacterBody2D

@export var health: Health
@export var stamina: Stamina
@export var hands_sprite: AnimatedSprite2D
@export var warning_label: Label # UI Label to display the warning message on screen

signal died()

# Track active tweens to prevent visual bugs when spamming actions or taking rapid damage
var warning_tween: Tween
var damage_tween: Tween

func _ready() -> void:
	assert(health, "Health node is missing!")
	assert(stamina, "Stamina node is missing!")
	assert(hands_sprite, "Hands sprite is missing!")
	
	# Connect health and stamina signals
	health.became_empty.connect(died.emit)
	health.changed.connect(_on_health_changed)
	stamina.consume_failed.connect(_on_stamina_consume_failed)

func _process(_delta: float) -> void:
	update_hands_appearance()

# Update hands opacity based on stamina ratio and update the shader tint parameter
func update_hands_appearance() -> void:
	if not stamina or stamina.max_stamina <= 0:
		return
		
	var stamina_ratio = stamina.get_stamina() / float(stamina.max_stamina)
	
	# 1. Handle opacity via self_modulate
	var target_alpha = clampf(stamina_ratio, 0.2, 1.0)
	var current_color = hands_sprite.self_modulate
	hands_sprite.self_modulate = Color(current_color.r, current_color.g, current_color.b, target_alpha)
	
	# 2. Send stamina ratio to the shader to color the hands green (top 80%)
	var shader_mat = hands_sprite.material as ShaderMaterial
	if shader_mat:
		shader_mat.set_shader_parameter("stamina_ratio", stamina_ratio)

# Triggered when health changes; checks if health decreased (damage taken)
func _on_health_changed(old: int, new: int) -> void:
	if new < old:
		flash_red()

# Triggered automatically when trying to consume stamina fails, receives action name
func _on_stamina_consume_failed(_amount: int, action_name: String) -> void:
	show_stamina_warning("Not enough stamina to " + action_name)

# Display the dynamic warning message on screen with a fade-out effect
func show_stamina_warning(message: String) -> void:
	if not warning_label:
		print(message)
		return
		
	# Kill any ongoing warning tween to reset cleanly if triggered repeatedly
	if warning_tween and warning_tween.is_valid():
		warning_tween.kill()
		
	warning_label.text = message
	warning_label.show()
	warning_label.modulate.a = 1.0 # Ensure full opacity at start
	
	warning_tween = create_tween()
	warning_tween.tween_interval(1.0) # Keep visible for 1 second
	warning_tween.tween_property(warning_label, "modulate:a", 0.0, 0.4) # Fade alpha to 0 over 0.4s
	warning_tween.tween_callback(func(): 
		warning_label.hide()
		warning_label.modulate.a = 1.0 # Reset alpha for the next time
	)

# Flash the hands red when taking damage by utilizing the shader parameter
func flash_red() -> void:
	var shader_mat = hands_sprite.material as ShaderMaterial
	if not shader_mat:
		return
		
	# Kill any ongoing damage tween to ensure smooth re-triggering on rapid hits
	if damage_tween and damage_tween.is_valid():
		damage_tween.kill()
		
	# Enable damage color in the shader
	shader_mat.set_shader_parameter("is_damaged", 1.0)
	
	# Smoothly tween back to normal over 0.15 seconds
	damage_tween = create_tween()
	damage_tween.tween_method(
		func(value: float): shader_mat.set_shader_parameter("is_damaged", value),
		1.0, 0.0, 0.15
	)

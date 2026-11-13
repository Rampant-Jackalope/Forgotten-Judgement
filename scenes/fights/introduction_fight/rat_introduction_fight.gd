extends Node2D

@export var min_attack_interval: float = 0:
	set(value):
		min_attack_interval = value
		if max_attack_interval < value: max_attack_interval = value
@export var max_attack_interval: float = 1:
	set(value):
		max_attack_interval = value
		if min_attack_interval > value: min_attack_interval = value

@onready var attack_cooldown_timer: Timer = Timer.new()
var rng = RandomNumberGenerator.new()

var player: Node2D
var player_controller: PlayerController2D
var player_health: Health

@export var kick_sound_delay: float = 0.5
@export var hurt_audio_player: AudioStreamPlayer2D

var _attacks: Array[AttackBase] = []

func _ready() -> void:
	# Configure and start the attack timer
	attack_cooldown_timer.timeout.connect(_spawn_projectile)
	attack_cooldown_timer.one_shot = true
	add_child(attack_cooldown_timer)

	# Find and validate the player node and its components
	player = get_node("Player2D")
	assert(player != null, "Could not find player node")

	var player_body = player.get_node("Body")
	assert(
		player_body != null,
		"Could not find player body component, cannot connect to death signal",
	)
	player_body.died.connect(_on_player_death)

	player_controller = player_body.get_node("PlayerController2D")
	assert(player_controller != null)

	player_health = player.get_node("Health")
	assert(player_health != null, "Could not find player health component")
	
	assert(hurt_audio_player)

	# Start the initial attack cooldown
	attack_cooldown_timer.wait_time = rng.randf_range(min_attack_interval, max_attack_interval)
	attack_cooldown_timer.start()

	# Gather all available attacks from child nodes
	for child in get_children():
		if child is AttackBase:
			_attacks.push_back(child)

func _spawn_projectile() -> void:
	# Trigger a random attack and restart the cooldown timer
	await _attacks.pick_random().trigger(rng)
	attack_cooldown_timer.wait_time = rng.randf_range(min_attack_interval, max_attack_interval)
	attack_cooldown_timer.start()

func _on_player_death() -> void:
	
	WorldManager.set_world_to_3d()
	ScreenFader.player_death_transition()

func _on_rat_introduction_health_changed(old: int, new: int) -> void:
	if new < old: hurt_audio_player.play()

func _on_rat_introduction_died() -> void:
	Dialogic.VAR.bartender.RatFightCompleted = true
	WorldManager.set_world_to_3d()

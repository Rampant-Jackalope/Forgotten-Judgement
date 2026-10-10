extends Node2D

@export var min_attack_interval: float = 0:
	set(value):
		min_attack_interval = value
		if max_attack_interval < value: max_attack_interval = value
@export var max_attack_interval: float = 1:
	set(value):
		max_attack_interval = value
		if min_attack_interval > value: min_attack_interval = value

@onready var timer: Timer = Timer.new()
var rng = RandomNumberGenerator.new()

var player: Node2D
var player_controller: PlayerController2D
var player_health: Health

@export var kick_sound_delay: float = 0.5
@export var hurt_audio_player: AudioStreamPlayer2D

var _attacks: Array[AttackBase] = []

func _ready() -> void:
	timer.timeout.connect(_spawn_projectile)
	timer.one_shot = true
	add_child(timer)

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

	timer.wait_time = rng.randf_range(min_attack_interval, max_attack_interval)
	timer.start()

	for child in get_children():
		if child is AttackBase:
			_attacks.push_back(child)

func _spawn_projectile() -> void:
	await _attacks.pick_random().trigger(rng)
	timer.wait_time = rng.randf_range(min_attack_interval, max_attack_interval)
	timer.start()

func _on_player_death() -> void:
	# TODO: properly handle this shit doesn't matter too much this is a debugging fight anyway
	get_tree().quit()

# Connected to signal
func _on_michael_health_changed(old: int, new: int) -> void:
	if new < old: hurt_audio_player.play()

# Connected to signal
func _on_michael_died() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/3d-demo-root.tscn") # TODO: Make this good
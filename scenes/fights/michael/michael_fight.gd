extends Node2D

@export var projectile_spawn_interval: float = 0.5

@onready var timer: Timer = Timer.new()
var rng = RandomNumberGenerator.new()

var player: Node2D
var player_controller: PlayerController2D
var player_health: Health

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var kick_sound_delay: float = 0.5

var _attacks: Array[AttackBase] = []

func _ready() -> void:
	timer.one_shot = false
	timer.wait_time = projectile_spawn_interval
	timer.timeout.connect(_spawn_projectile)
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

	timer.start()

	for child in get_children():
		if child is AttackBase:
			_attacks.push_back(child)

func _spawn_projectile() -> void:
	_attacks.pick_random().trigger(rng)

func _on_projectile_hit(damage: int) -> void:
	if player_controller.state == PlayerController2D.State.BLOCKING:
		return
	player_health.damage(damage)

func _on_player_death() -> void:
	# TODO: properly handle this shit doesn't matter too much this is a debugging fight anyway
	get_tree().quit()

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

@onready var enemy_health: Health = $RatIntroduction/Health
@onready var rat_hitbox_collision: CollisionShape2D = $RatIntroduction/Hitbox/CollisionShape2D

@export var kick_sound_delay: float = 0.5
@export var hurt_audio_player: AudioStreamPlayer2D

@onready var scratch_attack: PunchAttack = $RatScratchAttack
@onready var poison_attack: DropItemAttack = $RatDropPoison

var _attacks: Array[AttackBase] = []

func _ready() -> void:
	attack_cooldown_timer.timeout.connect(_spawn_projectile)
	attack_cooldown_timer.one_shot = true
	add_child(attack_cooldown_timer)

	player = get_node("Player2D")
	assert(player != null, "Could not find player node")

	var player_body = player.get_node("Body")
	assert(player_body != null, "Could not find player body component")
	player_body.died.connect(_on_player_death)

	player_controller = player_body.get_node("PlayerController2D")
	assert(player_controller != null)

	player_health = player.get_node("Health")
	assert(player_health != null, "Could not find player health component")
	
	assert(hurt_audio_player)
	assert(scratch_attack, "Could not find RatScratchAttack node!")
	assert(poison_attack, "Could not find RatDropPoison node!")

	for child in get_children():
		if child is AttackBase:
			_attacks.push_back(child)
			
	assert(_attacks.size() > 0, "No attacks found in rat introduction fight!")
	
	if rat_hitbox_collision:
		rat_hitbox_collision.disabled = true
			
	if not has_node("TutorialLayer"):
		start_combat()

func start_combat() -> void:
	if player_health is Health:
		player_health.set_health(player_health.max_health)
	if enemy_health is Health:
		enemy_health.set_health(enemy_health.max_health)

	if rat_hitbox_collision:
		rat_hitbox_collision.disabled = false

	attack_cooldown_timer.wait_time = rng.randf_range(min_attack_interval, max_attack_interval)
	attack_cooldown_timer.start()

func demo_single_attack(index: int) -> void:
	if index == 0:
		await scratch_attack.do()
	elif index == 1:
		await poison_attack.do()

func get_attack_count() -> int:
	return _attacks.size()

func _spawn_projectile() -> void:
	if _attacks.size() > 0:
		await _attacks.pick_random().do()
		
	attack_cooldown_timer.wait_time = rng.randf_range(min_attack_interval, max_attack_interval)
	attack_cooldown_timer.start()

func _on_player_death() -> void:
	PlayerPositionMarkers.transition("Generic_Player_Death")
	WorldManager.set_world_to_3d()
	Util.get_player().run_locked_dialogue("misc-popups", "player_death")

func _on_rat_health_changed(old: int, new: int) -> void:
	if new < old: hurt_audio_player.play()

func _on_rat_died() -> void:
	DialogicFlags.set_fought(DialogicFlags.Npc.RAT, true)
	WorldManager.set_world_to_3d()

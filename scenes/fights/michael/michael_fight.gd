extends Node2D

@export var projectile_spawn_interval: float = 0.5
@export var projectile_types: Array[PackedScene]

@onready var timer: Timer = Timer.new()
var rng := RandomNumberGenerator.new()

@onready var player: Node2D = $Player2D
@onready var player_controller: PlayerController2D = $Player2D/Body/PlayerController2D
@onready var player_health: Health = $Player2D/Health

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	timer.one_shot = false
	timer.wait_time = projectile_spawn_interval
	timer.timeout.connect(_spawn_projectile)
	add_child(timer)

	assert(player_health != null)

	var player_body := player.get_node("Body")
	if not player_body:
		push_error("Could not find player body component, cannot connect to death signal")
	player_body.died.connect(_on_player_death)

	assert(player_controller != null)

	timer.start()

func _spawn_projectile() -> void:
	if projectile_types.is_empty():
		push_error("No projectile types defined")
		return
	var scene: PackedScene = projectile_types.pick_random()
	var instance := scene.instantiate()
	if not instance:
		push_error("Could not spawn projectile instance.")
		return
	if not instance.has_signal("hit"):
		push_error("assigned projectile instance does not have a hit signal")
	instance.hit.connect(_on_projectile_hit)

	if is_instance_of(instance, LinearProjectile):
		kick_shoe(instance)
	elif is_instance_of(instance, FallingProjectile):
		drop_gloves(instance)
	else:
		push_error("Unknown projectile type found in projectile_types array")

func kick_shoe(instance: Node) -> void:
	var viewport_size := get_viewport_rect().size
	var min_x  = viewport_size.x * 0.2
	var min_y = viewport_size.y * 0.2
	var max_x = viewport_size.x * 0.8
	var max_y = viewport_size.y * 0.8

	instance.position.y = rng.randf_range(min_y, max_y)
	instance.position.x = rng.randf_range(min_x, max_x)
	
	add_child(instance)
	audio_player.play()

func drop_gloves(instance: Node) -> void:
	instance.position.y = -300
	instance.position.x = rng.randf_range(0, get_viewport_rect().size.x)
	add_child(instance)

func _on_projectile_hit(damage: int) -> void:
	if player_controller.state == PlayerController2D.State.BLOCKING:
		return
	player_health.damage(damage)

func _on_player_death() -> void:
	get_tree().quit()

extends Node2D

@export var projectile_spawn_interval: float = 0.5
@export var projectile: PackedScene

@onready var timer: Timer = Timer.new()
var rng := RandomNumberGenerator.new()

@onready var player: Node2D = $Player2D
var player_controller: PlayerController2D 
var player_health: Health

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	timer.one_shot = false
	timer.wait_time = projectile_spawn_interval
	timer.timeout.connect(_spawn_projectile)
	add_child(timer)

	player_health = player.get_node("Health")
	if not player_health:
		push_error("Could not find player health component")
	var player_body := player.get_node("Body")
	if not player_body:
		push_error("Could not find player body component")
	player_body.died.connect(_on_player_death)
	
	player_controller = player_body.get_node("PlayerController2D")
	if not player_controller:
		push_error("Could not find player controller component")

	timer.start()

func _spawn_projectile() -> void:
	var instance := projectile.instantiate()
	if not instance:
		push_error("Could not spawn projectile instance.")
		return
	instance.position.y = -300
	instance.position.x = rng.randf_range(0, get_viewport_rect().size.x)
	if not instance.has_signal("hit"):
		push_error("assigned projectile instance does not have a hit signal")
	instance.hit.connect(_on_projectile_hit)
	add_child(instance)

func _on_projectile_hit(damage: int) -> void:
	if player_controller.state == PlayerController2D.State.BLOCKING:
		return
	player_health.damage(damage)

func _on_player_death() -> void:
	get_tree().quit()

class_name MichaelKickAttack
extends AttackBase

@export var scene: PackedScene
@export var kick_sound_delay: float
@export var audio_player: AudioStreamPlayer2D

func _ready() -> void:
	assert(scene)
	assert(kick_sound_delay >= 0)
	assert(audio_player)

func do() -> void:
	var viewport_size = get_viewport_rect().size
	var min_x = viewport_size.x * 0.2
	var min_y = viewport_size.y * 0.2
	var max_x = viewport_size.x * 0.8
	var max_y = viewport_size.y * 0.8

	var instance = scene.instantiate()

	instance.position.y = random.randf_range(min_y, max_y)
	instance.position.x = random.randf_range(min_x, max_x)

	add_child(instance)
	await get_tree().create_timer(kick_sound_delay).timeout
	audio_player.play()
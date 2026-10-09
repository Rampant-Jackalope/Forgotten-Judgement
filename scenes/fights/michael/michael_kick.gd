class_name MichaelKickAttack
extends AttackBase

@export var scene: PackedScene
@export var attack_positions: Array[Vector2] = []
@export var audio_player: AudioStreamPlayer2D
@export var animator: AnimatedSprite2D
@export var animation_name: StringName
@export var trigger_frame: int
@export var anchor: Sprite2DAnchor

func _ready() -> void:
	assert(scene)
	assert(audio_player)
	assert(anchor)

	assert(animator)
	assert(animator.sprite_frames.has_animation(animation_name))
	assert(animator.sprite_frames.get_frame_count(animation_name) > trigger_frame)
	animator.frame_changed.connect(_animation_frame_changed)

func _animation_frame_changed():
	if animator.animation == animation_name and animator.frame == trigger_frame:
		_animation_frame_triggered()

func _animation_frame_triggered():
	var pos = attack_positions.map(func(v): return get_viewport_rect().size * v).pick_random()

	var instance = scene.instantiate()
	instance.position = pos
	add_child(instance)

	anchor.enabled = false
	animator.position = pos

	await animator.animation_finished

	anchor.enabled = true

	audio_player.play()

func do() -> void:
	var prev_animation = animator.animation
	animator.play(animation_name)
	await animator.animation_finished
	animator.play(prev_animation)
class_name MichaelKickAttack
extends AttackBase

@export var scene: PackedScene
@export var attack_positions: Array[Vector2] = []
@export var animator: AnimatedSprite2D
@export var animation_name: StringName
@export var trigger_frame: int
@export var anchor: Sprite2DAnchor
@export var audio_player: AudioStreamPlayer2D

func _ready() -> void:
	assert(scene)
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
	if audio_player:
		var punch_modifier = Util.find_descendant_breadthfirst(instance, func(v): return v is PunchModifier) as PunchModifier
		if punch_modifier: punch_modifier.audio_player = audio_player
	add_child(instance)

	anchor.enabled = false
	animator.position = pos

	await animator.animation_finished

	anchor.enabled = true

func do() -> void:
	var prev_animation = animator.animation
	animator.play(animation_name)
	await animator.animation_finished
	animator.play(prev_animation)
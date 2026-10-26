class_name MichaelHatDropAttack
extends AttackBase

@export var scene: PackedScene
@export var animator: AnimatedSprite2D
@export var animation_name: StringName
@export var trigger_frame: int

func _ready() -> void:
	assert(scene)

	assert(animator)
	assert(animator.sprite_frames.has_animation(animation_name))
	assert(animator.sprite_frames.get_frame_count(animation_name) > trigger_frame)
	animator.frame_changed.connect(_animation_frame_changed)

func _animation_frame_changed():
	if animator.animation == animation_name and animator.frame == trigger_frame:
		_animation_frame_triggered()

func _animation_frame_triggered():
	var instance = scene.instantiate()
	instance.position.y = -300
	instance.position.x = random.randf_range(0, get_viewport_rect().size.x)
	add_child(instance)

func do() -> void:
	var prev_animation = animator.animation
	animator.play(animation_name)
	await animator.animation_finished
	animator.play(prev_animation)

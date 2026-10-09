class_name MichaelHatDropAttack
extends AttackBase

@export var scene: PackedScene

func _ready() -> void:
	assert(scene)

func do() -> void:
	var instance = scene.instantiate()
	instance.position.y = -300
	instance.position.x = random.randf_range(0, get_viewport_rect().size.x)
	add_child(instance)
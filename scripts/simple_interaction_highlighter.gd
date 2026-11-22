extends MeshInstance3D

@export var interactable: Interactable

var _material: ShaderMaterial:
	set(value):
		_material = value
		get_active_material(0).next_pass = value

func _enter_tree() -> void:
	assert(interactable is Interactable, "No Interactable assigned")

	_material = ShaderMaterial.new()
	_material.shader = preload("res://shaders/interactable_highlight.gdshader")

func _ready() -> void:
	interactable.highlight_on.connect(func(): set_instance_shader_parameter("enabled", true))
	interactable.highlight_off.connect(func(): set_instance_shader_parameter("enabled", false))

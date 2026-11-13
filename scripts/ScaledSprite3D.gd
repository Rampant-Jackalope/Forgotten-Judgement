@tool
extends Sprite3D
class_name ScaledSprite3D

const OUTLINE_SHADER := preload("res://shaders/sprite_outline.gdshader")

## Desired world height of the whole image, in meters.
@export var height_m: float = 1.8:
	set(value):
		height_m = value
		_update_scale()

@export var highlighted: bool = false:
	set(value):
		highlighted = value
		_apply_highlight()

var _mat: ShaderMaterial

func _enter_tree() -> void:
	billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	if _mat == null:
		_mat = ShaderMaterial.new()
		_mat.shader = OUTLINE_SHADER
	material_override = _mat
	if not texture_changed.is_connected(_update_scale):
		texture_changed.connect(_update_scale)
	_update_scale()
	_apply_highlight()

func set_highlight(value: bool) -> void:
	highlighted = value

func enable_highlight() -> void:
	highlighted = true

func disable_highlight() -> void:
	highlighted = false

func toggle_highlight() -> void:
	highlighted = not highlighted

func _update_scale() -> void:
	if texture == null:
		return
	pixel_size = height_m / float(texture.get_height())
	if _mat:
		_mat.set_shader_parameter("tex", texture)

func _apply_highlight() -> void:
	if _mat:
		_mat.set_shader_parameter("enabled", highlighted)

@tool
extends Sprite3D
class_name ScaledSprite3D

## Desired world height of the whole image, in meters.
@export var height_m: float = 1.8:
	set(value):
		height_m = value
		_update_scale()

func _enter_tree() -> void:
	billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	if not texture_changed.is_connected(_update_scale):
		texture_changed.connect(_update_scale)
	_update_scale()

func _update_scale() -> void:
	if texture == null:
		return
	pixel_size = height_m / float(texture.get_height())

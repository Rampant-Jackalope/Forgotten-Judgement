extends Sprite3D
class_name ScaledSprite3D

func _enter_tree() -> void:
	pixel_size = 0.01/6
	self.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

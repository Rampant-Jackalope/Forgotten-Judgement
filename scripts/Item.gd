class_name Item
extends Node

@export var id: String
@export var item_icon: Texture2D = null
@export var highlight_sprite: Sprite3D = null

func get_item_icon() -> Texture2D:
	return self.item_icon

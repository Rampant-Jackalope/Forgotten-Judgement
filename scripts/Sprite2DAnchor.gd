class_name Sprite2DAnchor
extends Node

enum AnchorH {LEFT, CENTER, RIGHT}
enum AnchorV {TOP, CENTER, BOTTOM}

@export var adornee = get_parent()
@export var enabled: bool = true:
	set(value):
		enabled = value
		if value: update_position()

@export var own_anchor_h: AnchorH ## The horizontal anchor that the sprite will attach *with*
@export var own_anchor_v: AnchorV ## The vertical anchor that the sprite will attach *with*

@export var parent_anchor_h: AnchorH ## The horizontal anchor that the sprite will attach *to*
@export var parent_anchor_v: AnchorV ## The vertical anchor that the sprite will attach *to*

@export var alignment_offset: Vector2 ## Additional offset

func _anchor_uv(h: AnchorH, v: AnchorV) -> Vector2:
	var x: float
	var y: float
	match h:
		AnchorH.LEFT:   x = 0.0
		AnchorH.CENTER: x = 0.5
		AnchorH.RIGHT:  x = 1.0
	match v:
		AnchorV.TOP:    y = 0.0
		AnchorV.CENTER: y = 0.5
		AnchorV.BOTTOM: y = 1.0
	return Vector2(x, y)

func _calculate_position() -> Vector2:
	var own_rect
	if adornee is Sprite2D:
		own_rect = adornee.get_rect()
	elif adornee is AnimatedSprite2D:
		var size = adornee.sprite_frames.get_frame_texture(adornee.animation, adornee.frame).get_size()
		own_rect = Rect2(adornee.position - size / 2, size)
	var parent_rect = get_viewport().get_visible_rect()

	var own_uv    = _anchor_uv(own_anchor_h,    own_anchor_v)
	var parent_uv = _anchor_uv(parent_anchor_h, parent_anchor_v)

	var own_offset    = (own_uv - Vector2(.5, .5)) * own_rect.size # Hardcoded vector accounts for origin being in the center of the rect # TODO: Calculate this somehow?
	var parent_offset = parent_uv * parent_rect.size
	var offset_to_parent = parent_offset - own_offset + alignment_offset

	return parent_rect.position + offset_to_parent

func update_position() -> void:
	if enabled: adornee.position = _calculate_position()

func _ready():
	assert(adornee is Sprite2D or adornee is AnimatedSprite2D)

	get_viewport().size_changed.connect(update_position)
	if adornee is Sprite2D: adornee.texture_changed.connect(update_position)
	elif adornee is AnimatedSprite2D: adornee.frame_changed.connect(update_position)

	update_position()

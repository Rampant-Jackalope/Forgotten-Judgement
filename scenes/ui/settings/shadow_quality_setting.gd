extends Control

@export var input: OptionButton

func _enter_tree() -> void:
	assert(input)

	input.selected = Settings.shadow_quality
	input.item_selected.connect(func(v): Settings.shadow_quality = v as Settings.ShadowQuality)

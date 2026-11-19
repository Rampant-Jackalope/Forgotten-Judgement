class_name GraphicsPresetsOptionButton extends OptionButton

class GraphicsSettings extends Resource:
	@export var label: String

	@export var shadow_quality: Settings.ShadowQuality
	@export var anti_aliasing: Settings.AntiAliasingMode

	func _init(
		label: String,
		shadow_quality: Settings.ShadowQuality,
		anti_aliasing: Settings.AntiAliasingMode,
	) -> void:
		assert(label != null)
		assert(shadow_quality != null)
		assert(anti_aliasing != null)

		self.label = label
		self.shadow_quality = shadow_quality
		self.anti_aliasing = anti_aliasing
	
	func matches(other: GraphicsSettings) -> bool:
		if self == other: return true

		if self.shadow_quality != other.shadow_quality: return false
		if self.anti_aliasing  != other.anti_aliasing:  return false

		return true

var presets: Array[GraphicsSettings] = [
	GraphicsSettings.new("Potato",
		Settings.ShadowQuality.POTATO,
		Settings.AntiAliasingMode.DISABLED,
	),
	GraphicsSettings.new("Low",
		Settings.ShadowQuality.LOW,
		Settings.AntiAliasingMode.FXAA,
	),
	GraphicsSettings.new("Medium",
		Settings.ShadowQuality.MEDIUM,
		Settings.AntiAliasingMode.SMAA,
	),
	GraphicsSettings.new("High",
		Settings.ShadowQuality.HIGH,
		Settings.AntiAliasingMode.TAA,
	),
	GraphicsSettings.new("Ultra",
		Settings.ShadowQuality.ULTRA,
		Settings.AntiAliasingMode.TAA,
	),
]

@export_group("References")
@export var shadow_quality_input: OptionButton
@export var anti_aliasing_input: OptionButton

var _current: int = -1:
	set(value):
		_current = value
		if value >= 0:
			self.selected = value
		else:
			self.selected = self.item_count - 1

func _enter_tree() -> void:
	assert(shadow_quality_input)
	assert(anti_aliasing_input)

	for i in range(presets.size()):
		var preset = presets[i]
		self.add_item(preset.label, i)
	self.add_item("Custom", -1); self.set_item_disabled(-1, true)

	update_current()
	self.item_selected.connect(_item_selected)

	shadow_quality_input.item_selected.connect(func(_v): update_current())
	anti_aliasing_input.item_selected.connect(func(_v): update_current())

func update_current():
	var current = GraphicsSettings.new("temp",
		Settings.shadow_quality,
		Settings.anti_aliasing,
	)
	for i in range(presets.size()):
		var preset = presets[i] as GraphicsSettings
		if current.matches(preset):
			_current = i
			return
	_current = -1

func _item_selected(id: int) -> void:
	if id < 0: return

	var preset = presets[id]
	shadow_quality_input.selected = preset.shadow_quality; Settings.shadow_quality = preset.shadow_quality
	anti_aliasing_input.selected  = preset.anti_aliasing;  Settings.anti_aliasing  = preset.anti_aliasing

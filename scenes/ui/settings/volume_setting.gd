extends Control

@export_group("Settings")
@export var bus_name: StringName = "Bus Name":
	set(value):
		bus_name = value
		if label: label.text = value

@export_group("References")
@export var slider: Range
@export var spin_box: SpinBox
@export var label: Label

@export_range(0.0, 200.0) var _value: float = 100.0:
	set(value):
		_value = value

		Settings.set_volume(bus_name, value / 100.0)

		if slider.value != value: slider.value = value
		if spin_box.value != value: spin_box.value = value

func _enter_tree() -> void:
	assert(slider)
	assert(spin_box)
	assert(label)

	_value = roundf(Settings.bus_volumes[bus_name] * 100.0)
	label.text = bus_name

	slider.value_changed.connect(func(v): _value = v)
	spin_box.value_changed.connect(func(v): _value = v)

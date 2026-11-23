extends Node

const SETTINGS_FILE_PATH: String = "user://settings.json"

@export_category("Game")
@export var show_action_hints: bool = true
@export var show_save_indicator: bool = true

@export_category("Video")
@export_group("Size")
enum WindowMode {WINDOWED, FULLSCREEN, BORDERLESS_FULLSCREEN}
@export var window_mode: WindowMode = WindowMode.BORDERLESS_FULLSCREEN:
	set(value):
		window_mode = value
		match value:
			WindowMode.WINDOWED:              DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			WindowMode.FULLSCREEN:            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			WindowMode.BORDERLESS_FULLSCREEN: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			_: assert(false)
		resolution = resolution
@export var resolution: Vector2i = DisplayServer.screen_get_size():
	set(value):
		resolution = value
		if window_mode == WindowMode.WINDOWED:
			DisplayServer.window_set_size(value)
		get_tree().root.size = value

@export_group("Frame timing")
enum VSyncMode {DISABLED, NORMAL, ADAPTIVE}
@export var v_sync: VSyncMode = VSyncMode.ADAPTIVE:
	set(value):
		v_sync = value
		match value:
			VSyncMode.DISABLED: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			VSyncMode.NORMAL:   DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			VSyncMode.ADAPTIVE: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
			_: assert(false)
@export_range(0, 1000) var framerate_limit: int = 0:
	set(value):
		framerate_limit = value
		Engine.max_fps = value

@export_category("Graphics")
enum AntiAliasingMode {DISABLED, FXAA, SMAA, MSAA2, MSAA4, MSAA8, TAA}
@export var anti_aliasing: AntiAliasingMode = AntiAliasingMode.MSAA4:
	set(value):
		anti_aliasing = value
		var viewport = get_viewport()
		match value:
			AntiAliasingMode.DISABLED:
				viewport.msaa_3d         = Viewport.MSAA_DISABLED
				viewport.msaa_2d         = Viewport.MSAA_DISABLED
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
				viewport.use_taa         = false
			AntiAliasingMode.FXAA:
				viewport.msaa_3d         = Viewport.MSAA_DISABLED
				viewport.msaa_2d         = Viewport.MSAA_DISABLED
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
				viewport.use_taa         = false
			AntiAliasingMode.SMAA:
				viewport.msaa_3d         = Viewport.MSAA_DISABLED
				viewport.msaa_2d         = Viewport.MSAA_DISABLED
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_SMAA
				viewport.use_taa         = false
			AntiAliasingMode.MSAA2:
				viewport.msaa_3d         = Viewport.MSAA_2X
				viewport.msaa_2d         = Viewport.MSAA_2X
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
				viewport.use_taa         = false
			AntiAliasingMode.MSAA4:
				viewport.msaa_3d         = Viewport.MSAA_4X
				viewport.msaa_2d         = Viewport.MSAA_4X
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
				viewport.use_taa         = false
			AntiAliasingMode.MSAA8:
				viewport.msaa_3d         = Viewport.MSAA_8X
				viewport.msaa_2d         = Viewport.MSAA_8X
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
				viewport.use_taa         = false
			AntiAliasingMode.TAA:
				viewport.msaa_3d         = Viewport.MSAA_DISABLED
				viewport.msaa_2d         = Viewport.MSAA_DISABLED
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
				viewport.use_taa         = true
			_: assert(false)
enum ShadowQuality {POTATO, VERY_LOW, LOW, MEDIUM, HIGH, ULTRA}
@export var shadow_quality: ShadowQuality = ShadowQuality.LOW:
	set(value):
		shadow_quality = value
		match value:
			ShadowQuality.POTATO:
				get_viewport().positional_shadow_atlas_size = 512
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
			ShadowQuality.VERY_LOW:
				get_viewport().positional_shadow_atlas_size = 512
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
			ShadowQuality.LOW:
				get_viewport().positional_shadow_atlas_size = 1024
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			ShadowQuality.MEDIUM:
				get_viewport().positional_shadow_atlas_size = 2048
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			ShadowQuality.HIGH:
				get_viewport().positional_shadow_atlas_size = 2048
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			ShadowQuality.ULTRA:
				get_viewport().positional_shadow_atlas_size = 4096
				RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
				RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
			_: assert(false)

var _bus_volumes: Dictionary[StringName, float] = {}
@export var bus_volumes: Dictionary[StringName, float]:
	get: return Util.dict_as_readonly(_bus_volumes)
	set(v): pass
func set_volume(bus_name: StringName, volume: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0: return
	_bus_volumes[bus_name] = volume
	AudioServer.set_bus_volume_linear(bus_idx, volume)

var _prev_window_mode: DisplayServer.WindowMode
func _process(_delta: float) -> void:
	var current_window_mode = DisplayServer.window_get_mode()
	if _prev_window_mode == null: _prev_window_mode = current_window_mode

	if current_window_mode != _prev_window_mode:
		match current_window_mode:
			DisplayServer.WINDOW_MODE_WINDOWED:             window_mode = WindowMode.WINDOWED
			DisplayServer.WINDOW_MODE_MINIMIZED:            pass
			DisplayServer.WINDOW_MODE_MAXIMIZED:            window_mode = WindowMode.WINDOWED
			DisplayServer.WINDOW_MODE_FULLSCREEN:           window_mode = WindowMode.FULLSCREEN
			DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN: window_mode = WindowMode.FULLSCREEN
			_: assert(false)
		_prev_window_mode = current_window_mode

@export_group("Controls")
@export var sensitivity: float = 0.14: ## Sensitivity in °/px
	set(value):
		sensitivity = value
		sensitivity_changed.emit()
signal sensitivity_changed()
var controls: Dictionary[StringName, InputEvent] = {}

func _ready() -> void:
	get_viewport().size_changed.connect(func(): resolution = get_viewport().size)

	for bus_idx in range(AudioServer.bus_count):
		var bus_name = AudioServer.get_bus_name(bus_idx)
		_bus_volumes[bus_name] = AudioServer.get_bus_volume_linear(bus_idx)

	load_settings()

func _exit_tree() -> void:
	save_settings()

func save_settings():
	var save_file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)

	var save_controls: Dictionary[StringName, Dictionary] = {}
	for action in controls.keys():
		if InputMap.get_action_description(action) == null: continue
		if controls[action] == null: continue # For some reason the loop *does* do these
		save_controls[action] = dictionarise_inputevent(controls[action])

	var save_dict = {
		"show_action_hints":   self.show_action_hints,
		"show_save_indicator": self.show_save_indicator,
		"window_mode":         self.window_mode,
		"resolution_x":        self.resolution.x,
		"resolution_y":        self.resolution.y,
		"v_sync":              self.v_sync,
		"framerate_limit":     self.framerate_limit,
		"anti_aliasing":       self.anti_aliasing,
		"volume":              self._bus_volumes,
		"sensitivity":         self.sensitivity,
		"controls":            save_controls,
	}

	var json_string = JSON.stringify(save_dict)
	save_file.store_string(json_string)

	save_file.close()
func load_settings() -> bool:
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		return false

	var save_file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	
	var json_string = ""
	while save_file.get_position() < save_file.get_length():
		json_string += save_file.get_line()
	save_file.close()
	
	var save_dict = JSON.parse_string(json_string)

	if save_dict == null:
		push_error("Tried to load empty/corrupt settings")
		return false

	if save_dict.has("show_action_hints"):                              self.show_action_hints   = save_dict.show_action_hints
	if save_dict.has("show_save_indicator"):                            self.show_save_indicator = save_dict.show_save_indicator
	if save_dict.has("window_mode"):                                    self.window_mode         = save_dict.window_mode
	if save_dict.has("resolution_x") and save_dict.has("resolution_y"): self.resolution          = Vector2i(save_dict.resolution_x, save_dict.resolution_y)
	if save_dict.has("v_sync"):                                         self.v_sync              = save_dict.v_sync
	if save_dict.has("framerate_limit"):                                self.framerate_limit     = save_dict.framerate_limit
	if save_dict.has("anti_aliasing"):                                  self.anti_aliasing       = save_dict.anti_aliasing
	if save_dict.has("sensitivity"):                                    self.sensitivity         = save_dict.sensitivity

	if save_dict.has("controls"): for action in save_dict.controls.keys():
		if InputMap.get_action_description(action) == null: continue
		var event = dedictionarise_inputevent(save_dict.controls[action])
		self.controls[action] = event
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

	if save_dict.has("volume"): for bus_name in save_dict.volume.keys():
		if AudioServer.get_bus_index(bus_name) >= 0: set_volume(bus_name, save_dict.volume[bus_name])

	return true

func dictionarise_inputevent(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {
			"type": "key",

			"key": event.keycode,
			"modifiers": {
				"shift": event.shift_pressed,
				"ctrl":  event.ctrl_pressed,
				"alt":   event.alt_pressed,
				"meta":  event.meta_pressed,
			},
		}
	elif event is InputEventMouseButton:
		return {
			"type": "mouse_button",

			"button": event.button_index,
			"modifiers": {
				"shift": event.shift_pressed,
				"ctrl":  event.ctrl_pressed,
				"alt":   event.alt_pressed,
				"meta":  event.meta_pressed,
			},
		}
	
	assert(false, "Cannot dictionarise unknown InputEvent: " + str(event))
	return {} # Impossible to run, is to calm the LSP
func dedictionarise_inputevent(dict: Dictionary) -> InputEvent:
	if dict.type == null:
		push_error("Cannot dedictionarise dict " + JSON.stringify(dict) + ": No 'type' is present")
		return null

	match dict.type:
		"key":
			assert(dict.key is float) # JSON.parse_string only outputs floats
			var event = InputEventKey.new()
			event.keycode = int(dict.key)
			var modifiers = dict.modifiers
			event.shift_pressed = modifiers.shift
			event.ctrl_pressed  = modifiers.ctrl
			event.alt_pressed   = modifiers.alt
			event.meta_pressed  = modifiers.meta
			event.pressed = true
			return event
		"mouse_button":
			assert(dict.button)
			var event = InputEventMouseButton.new()
			event.button_index = dict.button
			var modifiers = dict.modifiers
			event.shift_pressed = modifiers.shift
			event.ctrl_pressed  = modifiers.ctrl
			event.alt_pressed   = modifiers.alt
			event.meta_pressed  = modifiers.meta
			event.pressed = true
			return event

	assert(false, "Cannot dedictionarise dict " + JSON.stringify(dict) + ": Unknown 'type'")
	return null # Impossible to run, is to calm the LSP

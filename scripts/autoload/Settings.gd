extends Node

const SETTINGS_FILE_PATH: String = "user://settings.json"

@export_category("Game")
@export var quick_restart: bool = false ## Quickly restart gameplay after a game over, skipping the game over screen

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
enum AntiAliasingMode {DISABLED, MSAA2, MSAA4, MSAA8, FXAA, SMAA, TAA}
@export var anti_aliasing: AntiAliasingMode = AntiAliasingMode.MSAA4:
	set(value):
		anti_aliasing = value
		# TODO: Implement

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

	var save_dict = {
		"quick_restart":   self.quick_restart,
		"window_mode":     self.window_mode,
		"resolution_x":    self.resolution.x,
		"resolution_y":    self.resolution.y,
		"v_sync":          self.v_sync,
		"framerate_limit": self.framerate_limit,
		"anti_aliasing":   self.anti_aliasing,
		"volume":          self._bus_volumes,
	}

	var json_string = JSON.stringify(save_dict)
	print("saving: " + json_string)
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

	print("loading: " + json_string)
	
	var save_dict = JSON.parse_string(json_string)

	assert(save_dict)

	self.quick_restart   = save_dict.quick_restart
	self.window_mode     = save_dict.window_mode
	self.resolution      = Vector2i(save_dict.resolution_x, save_dict.resolution_y)
	self.v_sync          = save_dict.v_sync
	self.framerate_limit = save_dict.framerate_limit
	self.anti_aliasing   = save_dict.anti_aliasing

	if save_dict.volume: for bus_name in save_dict.volume.keys():
		if AudioServer.get_bus_index(bus_name) >= 0: set_volume(bus_name, save_dict.volume[bus_name])

	return true
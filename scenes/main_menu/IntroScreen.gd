extends Node2D

@export_file("*.tscn") var main_menu_scene: String = "res://scenes/main_menu/user_interface.tscn"
@export_dir var frame_folder := "res://assets/introscreen/introscreen-frames/"
@export var fps := 30.0

@onready var texture_player: TextureRect = %TextureRect

var frames: Array[Texture2D] = []
var current_frame := 0
var elapsed := 0.0
var _is_changing_scene: bool = false

func _ready() -> void:
	if texture_player:
		texture_player.custom_minimum_size = Vector2(1920, 1080)
		texture_player.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		if not frame_folder.is_empty():
			_load_frames(frame_folder)
	else:
		push_error("TextureRect kon niet worden gevonden!")

func _process(delta: float) -> void:
	if frames.is_empty() or fps <= 0.0 or _is_changing_scene:
		return

	elapsed += delta
	var frame_time := 1.0 / fps

	while elapsed >= frame_time:
		elapsed -= frame_time
		_advance_frame()

func _load_frames(dir_path: String) -> void:
	frames.clear()
	current_frame = 0
	elapsed = 0.0

	var path := dir_path
	if not path.ends_with("/"):
		path += "/"

	var directory := DirAccess.open(path)
	if directory == null:
		push_error("Map kon niet worden geopend: " + path)
		return

	var files := directory.get_files()
	files.sort()

	for file in files:
		if file.ends_with(".png") and not file.ends_with(".png.import"):
			var tex := load(path + file) as Texture2D
			if tex:
				frames.append(tex)

	if not frames.is_empty():
		texture_player.texture = frames[0]

func _advance_frame() -> void:
	if frames.is_empty():
		return

	current_frame += 1

	# Als alle frames zijn afgespeeld, ga door naar het hoofdmenu
	if current_frame >= frames.size():
		_go_to_main_menu()
	else:
		texture_player.texture = frames[current_frame]

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			_go_to_main_menu()

func _go_to_main_menu() -> void:
	if _is_changing_scene:
		return
	_is_changing_scene = true
	
	get_tree().change_scene_to_file(main_menu_scene)

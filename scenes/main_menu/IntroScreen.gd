extends Node2D

@export_file("*.tscn") var main_menu_scene: String = "res://scenes/main_menu/user_interface.tscn"

# Gebruikt de unieke naam (%VideoStreamPlayer) zodat het pad altijd werkt
@onready var video_player: VideoStreamPlayer = %VideoStreamPlayer

var _is_changing_scene: bool = false

func _ready() -> void:
	if video_player:
		# Zorg dat de video het volledige scherm vult (1920x1080)
		video_player.custom_minimum_size = Vector2(1920, 1080)
		video_player.expand = true
		
		# Signaal koppelen voor als de video klaar is
		if not video_player.finished.is_connected(_on_video_finished):
			video_player.finished.connect(_on_video_finished)
		
		# Start de video
		video_player.play()
	else:
		push_error("VideoStreamPlayer kon niet worden gevonden!")

func _input(event: InputEvent) -> void:
	# Overslaan met toets of muisklik
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			_go_to_main_menu()

func _on_video_finished() -> void:
	_go_to_main_menu()

func _go_to_main_menu() -> void:
	if _is_changing_scene:
		return
	_is_changing_scene = true
	
	if video_player and video_player.is_playing():
		video_player.stop()
		
	get_tree().change_scene_to_file(main_menu_scene)

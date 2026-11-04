extends VideoStreamPlayer

@export_file("*.tscn") var main_menu_scene: String = "res://scenes/main_menu/user_interface.tscn"

var _is_changing_scene: bool = false

func _ready() -> void:
	self.finished.connect(_go_to_main_menu)


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			_go_to_main_menu()

func _go_to_main_menu() -> void:
	if _is_changing_scene:
		return
	_is_changing_scene = true
	
	get_tree().change_scene_to_file(main_menu_scene)

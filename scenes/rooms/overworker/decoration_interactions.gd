extends Node3D

@onready var coffee_machine: MeshInstance3D = $Coffee_machine2/Coffee_machine
@onready var water_cooler: MeshInstance3D = $Water_cooler2/Water_cooler

# Desk items need to be highlighted at the same time
@onready var desk: MeshInstance3D = $Cube2/Cube
@onready var floppy: MeshInstance3D = $FloppyDisk2/FloppyDisk
@onready var puter: MeshInstance3D = $Macintosh2/Macintosh
@onready var mouse: MeshInstance3D = $Mouse2/Mouse
@onready var mouse_cable: MeshInstance3D = $MouseCable2/MouseCable
@onready var printer: MeshInstance3D = $Printer2/Printer
@onready var keyboard: MeshInstance3D = $ShittyKeyboard2/ShittyKeyboard

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_interactable_interacted(_interactor: Interactor, _pop: Callable) -> void:
	Dialogic.VAR.overworker.warnings += 1
	Util.get_player().run_locked_dialogue("overworker-warning")

func _on_dialogic_signal(action: String) -> void:
	if action == "fight":
		Dialogic.VAR.overworker.warnings = 0
		WorldManager.set_world_to_2d("overworker_fight")

func water_cooler_highlight_on():
	water_cooler.set_instance_shader_parameter("enabled", true)

func water_cooler_highlight_off():
	water_cooler.set_instance_shader_parameter("enabled", false)

func coffee_machine_highlight_on():
	coffee_machine.set_instance_shader_parameter("enabled", true)

func coffee_machine_highlight_off():
	coffee_machine.set_instance_shader_parameter("enabled", false)

func desk_highlight_on():
	desk.set_instance_shader_parameter("enabled", true)
	floppy.set_instance_shader_parameter("enabled", true)
	puter.set_instance_shader_parameter("enabled", true)
	mouse.set_instance_shader_parameter("enabled", true)
	mouse_cable.set_instance_shader_parameter("enabled", true)
	printer.set_instance_shader_parameter("enabled", true)
	keyboard.set_instance_shader_parameter("enabled", true)

func desk_highlight_off():
	desk.set_instance_shader_parameter("enabled", false)
	floppy.set_instance_shader_parameter("enabled", false)
	puter.set_instance_shader_parameter("enabled", false)
	mouse.set_instance_shader_parameter("enabled", false)
	mouse_cable.set_instance_shader_parameter("enabled", false)
	printer.set_instance_shader_parameter("enabled", false)
	keyboard.set_instance_shader_parameter("enabled", false)

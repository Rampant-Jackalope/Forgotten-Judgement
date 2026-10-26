@tool
extends Node3D

@export var radius: float = 10.0:
	set(value):
		radius = value
		if is_inside_tree():
			_update_positions()

@export var cycle_speed_deg: float = 15.0:  ## degrees per second
	set(value):
		cycle_speed_deg = value
		if is_inside_tree():
			_update_positions()

@onready var moon := $Moon
@onready var sun := $Sun
@onready var sun_light := $Sun/Light

var angle: float = 0.0

func _ready() -> void:
	_update_positions()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	angle += deg_to_rad(cycle_speed_deg) * delta
	_update_positions()

func _update_positions() -> void:
	sun.position = Vector3(cos(angle), sin(angle), 0.0) * radius
	moon.position = Vector3(cos(angle + deg_to_rad(180)), sin(angle + deg_to_rad(180)), 0.0) * radius

	sun_light.look_at(Vector3.ZERO, Vector3.UP)

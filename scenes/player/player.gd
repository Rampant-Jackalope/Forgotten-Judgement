class_name Player
extends Node

@onready var player_2d: Player2D = $Player2D
@onready var player_3d: Player3D = $Player3D

@onready var inventory: ItemInventory = ItemInventory.new()

enum ActivePlayerType {
	PLAYER_2D,
	PLAYER_3D,
}

var active_player_type: int = ActivePlayerType.PLAYER_3D
var dialogue_locked: bool = false

# TODO: remove/extract this when debugging console/commands are made
# set_2d = KEY_2
# set_3d = KEY_3
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("set_2d"):
		set_active_player_type(ActivePlayerType.PLAYER_2D)
	elif Input.is_action_just_pressed("set_3d"):
		set_active_player_type(ActivePlayerType.PLAYER_3D)

func set_active_player_type(player_type: ActivePlayerType) -> void:
	active_player_type = player_type
	if player_type == ActivePlayerType.PLAYER_2D:
		player_3d.deactivate()
		player_2d.activate()
	else:
		player_2d.deactivate()
		player_3d.activate()

func _ready() -> void:
	player_2d.deactivate()
	add_child(inventory)

func dialogue_lock() -> void:
	dialogue_locked = true

func dialogue_free() -> void:
	dialogue_locked = false

func is_dialogue_locked() -> bool:
	return dialogue_locked

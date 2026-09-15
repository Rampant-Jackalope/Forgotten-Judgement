class_name Player
extends Node

@onready var player_2d := $Player2D
@onready var player_3d := $Player3D

@onready var inventory: ItemInventory = ItemInventory.new()

enum ActivePlayerType {
	PLAYER_2D,
	PLAYER_3D,
}

var active_player_type: int = ActivePlayerType.PLAYER_3D
var dialogue_locked: bool = false

func _ready() -> void:
	player_2d.set_process(false)
	add_child(inventory)

func dialogue_lock() -> void:
	dialogue_locked = true

func dialogue_free() -> void:
	dialogue_locked = false

func is_dialogue_locked() -> bool:
	return dialogue_locked

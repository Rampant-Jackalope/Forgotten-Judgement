extends Node3D

signal left_clicked(hit_position: Vector3, normal: Vector3)
signal right_clicked(hit_position: Vector3, normal: Vector3)

@onready var interactable: Interactable3D = get_node("door-rotate/door/InteractionShape")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

enum DOOR_STATE {
	CLOSED,
	OPEN,
}

var state: int = DOOR_STATE.CLOSED

func _ready() -> void:
	interactable.left_clicked.connect(left_clicked.emit)
	interactable.right_clicked.connect(right_clicked.emit)
	self.close()

func open() -> void:
	animation_player.play("open")

func close() -> void:
	animation_player.play("close")

func open_and_close() -> void:
	animation_player.play("open-and-close")

func toggle() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	
	if state == DOOR_STATE.CLOSED:
		open()
		state = DOOR_STATE.OPEN
	else:
		close()
		state = DOOR_STATE.CLOSED

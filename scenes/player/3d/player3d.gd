class_name Player3D
extends CharacterBody3D

@onready var controller: PlayerController3D = $PlayerController3D
@onready var interactor: Interactor = $Interactor

var dialogue_locked: bool = false

signal unlocked_dialogue()
signal locked_dialogue() 

func _restore_position() -> void:
	global_position = GameState.data[GameState.DataKey.PLAYER_POSITION]

func _ready() -> void:
	InputStash.enable_action("interact")
	GameState.about_to_save.connect(_write_state)
	_restore_position()

func dialogue_lock() -> void:
	WorldManager.set_3d_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	InputStash.disable_action("interact")
	Interactable.highlight_suppressed = true
	dialogue_locked = true
	locked_dialogue.emit()

func dialogue_unlock() -> void:
	WorldManager.set_3d_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	InputStash.enable_action("interact")
	Interactable.highlight_suppressed = false
	dialogue_locked = false
	unlocked_dialogue.emit()

func run_locked(callback: Callable) -> void:
	dialogue_lock()
	if callback.is_valid():
		await callback.call()
	if self: dialogue_unlock()

func run_locked_dialogue(timeline: String, label: String = "") -> void:
	dialogue_lock()
	Dialogic.start(timeline, label)
	await Dialogic.timeline_ended
	if self: dialogue_unlock()

func _write_state() -> void:
	if not is_inside_tree(): return
	GameState.data[GameState.DataKey.PLAYER_POSITION] = global_position

func _exit_tree() -> void:
	_write_state()
	GameState.about_to_save.disconnect(_write_state)

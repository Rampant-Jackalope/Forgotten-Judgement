class_name Player3D
extends CharacterBody3D

@onready var controller: PlayerController3D = $PlayerController3D
@onready var interactor: Interactor = $Interactor

var dialogue_locked: bool = false

func dialogue_lock() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	InputStash.disable_action("interact")
	dialogue_locked = true

func dialogue_unlock() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	InputStash.enable_action("interact")
	dialogue_locked = false

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

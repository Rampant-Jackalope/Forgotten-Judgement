class_name Player3D
extends CharacterBody3D

@onready var controller: PlayerController3D = $PlayerController3D
@onready var interactor: Interactor = $Interactor

var dialogue_locked: bool = false

func dialogue_lock() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dialogue_locked = true

func dialogue_unlock() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	dialogue_locked = false

func run_locked_dialogue(timeline: String, label: String = "") -> void:
	dialogue_lock()
	Dialogic.start(timeline, label)
	await Dialogic.timeline_ended
	if self: dialogue_unlock()
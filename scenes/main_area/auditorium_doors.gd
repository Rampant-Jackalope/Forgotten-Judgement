extends Node3D

@export var invert_open_direction: bool = false
@export var double_callback_door: Node3D
@export var video_stream_player: VideoStreamPlayer

var l_animation_player: AnimationPlayer
var r_animation_player: AnimationPlayer
var l_collision_shape: CollisionShape3D
var r_collision_shape: CollisionShape3D

enum State {
	CLOSED,
	OPEN,
}

var state = State.CLOSED

class DoorAnimation:
	var R: String
	var L: String

	func _init(_r: String, _l: String) -> void:
		R = _r
		L = _l

	
func get_animation() -> DoorAnimation:
	if invert_open_direction:
		return DoorAnimation.new("Open_pos", "Open_neg")

	return DoorAnimation.new("Open_neg", "Open_pos")

func _is_animating() -> bool:
	return r_animation_player.is_playing() or l_animation_player.is_playing()

func _set_collision_disabled(value: bool) -> void:
	r_collision_shape.set_deferred("disabled", value)
	l_collision_shape.set_deferred("disabled", value)

# Only awaits a player that is still playing, so it can't hang
# on a signal that has already fired.
func _wait_for_animations() -> void:
	if r_animation_player.is_playing():
		await r_animation_player.animation_finished
	if l_animation_player.is_playing():
		await l_animation_player.animation_finished

func _ready() -> void:
	assert(double_callback_door != null, "No callback door assigned")
	assert(video_stream_player != null, "No videostreamplayer assigned")

	video_stream_player.finished.connect(_on_cutscene_done)

	assert(double_callback_door.get_node_or_null("L"), "Assigned callback door is likely not a callback door")
	assert(double_callback_door.get_node_or_null("R"), "Assigned callback door is likely not a callback door")

	l_animation_player = double_callback_door.get_node_or_null("L/AnimationPlayer")
	r_animation_player = double_callback_door.get_node_or_null("R/AnimationPlayer")
	assert(l_animation_player != null, "Failed to assign L animation player")
	assert(l_animation_player != null, "Failed to assign R animation player")

	l_collision_shape = double_callback_door.get_node_or_null("L/DoorAniimated/StaticBody3D/CollisionShape3D")
	r_collision_shape = double_callback_door.get_node_or_null("R/DoorAniimated/StaticBody3D/CollisionShape3D")
	assert(l_collision_shape != null, "Failed to assign L collisionshape")
	assert(r_collision_shape != null, "Failed to assign R collisionshape")

func _run_inital_cutscene(interactor: Interactor) -> void:
	interactor.player.dialogue_lock()
	video_stream_player.play()

func _on_cutscene_done() -> void:
	video_stream_player.stop()
	video_stream_player.hide()
	Util.get_player().dialogue_unlock()

func _on_double_callback_door_interacted(_door_l: Node3D, _door_r: Node3D, interactor: Interactor, _pop: Callable) -> void:
	if !Dialogic.VAR.SINGER.ENTERED_AUDITORIUM:
		_run_inital_cutscene(interactor)

	if _is_animating():
		return

	var animation = get_animation()

	if state == State.CLOSED:
		state = State.OPEN
		r_animation_player.play(animation.R)
		l_animation_player.play(animation.L)
	else:
		state = State.CLOSED
		r_animation_player.play_backwards(animation.R)
		l_animation_player.play_backwards(animation.L)

	_set_collision_disabled(true)
	await _wait_for_animations()
	_set_collision_disabled(false)
	Dialogic.VAR.SINGER.ENTERED_AUDITORIUM = true

extends Node
class_name ScreenFader

static var _is_transitioning = false

##For moving npcs around with a marker as destination, alongside a screen transition.
static func transition_npc(npc: Node3D, destination: Vector3) -> void:
	#A guard to prevent multiple transitions at once, which would probably cause issues...
	#note: this does not guard against a second dialogue timeline being started.
	if _is_transitioning:
		return
	
	var player = Util.get_player()

	#The actual process	
	_is_transitioning = true
	player.dialogue_lock()
	await EffectScreen.fade_in(0.4)
	npc.global_position = destination
	await EffectScreen.fade_out(0.5)
	player.dialogue_unlock()
	_is_transitioning = false

static func transition_player(destination: Vector3, look_direction: Vector3) -> void:
	if _is_transitioning:
		return
	
	var player = Util.get_player()

	_is_transitioning = true
	player.dialogue_locked = true # INFO: setting manually bc the dialogue_lock() function changes the mouse mode

	await EffectScreen.fade_in(0.5)

	player.global_position = destination
	if look_direction != Vector3.ZERO:
		player.global_rotation = Vector3(0.0, atan2(-look_direction.x, -look_direction.z), 0.0)
		player.get_node("CamPivot").rotation = Vector3.ZERO  # reset camera pitch

	await EffectScreen.fade_out(0.5)

	player.dialogue_locked = false
	_is_transitioning = false


static func player_death_transition() -> void:
	# TODO: insert better animation
	if _is_transitioning:
		return
	
	_is_transitioning = true

	EffectScreen.force_blackout()
	var player = Util.get_player()

	var death_marker = PlayerPositionMarkers.get_marker("Player_Death")
	var look_direction = death_marker.look_direction

	player.dialogue_locked = true # INFO: setting manually bc the dialogue_lock() function changes the mouse mode
	player.global_position = death_marker.global_position

	if look_direction != Vector3.ZERO:
		player.global_rotation = Vector3(0.0, atan2(-look_direction.x, -look_direction.z), 0.0)
		player.get_node("CamPivot").rotation = Vector3.ZERO  # reset camera pitch

	await Util.static_sleep(1.5)
	await EffectScreen.fade_out(0.8)

	player.dialogue_locked = false
	_is_transitioning = false
	player.run_locked_dialogue("misc-popups", "player_death")

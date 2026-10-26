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

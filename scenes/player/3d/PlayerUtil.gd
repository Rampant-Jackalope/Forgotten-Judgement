extends Node
class_name PlayerUtil

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
	await EffectScreen.fade_to(0.4)
	npc.global_position = destination
	await EffectScreen.fade_out(0.5)
	player.dialogue_unlock()
	_is_transitioning = false

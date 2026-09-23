class_name Util
extends Node

static var is_transitioning = false

static func show_temp_richlabel(
		parent: Node,
		text: String,
		duration: float = 1.5,
		fade_duration: float = 0.5,
		callback: Callable = Callable()
) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = text
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var viewport_size := parent.get_viewport().get_visible_rect().size
	label.size = Vector2(200, 40)
	label.position = Vector2(viewport_size.x / 2.0 - label.size.x / 2.0, viewport_size.y - 50)

	parent.add_child(label)

	var tween := label.create_tween()
	tween.tween_interval(duration)
	tween.tween_property(label, "modulate:a", 0.0, fade_duration)

	if callback.is_valid():
		tween.tween_callback(callback)

	tween.tween_callback(label.queue_free)

	return label

static func get_player() -> Player3D:
	return Engine.get_main_loop().root.get_node("World/Player3D")

##For moving npcs around with a marker as destination, alongside a screen transition.
static func transition_npc(npc: Node3D, destination: Vector3) -> void:
	#A guard to prevent multiple transitions at once, which would probably cause issues...
	#note: this does not guard against a second dialogue timeline being started.
	if is_transitioning:
		return

	#The actual process	
	is_transitioning = true
	#lock
	get_player().dialogue_lock()
	#fade out
	await EffectScreen.fade_out(0.4)
	#move
	npc.global_position = destination
	#fade in
	await EffectScreen.fade_in(0.5)
	#unlock
	get_player().dialogue_unlock()
	is_transitioning = false


##For getting a marker node for an npc to move to, given the marker's id.
static func get_npc_marker(id: String) -> Node3D:
	var markers = Engine.get_main_loop().root.get_node_or_null("World/NpcPositionMarkers")
	return markers.get_marker(id) if markers else null

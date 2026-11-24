@abstract class_name Util
extends Node

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

const PLAYER_PATH := "WorldManager/World3D/Player3D"

static func get_player() -> Player3D:
	var player = get_player_or_null()
	assert(player, "Could not find Player3D in tree")
	return player
static func get_player_or_null() -> Player3D:
	return Engine.get_main_loop().root.get_node_or_null(PLAYER_PATH) as Player3D

static func is_dialogue_active() -> bool:
	var p := get_player_or_null()
	return p != null and p.dialogue_locked

##For getting a marker node for an npc to move to, given the marker's id.
static func get_npc_marker(id: String) -> Node3D:
	var markers = Engine.get_main_loop().root.get_node_or_null("World/NpcPositionMarkers")
	return markers.get_marker(id) if markers else null

static func find_descendant_depthfirst(ancestor: Node, predicate: Callable) -> Node:
	var children: Array[Node] = ancestor.get_children()
	while children.size() > 0:
		var child = children.pop_back()
		children.append_array(child.get_children())

		if predicate.call(child): return child
	return null
static func find_descendant_breadthfirst(ancestor: Node, predicate: Callable) -> Node:
	var children: Array[Node] = ancestor.get_children()
	while children.size() > 0:
		var child = children.pop_front()
		children.append_array(child.get_children())

		if predicate.call(child): return child
	return null
static func find_most_related(node: Node, predicate: Callable, parent_stop: Node = null) -> Node:
	var descendant = find_descendant_breadthfirst(node, predicate)

	if descendant != null: return descendant

	var node_parent = node.get_parent()
	if node_parent == parent_stop: return null
	if predicate.call(node_parent): return node_parent
	return find_most_related(node_parent, predicate)

static func get_descendants_depthfirst(ancestor: Node, predicate: Callable) -> Array[Node]:
	var result: Array[Node] = []

	var children: Array[Node] = ancestor.get_children()
	while children.size() > 0:
		var child = children.pop_back()
		children.append_array(child.get_children())

		if predicate.call(child): result.push_back(child)

	return result
static func get_descendants_breadthfirst(ancestor: Node, predicate: Callable) -> Array[Node]:
	var result: Array[Node] = []

	var children: Array[Node] = ancestor.get_children()
	while children.size() > 0:
		var child = children.pop_front()
		children.append_array(child.get_children())

		if predicate.call(child): result.push_back(child)

	return result

## pick_random_weighted<T>(options: Dictionary[T, float]) -> T
static func pick_random_weighted(options: Dictionary, random: RandomNumberGenerator = null):
	if random == null:
		random = RandomNumberGenerator.new()
		random.randomize()
	var pre_seed = random.seed # To log for debug later

	var total_weight: float = 0
	for weight in options.values():
		total_weight += weight

	var rnd = random.randf() * total_weight

	var accumulator: float = 0
	for value in options.keys():
		var weight = options.get(value)
		accumulator += weight
		if accumulator >= rnd: return value
	
	assert(false, "Didn't pick any option. rnd=" + str(rnd) + ", seed=" + str(pre_seed))

# bc normal sleep method does not work in static functions
static func static_sleep(seconds: float) -> void:
	await (Engine.get_main_loop() as SceneTree).create_timer(seconds).timeout

const WAS_DISABLED = "_was_disabled"
const WAS_PICKABLE = "_was_pickable"
const WAS_VISIBLE = "_was_visible"

static func set_enabled(root: Node, enabled: bool) -> void:
	root.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	_toggle_visibility(root, enabled)
	_toggle_collision(root, enabled)

static func _toggle_visibility(node: Node, enabled: bool) -> void:
	if node is Node3D or node is CanvasItem or node is CanvasLayer:
		if enabled:
			if node.has_meta(WAS_VISIBLE):
				node.visible = node.get_meta(WAS_VISIBLE)
				node.remove_meta(WAS_VISIBLE)
		else:
			if not node.has_meta(WAS_VISIBLE):
				node.set_meta(WAS_VISIBLE, node.visible)
			node.visible = false
		return

	# plain Node (WorldEnvironment, etc.): no visibility of its own, keep looking
	for child in node.get_children():
		_toggle_visibility(child, enabled)

static func _toggle_collision(node: Node, enabled: bool) -> void:
	if node is CollisionShape2D or node is CollisionPolygon2D \
			or node is CollisionShape3D or node is CollisionPolygon3D:
		if enabled:
			if node.has_meta(WAS_DISABLED):
				node.set_deferred("disabled", node.get_meta(WAS_DISABLED))
				node.remove_meta(WAS_DISABLED)
		else:
			if not node.has_meta(WAS_DISABLED):
				node.set_meta(WAS_DISABLED, node.disabled)
			node.set_deferred("disabled", true)

	# stop the pesky rays
	if node is CollisionObject3D or node is CollisionObject2D:
		if enabled:
			if node.has_meta(WAS_PICKABLE):
				node.input_ray_pickable = node.get_meta(WAS_PICKABLE)
				node.remove_meta(WAS_PICKABLE)
		else:
			if not node.has_meta(WAS_PICKABLE):
				node.set_meta(WAS_PICKABLE, node.input_ray_pickable)
			node.input_ray_pickable = false

	for child in node.get_children():
		_toggle_collision(child, enabled)

static func array_as_readonly(arr: Array) -> Array:
	var clone: Array = []
	for v in arr: clone.push_back(v)

	clone.make_read_only()

	return clone
static func dict_as_readonly(dict: Dictionary) -> Dictionary:
	var clone: Dictionary = {}
	for key in dict.keys(): clone[key] = dict[key]
	
	clone.make_read_only()

	return clone

static func get_key_event_text(event: InputEventKey) -> String:
	if event.keycode == 0 and event.physical_keycode == 0: assert(false, "InputEventKey has neither keycode nor physical_keycode set")
	return event.as_text_physical_keycode() if event.keycode == 0 else event.as_text_keycode()
static func get_mousebutton_event_text(event: InputEventMouseButton) -> String:
	match event.button_index:
		MOUSE_BUTTON_NONE:       assert(false, "Got \"none\" mouse button")
		MOUSE_BUTTON_LEFT:       return "Left Mouse"
		MOUSE_BUTTON_RIGHT:      return "Right Mouse"
		MOUSE_BUTTON_MIDDLE:     return "Middle Mouse"
		MOUSE_BUTTON_WHEEL_UP:   return "Scroll Up"
		MOUSE_BUTTON_WHEEL_DOWN: return "Scroll Down"
	return "Mouse" + str(event.button_index)

static func get_event_text(event: InputEvent) -> String:
	assert(event != null, "Got null")

	if event is InputEventKey:         return get_key_event_text(event)
	if event is InputEventMouseButton: return get_mousebutton_event_text(event)

	push_warning("Unknown event type '%s'" % event.get_class())
	return event.as_text()

static func get_action_key_text(action: StringName) -> String:
	var items: Array[String] = []
	for event in InputMap.action_get_events(action):
		items.push_back(get_event_text(event))
	if items.size() <= 0: return "Unset"
	return ", ".join(items)

static func get_npc_name(npc: DialogicFlags.NPC) -> String:
	match npc:
		DialogicFlags.NPC.BARTENDER:
			return "Bartender"
		DialogicFlags.NPC.OVERWORKER:
			return "Richard"
		DialogicFlags.NPC.SINGER:
			return "Velvet"
		DialogicFlags.NPC.HOBO:
			return "Hobo"
		DialogicFlags.NPC.COUPLE_GUY:
			return "Edward"
		DialogicFlags.NPC.COUPLE_GIRL:
			return "Beatrice"
		DialogicFlags.NPC.ENKI:
			return "Enki"
		DialogicFlags.NPC.CHILD:
			return "Child"
		DialogicFlags.NPC.RAT:
			return "Rat"
	assert(false, "invalid npc provided")
	return ""

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

static func get_player() -> Player3D:
	return Engine.get_main_loop().root.get_node("WorldManager/World3D/Player3D")

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

static func set_enabled(root: Node, enabled: bool) -> void:
	root.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	_toggle_visibility(root, enabled)
	_toggle_collision(root, enabled)

static func _toggle_visibility(node: Node, enabled: bool) -> void:
	if node is Node3D or node is CanvasItem or node is CanvasLayer:
		if enabled:
			if node.has_meta("_was_visible"):
				node.visible = node.get_meta("_was_visible")
				node.remove_meta("_was_visible")
		else:
			if not node.has_meta("_was_visible"):
				node.set_meta("_was_visible", node.visible)
			node.visible = false
		return

	# plain Node (WorldEnvironment, etc.): no visibility of its own, keep looking
	for child in node.get_children():
		_toggle_visibility(child, enabled)

static func _toggle_collision(node: Node, enabled: bool) -> void:
	if node is CollisionShape2D or node is CollisionPolygon2D \
			or node is CollisionShape3D or node is CollisionPolygon3D:
		if enabled:
			if node.has_meta("_was_disabled"):
				node.set_deferred("disabled", node.get_meta("_was_disabled"))
				node.remove_meta("_was_disabled")
		else:
			if not node.has_meta("_was_disabled"):
				node.set_meta("_was_disabled", node.disabled)
			node.set_deferred("disabled", true)

	# stop the pesky rays
	if node is CollisionObject3D or node is CollisionObject2D:
		if enabled:
			if node.has_meta("_was_pickable"):
				node.input_ray_pickable = node.get_meta("_was_pickable")
				node.remove_meta("_was_pickable")
		else:
			if not node.has_meta("_was_pickable"):
				node.set_meta("_was_pickable", node.input_ray_pickable)
			node.input_ray_pickable = false

	for child in node.get_children():
		_toggle_collision(child, enabled)

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
	return Engine.get_main_loop().root.get_node("World/Player3D")

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

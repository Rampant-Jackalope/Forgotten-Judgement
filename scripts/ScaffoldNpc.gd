@tool
extends Node3D
class_name ScaffoldedNpc

@export var npc_name: DialogicFlags.Npc

## Each entry is [path_relative_to_this_node, type].
## Type can be a native class name string or a script class (e.g. ScaledSprite3D).
## Parents must come before their children.
func _get_scaffold() -> Array:
	return [
		["Target", Node3D],
		["Interactable", Interactable],
		["Interactable/CollisionShape3D", CollisionShape3D],
		["ScaledSprite3D", ScaledSprite3D],
		["StaticBody3D", StaticBody3D],
		["StaticBody3D/CollisionShape3D", CollisionShape3D]
	]

## Defaults for freshly created nodes only (inspector edits persist).
func _init_defaults(child: Node, path: String) -> void:
	match path:
		"Interactable/CollisionShape3D":
			var sphere := SphereShape3D.new()
			sphere.radius = 1.0
			(child as CollisionShape3D).shape = sphere
		"StaticBody3D/CollisionShape3D":
			var pill := CapsuleShape3D.new()
			pill.radius = 0.2
			(child as CollisionShape3D).shape = pill 


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		if Engine.is_editor_hint():
			# Build scaffolding in the editor only, at runtime the children come from the saved scene.
			_build.call_deferred()
		else:
			_connect_highlighting()

		assert(npc_name != null, "No valid DialogicFlags.Npc enum value assigned")
		NpcPositionMarkers.register_npc(npc_name, self)

func _connect_highlighting() -> void:
	var interactable := get_node_or_null("Interactable") as Interactable
	var scaled_sprite := get_node_or_null("ScaledSprite3D") as ScaledSprite3D
	assert(interactable != null, "NPC is missing its Interactable child")
	assert(scaled_sprite != null, "NPC is missing its ScaledSprite3D child")

	if not interactable.highlight_on.is_connected(scaled_sprite.enable_highlight):
		interactable.highlight_on.connect(scaled_sprite.enable_highlight)
	if not interactable.highlight_off.is_connected(scaled_sprite.disable_highlight):
		interactable.highlight_off.connect(scaled_sprite.disable_highlight)

func _build() -> void:
	if not is_inside_tree(): return
	var root := get_tree().edited_scene_root
	if root == null: return

	for entry in _get_scaffold():
		var path: String = entry[0]
		if get_node_or_null(path): continue

		var parent: Node = self
		var child_name := path
		if "/" in path:
			parent = get_node_or_null(path.get_base_dir())
			child_name = path.get_file()
			if parent == null:
				push_warning("Scaffold: parent for '%s' not found" % path)
				continue

		var type: Variant = entry[1]
		var child: Node = ClassDB.instantiate(type) if type is String else type.new()
		child.name = child_name
		parent.add_child(child)
		child.owner = root  # makes it visible in the tree and saved to the .tscn
		_init_defaults(child, path)

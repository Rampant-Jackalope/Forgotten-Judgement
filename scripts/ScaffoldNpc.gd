@tool
extends Node3D
class_name ScaffoldedNpc

## Each entry is [path_relative_to_this_node, type].
## Type can be a native class name string or a script class (e.g. ScaledSprite3D).
## Parents must come before their children.
func _get_scaffold() -> Array:
	return [
		["Target", Node3D],
		["Interactable", Interactable],
		["Interactable/CollisionShape3D", CollisionShape3D],
		["ScaledSprite3D", ScaledSprite3D]
	]

func _init_defaults(child: Node, path: String) -> void:
	match path:
		"Interactable/CollisionShape3D":
			var sphere:= SphereShape3D.new()
			sphere.radius = 1 

			(child as CollisionShape3D).shape = sphere

func _ready() -> void:
	# Only build in the editor. At runtime the children come from the saved scene.
	if Engine.is_editor_hint():
		_build.call_deferred()

func _build() -> void:
	if not is_inside_tree():
		return
	var root := get_tree().edited_scene_root
	if root == null:
		return

	for entry in _get_scaffold():
		var path: String = entry[0]
		if get_node_or_null(path):
			continue

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

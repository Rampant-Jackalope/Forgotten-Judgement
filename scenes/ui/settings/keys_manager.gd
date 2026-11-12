extends Container

@export var template: Control
@export var container: Container

func _enter_tree() -> void:
	assert(template)
	assert(container)

	if template.get_parent(): template.get_parent().remove_child(template)

	update_items()

func update_items() -> void:
	for child in container.get_children():
		container.remove_child(child)
	
	for action in InputMap.get_actions():
		var instance = template.duplicate()

		instance.name = action

		var action_edit = Util.find_descendant_breadthfirst(instance, func(v): return v is ActionEventEdit) as ActionEventEdit
		if action_edit:
			action_edit.action = action

		var label = Util.find_descendant_breadthfirst(instance, func(v): return v is Label) as Label
		if label:
			label.text = action

		container.add_child(instance)

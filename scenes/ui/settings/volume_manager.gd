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
	
	var bus_volumes = Settings.bus_volumes
	for bus_name in bus_volumes.keys():
		var instance = template.duplicate()

		instance.name = bus_name

		instance.bus_name = bus_name

		container.add_child(instance)

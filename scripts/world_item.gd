extends Node3D

@export var item_data: ItemData
@export var dialogue_timeline: String = ""

func _on_interactable_3d_left_clicked(_hit_position: Vector3, _normal: Vector3) -> void:
	# Check if an ItemData resource (like drip_jacket.tres) is assigned in the Inspector
	if item_data == null:
		print("Error: No ItemData assigned to ", name)
		return

	# Try to find the Hotbar node dynamically
	var hotbar = get_node_or_null("/root/World/HUD/Hotbar")
	
	# Fallback search if the path above differs slightly in your scene
	if hotbar == null:
		hotbar = get_tree().get_first_node_in_group("hotbar")
		
	if hotbar == null:
		print("Error: Could not find Hotbar node in the scene tree!")
		return

	# Attempt to add the item_data (with name, icon, description) to the hotbar
	var success = hotbar.add_item_to_first_empty_slot(item_data)
	
	if not success:
		print("Hotbar is full! Cannot pick up ", item_data.name)
		return

	# Optional: Trigger dialogue popup if a timeline string was provided
	if dialogue_timeline != "":
		Util.run_locked_dialogue("misc-popups", dialogue_timeline)

	# Remove the item from the 3D world after successfully adding to hotbar
	queue_free()

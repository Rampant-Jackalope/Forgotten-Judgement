extends HBoxContainer

# Array to store associated item scenes for future use
var item_scenes: Array[PackedScene] = [null, null, null]

func add_item_to_first_empty_slot(icon_texture: Texture2D, scene: PackedScene = null) -> bool:
	var slots = get_children() # Retrieves Slot1, Slot2, Slot3
	
	for i in range(slots.size()):
		var slot_panel = slots[i]
		
		# Locate TextureRect node inside the PanelContainer
		var texture_rect = slot_panel.get_node_or_null("Icon") as TextureRect
		if texture_rect == null:
			for child in slot_panel.get_children():
				if child is TextureRect:
					texture_rect = child
					break
		
		# Assign the item to the first empty slot found
		if texture_rect and texture_rect.texture == null:
			if icon_texture == null:
				print("Error: Passed texture is null!")
				return false
				
			# Apply sizing settings via script to fit the PanelContainer
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.custom_minimum_size = slot_panel.size
			
			# Render the icon and show the node
			texture_rect.texture = icon_texture
			texture_rect.show()
			
			item_scenes[i] = scene
			print("Item successfully assigned to slot ", i + 1)
			return true
			
	print("Hotbar is full!")
	return false

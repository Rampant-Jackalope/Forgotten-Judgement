extends HBoxContainer

var items: Array[ItemData] = [null, null, null]
var selected_slot_index: int = 0

signal slot_hovered(item: ItemData)
signal slot_unhovered()
signal slot_changed(index: int, item: ItemData)

# Verwijzing naar het label in het midden van de HUD
@onready var item_popup_label: Label = get_node_or_null("../ItemPopupLabel")
var popup_tween: Tween

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	update_slot_highlights()
	_setup_hover_signals()

func _setup_hover_signals() -> void:
	var slots = get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		if slot is Control:
			var slot_index = i
			slot.mouse_entered.connect(func(): slot_hovered.emit(items[slot_index]))
			slot.mouse_exited.connect(func(): slot_unhovered.emit())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_1: select_slot(0)
		elif event.keycode == KEY_2: select_slot(1)
		elif event.keycode == KEY_3: select_slot(2)

func remove_item(item_name_to_remove: String) -> bool:
	for i in range(items.size()):
		var item = items[i]
		if item != null:
			# Check op zowel 'item_name' als de engine property 'name'
			var current_name = item.get("item_name") if "item_name" in item else item.name
			
			if current_name.to_lower() == item_name_to_remove.to_lower() or item.resource_path.get_file().get_basename() == item_name_to_remove:
				items[i] = null
				
				# Maak het icoon in de UI leeg en verberg deze
				var slots = get_children()
				if i < slots.size():
					var slot_panel = slots[i]
					var texture_rect = slot_panel.get_node_or_null("TextureRect") as TextureRect
					if texture_rect == null:
						for child in slot_panel.get_children():
							if child is TextureRect:
								texture_rect = child
								break
					
					if texture_rect:
						texture_rect.texture = null
						texture_rect.hide()
				
				# Stuur een signaal als het actieve slot is gewijzigd
				if i == selected_slot_index:
					slot_changed.emit(selected_slot_index, null)
					
				print("Item '", item_name_to_remove, "' succesvol verwijderd uit slot ", i + 1)
				return true

	print("Item '", item_name_to_remove, "' niet gevonden in hotbar!")
	return false
	
func select_slot(index: int) -> void:
	if index >= 0 and index < get_children().size():
		selected_slot_index = index
		update_slot_highlights()
		
		var current_item = items[selected_slot_index]
		slot_changed.emit(selected_slot_index, current_item)
		
		# Toon de beschrijving midden op het scherm
		_show_popup_text(current_item)

func _show_popup_text(item: ItemData) -> void:
	if item_popup_label == null:
		# Fallback als de node anders heet
		item_popup_label = get_parent().get_node_or_null("ItemPopupLabel") as Label

	if item_popup_label == null:
		return

	# Stop vorige animatie als je snel tussen slots wisselt
	if popup_tween and popup_tween.is_running():
		popup_tween.kill()

	# Bepaal tekst (naam + beschrijving)
	if item != null:
		var display_name: String = ""
		if "item_name" in item and str(item.get("item_name")) != "":
			display_name = str(item.get("item_name"))
		elif "name" in item and str(item.get("name")) != "":
			display_name = str(item.get("name"))
		else:
			display_name = "Item"

		var display_desc: String = ""
		if "description" in item:
			display_desc = str(item.get("description"))

		if display_desc != "":
			item_popup_label.text = display_name + "\n" + display_desc
		else:
			item_popup_label.text = display_name
	else:
		item_popup_label.text = "(Empty Slot)"

	# Maak het label zichtbaar en pop/fade in-and-out
	item_popup_label.show()
	popup_tween = create_tween()
	popup_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	item_popup_label.modulate.a = 0.0
	popup_tween.tween_property(item_popup_label, "modulate:a", 1.0, 0.15) # Pop-in
	popup_tween.tween_interval(2.0)                                       # Blijf 2 sec staan
	popup_tween.tween_property(item_popup_label, "modulate:a", 0.0, 0.35) # Fade-out
	popup_tween.tween_callback(item_popup_label.hide)

func update_slot_highlights() -> void:
	var slots = get_children()
	for i in range(slots.size()):
		if i == selected_slot_index:
			slots[i].modulate = Color(1.3, 1.3, 1.3, 1.0)
		else:
			slots[i].modulate = Color(0.6, 0.6, 0.6, 0.8)

func add_item_to_first_empty_slot(item_data: ItemData) -> bool:
	if item_data == null:
		print("Error: No ItemData provided to add_item_to_first_empty_slot!")
		return false
	
	if not item_data is ItemData:
		print("Error: Object is not an ItemData resource, received: ", item_data)
		return false
		
	var slots = get_children()
	
	for i in range(slots.size()):
		if items[i] == null:
			items[i] = item_data
			
			var slot_panel = slots[i]
			var texture_rect = slot_panel.get_node_or_null("TextureRect") as TextureRect
			if texture_rect == null:
				for child in slot_panel.get_children():
					if child is TextureRect:
						texture_rect = child
						break
			
			if texture_rect:
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				texture_rect.texture = item_data.icon
				texture_rect.show()
			
			var print_name = item_data.get("item_name") if "item_name" in item_data else item_data.name
			print("Item '", print_name, "' successfully added to slot ", i + 1)
			
			# Pop-up direct tonen als het item in je momenteel actieve slot komt
			if i == selected_slot_index:
				_show_popup_text(item_data)
				
			return true
			
	print("Hotbar is full!")
	return false

extends HBoxContainer

var items: Array[ItemData] = [null, null, null]
var selected_slot_index: int = 0

signal slot_hovered(item: ItemData)
signal slot_unhovered()
signal slot_changed(index: int, item: ItemData)

# Verwijzing naar het label in het midden van de HUD
@onready var item_popup_label: Label = get_node_or_null("../ItemPopupLabel")

# Nodes opzoeken via de parent HUD (omdat MainSlot nu losstaat)
var selected_slot: Control
var selected_slot_icon: TextureRect

var popup_tween: Tween

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	update_slot_highlights()
	_setup_hover_signals()
	_find_main_slot_nodes()
	_make_selected_slot_circular()
	_update_selected_display()

func _find_main_slot_nodes() -> void:
	var parent_hud = get_parent()
	if parent_hud:
		# Zoek MainSlot -> SelectedSlot -> SelectedSlotIcon vanaf de parent
		selected_slot = parent_hud.get_node_or_null("MainSlot/SelectedSlot") as Control
		selected_slot_icon = parent_hud.get_node_or_null("MainSlot/SelectedSlot/SelectedSlotIcon") as TextureRect
		
		# Fallback voor het geval MainSlot direct in TextureRect of elders geplaatst is
		if selected_slot == null:
			selected_slot = parent_hud.find_child("SelectedSlot", true, false) as Control
		if selected_slot_icon == null:
			selected_slot_icon = parent_hud.find_child("SelectedSlotIcon", true, false) as TextureRect

func _make_selected_slot_circular() -> void:
	if selected_slot == null:
		_find_main_slot_nodes()

	if selected_slot:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.1, 0.1, 0.1, 0.6) # Donkergrijze transparante achtergrond
		style_box.border_color = Color(0.9, 0.7, 0.2, 1.0) # Gouden rand
		style_box.set_border_width_all(3)
		style_box.set_corner_radius_all(100) # Maakt het een cirkel
		
		selected_slot.add_theme_stylebox_override("panel", style_box)

func _setup_hover_signals() -> void:
	var slots = [get_node_or_null("Slot 1"), get_node_or_null("Slot 2"), get_node_or_null("Slot 3")]
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
			var current_name = item.get("item_name") if "item_name" in item else item.name
			
			if current_name.to_lower() == item_name_to_remove.to_lower() or item.resource_path.get_file().get_basename() == item_name_to_remove:
				items[i] = null
				
				var slots = [get_node_or_null("Slot 1"), get_node_or_null("Slot 2"), get_node_or_null("Slot 3")]
				if i < slots.size() and slots[i] != null:
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
				
				if i == selected_slot_index:
					slot_changed.emit(selected_slot_index, null)
					_update_selected_display()
					
				print("Item '", item_name_to_remove, "' succesvol verwijderd uit slot ", i + 1)
				return true

	print("Item '", item_name_to_remove, "' niet gevonden in hotbar!")
	return false
	
func select_slot(index: int) -> void:
	var slots = [get_node_or_null("Slot 1"), get_node_or_null("Slot 2"), get_node_or_null("Slot 3")]
	if index >= 0 and index < slots.size():
		selected_slot_index = index
		update_slot_highlights()
		
		var current_item = items[selected_slot_index]
		slot_changed.emit(selected_slot_index, current_item)
		
		_show_popup_text(current_item)
		_update_selected_display()

func _update_selected_display() -> void:
	if selected_slot_icon == null:
		_find_main_slot_nodes()

	if selected_slot_icon:
		var current_item = items[selected_slot_index]
		if current_item != null and current_item.icon != null:
			selected_slot_icon.texture = current_item.icon
			selected_slot_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			selected_slot_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			selected_slot_icon.show()
		else:
			selected_slot_icon.texture = null
			selected_slot_icon.hide()

func _show_popup_text(item: ItemData) -> void:
	if item_popup_label == null:
		item_popup_label = get_parent().get_node_or_null("ItemPopupLabel") as Label

	if item_popup_label == null:
		return

	if popup_tween and popup_tween.is_running():
		popup_tween.kill()

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

	item_popup_label.show()
	popup_tween = create_tween()
	popup_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	item_popup_label.modulate.a = 0.0
	popup_tween.tween_property(item_popup_label, "modulate:a", 1.0, 0.15)
	popup_tween.tween_interval(2.0)
	popup_tween.tween_property(item_popup_label, "modulate:a", 0.0, 0.35)
	popup_tween.tween_callback(item_popup_label.hide)

func update_slot_highlights() -> void:
	var slots = [get_node_or_null("Slot 1"), get_node_or_null("Slot 2"), get_node_or_null("Slot 3")]
	for i in range(slots.size()):
		if slots[i] != null:
			if i == selected_slot_index:
				slots[i].modulate = Color(1.3, 1.3, 1.3, 1.0)
			else:
				slots[i].modulate = Color(0.6, 0.6, 0.6, 0.8)

func add_item_to_first_empty_slot(item_data: ItemData) -> bool:
	if item_data == null or not item_data is ItemData:
		return false
		
	var slots = [get_node_or_null("Slot 1"), get_node_or_null("Slot 2"), get_node_or_null("Slot 3")]
	
	for i in range(slots.size()):
		if items[i] == null:
			items[i] = item_data
			
			var slot_panel = slots[i]
			if slot_panel != null:
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
			
			if i == selected_slot_index:
				_show_popup_text(item_data)
				_update_selected_display()
				
			return true
			
	return false

extends MarginContainer
#res://scenes/main_menu/user_interface.tscn
@export var main_menu_scene: PackedScene


@export var main_buttons: VBoxContainer# = $MainButtons
@export var back_to_menu_button: Button# = $MainButtons/BackToMenuButton
@export var quit_button: Button# = $MainButtons/QuitButton

@export var hotbar = get_node_or_null("../Hotbar")

var items_display_label: Label
var hud_popup_label: Label
var popup_tween: Tween

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	hide()

	# Dynamically create the display label for the pause menu
	_setup_items_label()
	
	# Dynamically create the HUD popup label for active slot switching
	_setup_hud_popup_label()


	assert(main_buttons != null, "MainButtons node not found in PauseMenu.")
	assert(back_to_menu_button != null, "BackToMenuButton node not found in PauseMenu.")
	assert(quit_button != null, "QuitButton node not found in PauseMenu.")
	assert(hotbar != null, "Hotbar node not found in PauseMenu parent.")


	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Connect Hotbar signals
	if hotbar.has_signal("slot_hovered"):
		hotbar.slot_hovered.connect(_on_slot_hovered)
	if hotbar.has_signal("slot_unhovered"):
		hotbar.slot_unhovered.connect(_on_slot_unhovered)
	if hotbar.has_signal("slot_changed"):
		hotbar.slot_changed.connect(_on_slot_changed)
	
	# Ensure the pause menu is above other UI elements
	move_to_front.call_deferred() 

func _setup_items_label() -> void:
	items_display_label = main_buttons.get_node_or_null("ItemsDisplayLabel") as Label
	if items_display_label == null:
		items_display_label = Label.new()
		items_display_label.name = "ItemsDisplayLabel"
		items_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		items_display_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		# Add the label to the container and move it above buttons
		main_buttons.add_child(items_display_label)
		main_buttons.move_child(items_display_label, 0)

func _setup_hud_popup_label() -> void:
	# Create a dedicated popup label on the parent HUD container
	var parent_hud = get_parent()
	if parent_hud:
		hud_popup_label = parent_hud.get_node_or_null("HUDPopupLabel") as Label
		if hud_popup_label == null:
			hud_popup_label = Label.new()
			hud_popup_label.name = "HUDPopupLabel"
			hud_popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hud_popup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			hud_popup_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hud_popup_label.process_mode = PROCESS_MODE_ALWAYS
			
			# Position the popup label neatly in the lower section of the screen above the hotbar
			hud_popup_label.anchor_left = 0.2
			hud_popup_label.anchor_right = 0.8
			hud_popup_label.anchor_top = 0.75
			hud_popup_label.anchor_bottom = 0.85
			
			hud_popup_label.modulate.a = 0.0 # Start fully transparent
			parent_hud.add_child(hud_popup_label)

func _input(event: InputEvent) -> void:
	# Toggle pause menu with ESC (ui_cancel)
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause_menu()

func toggle_pause_menu() -> void:
	var is_paused = not visible
	visible = is_paused
	get_tree().paused = is_paused

	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_clear_pause_display_text()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_slot_hovered(item: ItemData) -> void:
	# Update pause menu label when hovering over slots in pause menu
	if visible and items_display_label:
		items_display_label.text = _format_item_text(item)

func _on_slot_unhovered() -> void:
	if visible:
		_clear_pause_display_text()

func _on_slot_changed(_index: int, item: ItemData) -> void:
	# Always trigger pop-up description when switching active slots (1, 2, 3)
	show_hud_popup(item)

func show_hud_popup(item: ItemData) -> void:
	if hud_popup_label == null:
		_setup_hud_popup_label()

	if hud_popup_label == null:
		return

	# Stop previous animation if active
	if popup_tween and popup_tween.is_running():
		popup_tween.kill()

	hud_popup_label.text = _format_item_text(item)

	# Smoothly fade in, hold, and fade out
	popup_tween = create_tween()
	popup_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	popup_tween.tween_property(hud_popup_label, "modulate:a", 1.0, 0.2) # Fade in
	popup_tween.tween_interval(2.0)                                    # Hold for 2s
	popup_tween.tween_property(hud_popup_label, "modulate:a", 0.0, 0.4) # Fade out

func _format_item_text(item: ItemData) -> String:
	if item == null:
		return "(Empty Slot)"

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
		return display_name + "\n" + display_desc
	return display_name

func _clear_pause_display_text() -> void:
	if items_display_label:
		items_display_label.text = ""

func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene.get_path())

func _on_quit_pressed() -> void:
	get_tree().quit()

extends HBoxContainer

var selected_slot_index: int = 0
# TODO: make it an @onready or @export global variable
# hinge: currently the Inventory as autoload defines a SLOT_COUNT, these nodes should ideally be instantiated at runtime accordingly
var slots

signal slot_hovered(item: ItemData)
signal slot_unhovered()
signal slot_changed(index: int, item: ItemData)

# Reference to the label in the middle of the HUD
@onready var item_popup_label: Label = get_node_or_null("../ItemPopupLabel")

# Search for nodes via the parent HUD (since MainSlot is now seperate)
var selected_slot: Control
var selected_slot_icon: TextureRect

var popup_tween: Tween

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_setup_popup_label()
	update_slot_highlights()
	_setup_hover_signals()
	_find_main_slot_nodes()
	_make_selected_slot_circular()
	_update_selected_display()

	#_home_offset is saved each time the hotbar is expanded, so it can return to its original position where the anchor puts it
	_home_offset = Vector2(offset_left, offset_top)  # from the scene, before any tween

	Inventory.slot_changed.connect(_on_slot_changed)
	Inventory.selected_changed.connect(_on_selected_changed)
	for i in Inventory.slot_count:
		_redraw_slot(i, Inventory.slots[i])
	

func _find_main_slot_nodes() -> void:
	var parent_hud = get_parent()
	if parent_hud:
		# Search MainSlot -> SelectedSlot -> SelectedSlotIcon from the parent
		selected_slot = parent_hud.get_node_or_null("MainSlot/SelectedSlot") as Control
		selected_slot_icon = parent_hud.get_node_or_null("MainSlot/SelectedSlot/SelectedSlotIcon") as TextureRect
		
		# Fallback for the case where MainSlot is directly placed in TextureRect or elsewhere
		if selected_slot == null:
			selected_slot = parent_hud.find_child("SelectedSlot", true, false) as Control
		if selected_slot_icon == null:
			selected_slot_icon = parent_hud.find_child("SelectedSlotIcon", true, false) as TextureRect

func _make_selected_slot_circular() -> void:
	if selected_slot == null:
		_find_main_slot_nodes()

	if selected_slot:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.1, 0.1, 0.1, 0.6) # Dark gray transparent background
		style_box.border_color = Color(0.9, 0.7, 0.2, 1.0) # Golden border
		style_box.set_border_width_all(3)
		style_box.set_corner_radius_all(100) # Creates a circle effect
		
		selected_slot.add_theme_stylebox_override("panel", style_box)

func _setup_hover_signals() -> void:
	for i in range(slots.size()):
		var slot = slots[i]
		if slot is Control:
			var slot_index = i
			slot.mouse_entered.connect(func():
				slot_hovered.emit(Inventory.slots[slot_index])
				_show_popup_text(Inventory.slots[slot_index], true))
			slot.mouse_exited.connect(func():
				slot_unhovered.emit()
				_hide_popup())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and not _dialogue_active():
		if event.keycode == KEY_1: Inventory.select(0)
		elif event.keycode == KEY_2: Inventory.select(1)
		elif event.keycode == KEY_3: Inventory.select(2)
		elif event.keycode == KEY_TAB and not get_tree().paused: toggle_expand()

func _update_selected_display() -> void:
	if selected_slot_icon == null:
		_find_main_slot_nodes()

	if selected_slot_icon:
		var current_item = Inventory.slots[selected_slot_index]
		if current_item != null and current_item.icon != null:
			selected_slot_icon.texture = current_item.icon
			selected_slot_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			selected_slot_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			selected_slot_icon.show()
		else:
			selected_slot_icon.texture = null
			selected_slot_icon.hide()

func _setup_popup_label() -> void:
	if item_popup_label != null:
		return # already exists in the scene
	item_popup_label = Label.new()
	item_popup_label.name = "ItemPopupLabel"
	item_popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_popup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item_popup_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_popup_label.process_mode = PROCESS_MODE_ALWAYS
	# lower part of the screen, above the hotbar
	item_popup_label.anchor_left = 0.2
	item_popup_label.anchor_right = 0.8
	item_popup_label.anchor_top = 0.75
	item_popup_label.anchor_bottom = 0.85
	item_popup_label.modulate.a = 0.0
	# deferred: the parent HUD is still busy adding its children during our _ready
	get_parent().add_child.call_deferred(item_popup_label)

## hold = true keeps the text up (used while hovering), false fades out after 2s.
func _show_popup_text(item: ItemData, hold: bool = false) -> void:
	if item_popup_label == null:
		return
	_kill_popup_tween()
	item_popup_label.text = item.get_display_text() if item != null else "Empty Slot"

	popup_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	popup_tween.tween_property(item_popup_label, "modulate:a", 1.0, 0.15)
	if not hold:
		popup_tween.tween_interval(2.0)
		popup_tween.tween_property(item_popup_label, "modulate:a", 0.0, 0.35)

func _hide_popup() -> void:
	if item_popup_label == null:
		return
	_kill_popup_tween()
	popup_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	popup_tween.tween_property(item_popup_label, "modulate:a", 0.0, 0.35)

func _kill_popup_tween() -> void:
	if popup_tween and popup_tween.is_running():
		popup_tween.kill()

func update_slot_highlights() -> void:
	slots = [get_node_or_null("Slot 1"), get_node_or_null("Slot 2"), get_node_or_null("Slot 3")]
	for i in range(slots.size()):
		if slots[i] != null:
			if i == selected_slot_index:
				slots[i].modulate = Color(1.3, 1.3, 1.3, 1.0)
			else:
				slots[i].modulate = Color(0.6, 0.6, 0.6, 0.8)



#should logic be seperated like this? ---

#another note: you can test this logic by running the HUD scene and pressing TAB.

#Hboxcontainer/hotbar expansion logic

@export var expanded_scale: float = 2.0
@export var expand_time: float = 0.35
@export var max_blur: float = 3.5

#The blur_rect affect every node above it in the order of the scene tree.
@onready var blur_rect: ColorRect = get_node_or_null("../BlurRect")

#Tween logic works because hotbar's parent is a CanvasLayer and not a container, which would snap it back

var is_expanded := false
var _home_offset: Vector2
var _expand_tween: Tween

func toggle_expand() -> void:
	set_expanded(not is_expanded)

func set_expanded(value: bool) -> void:
	if value == is_expanded:
		return
	is_expanded = value

	if _expand_tween and _expand_tween.is_running():
		_expand_tween.kill()

	pivot_offset = size / 2.0   # scale from the centre, without this it would scale from the top-left

	if is_expanded:
		blur_rect.show()

	var screen_center := get_viewport_rect().size / 2.0
	var target_pos := (screen_center - size / 2.0) if is_expanded else _get_home_pos()
	var target_scale := Vector2.ONE * (expanded_scale if is_expanded else 1.0)
	var target_blur := max_blur if is_expanded else 0.0
	var target_dim := 0.35 if is_expanded else 0.0

	#tween happens even if scene tree is paused
	_expand_tween = create_tween().set_parallel(true)
	_expand_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_expand_tween.set_trans(Tween.TRANS_CUBIC)
	_expand_tween.set_ease(Tween.EASE_OUT if is_expanded else Tween.EASE_IN_OUT)

	_expand_tween.tween_property(self, "position", target_pos, expand_time)
	_expand_tween.tween_property(self, "scale", target_scale, expand_time)
	_expand_tween.tween_property(blur_rect, "material:shader_parameter/blur_amount", target_blur, expand_time)
	_expand_tween.tween_property(blur_rect, "material:shader_parameter/dim", target_dim, expand_time)

	if not is_expanded:
		_expand_tween.chain().tween_callback(blur_rect.hide)

func _get_home_pos() -> Vector2:
	var vp := get_viewport_rect().size
	return Vector2(vp.x * anchor_left, vp.y * anchor_top) + _home_offset



#For now, I just put the new functions at the bottom, lmk if there should be some other organization.

func _on_slot_changed(i: int, item: ItemData) -> void:
	_redraw_slot(i, item)

func _redraw_slot(i: int, item: ItemData) -> void:
	# Keep the existing TextureRect; only set its texture.
	# TODO: Rename to better ¯\_(ツ)_/¯
	var tex := slots[i].get_node_or_null("TextureRect") as TextureRect
	if tex:
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.texture = item.icon if item else null
		tex.visible = item != null

func _on_selected_changed(i: int, item: ItemData) -> void:
	selected_slot_index = i
	update_slot_highlights()
	slot_changed.emit(i, item)
	_show_popup_text(item)
	_update_selected_display()

#Note: I added this function to two places (hotbar.gd and menu-buttons.gd), maybe it fits util better, idk.
func _dialogue_active() -> bool:
	var p := get_tree().root.get_node_or_null("World/Player3D") as Player3D
	return p != null and p.dialogue_locked

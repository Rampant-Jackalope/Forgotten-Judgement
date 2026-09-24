@tool
@abstract class_name ProjectileBase
extends AnimatedSprite2D

@export var damage: int = 1

@export var body: Node2D

## Reusable, inspector-assignable modifiers (punch, spin, flash, etc).
## Order matters if modifiers touch the same property.
@export var modifiers: Array = []

@export_group("Cleanup")
@export var time_out := 0.5
@export var enable_timeout := false
var timer: Timer

@export_group("Screen Culling")
@export var visibility_rect: Rect2 = Rect2(-32, -32, 64, 64):
	set(value):
		visibility_rect = value
		queue_redraw()

signal hit(damage: int)

func _process(_delta: float) -> void:
	# compound types like Rect2 don't update consistently apparently??
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	# Editor-only gizmo so the size of the visibility rect can be sized visually
	if Engine.is_editor_hint():
		draw_rect(visibility_rect, Color(0, 1, 0, 0.6), false, 2.0)

## optionally directly assign hitbox to avoid possible search failing or just sanity check
@export var hitbox: Area2D

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if _find_hitbox() == null:
		warnings.append("No Area2D child found. Every projectile needs one as its hitbox.")
	return warnings

func _find_hitbox() -> Area2D:
	for child in get_children():
		if child is Area2D:
			return child
	return null

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	if body == null:
		body = self

	hitbox = _find_hitbox()
	if hitbox == null:
		push_error("%s has no Area2D child every projectile needs a hitbox." % name)
	else:
		hitbox.monitoring = false
		hitbox.monitorable = false
		hitbox.body_entered.connect(func(_body: Node2D): self.hit.emit(damage))

	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time_out
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	var on_screen_detector := VisibleOnScreenNotifier2D.new()
	on_screen_detector.rect = visibility_rect
	on_screen_detector.screen_exited.connect(func(): queue_free())
	add_child(on_screen_detector)	

	# Pick up any child Nodes that implement the modifier interface too
	# (the "one-off script, no Resource needed" path).
	for child in get_children():
		if child.has_method("process_modifier") and child not in modifiers:
			modifiers.append(child)

	for m in modifiers:
		m.start(self)

	if enable_timeout:
		timer.start()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	apply_motion(delta)
	for m in modifiers:
		m.process_modifier(delta, self)

func activate_hitbox() -> void:
	if hitbox:
		hitbox.monitoring = true
		hitbox.monitorable = true

func deactivate_hitbox() -> void:
	if hitbox:
		hitbox.monitoring = false
		hitbox.monitorable = false

@abstract
func apply_motion(delta: float) -> void

@abstract
func _on_timer_timeout() -> void

@tool
@abstract class_name ProjectileBase
extends AnimatedSprite2D

@export var damage: int = 1

@export var body: Node2D

## Reusable, inspector-assignable modifiers (punch, spin, flash, etc).
var _modifiers: Array[ProjectileModifier] = []

@export_group("Cleanup")
@export var time_out: float = 10.0
@export var enable_timeout: bool = false
var timer: Timer

@export_group("Screen Culling")
@export var visibility_rect: Rect2 = Rect2(-32, -32, 64, 64):
	set(value):
		visibility_rect = value
		queue_redraw()

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
	return Util.find_descendant_breadthfirst(self, func(v): return v is Area2D) as Area2D

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	if body == null:
		body = self

	for child in get_children():
		if child is ProjectileModifier:
			_modifiers.push_back(child)

	hitbox = _find_hitbox()
	assert(hitbox != null)
	hitbox.monitoring = true
	hitbox.monitorable = true

	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time_out
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	var on_screen_detector := VisibleOnScreenNotifier2D.new()
	on_screen_detector.rect = visibility_rect
	on_screen_detector.screen_exited.connect(func(): queue_free())
	add_child(on_screen_detector)	

	for m in _modifiers:
		m.start.call_deferred(self) # To give time for modifiers to disconnect/replace hitbox events

	if enable_timeout:
		timer.start()

func scan_hits():
	for hit_body in hitbox.get_overlapping_bodies():
		_on_projectile_hit(hit_body)

func _on_projectile_hit(hit_body: Node2D):
	var controller = Util.find_most_related(hit_body, func(v): return v is PlayerController2D) as PlayerController2D
	if controller and controller.is_blocking(): return

	var hit_health = Util.find_most_related(hit_body, func(v): return v is Health) as Health
	if hit_health: hit_health.damage(damage)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	apply_motion(delta)
	for m in _modifiers:
		m.process_modifier(delta, self)

@abstract
func apply_motion(delta: float) -> void

@abstract
func _on_timer_timeout() -> void

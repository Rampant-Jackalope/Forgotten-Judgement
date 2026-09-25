@tool
class_name DeathBox2D
extends Area2D

@export var default_damage: int = 1

## X/Y are percentage offsets of the viewport for the top left corner of the shape
## W/H actual height and width of the shape in viewport percentages
@export_custom(
	PROPERTY_HINT_LINK,
	"suffix:%/1",
) var shape_sizing: Rect2 = Rect2(0.0, 0.0, 1.0, 1.0):
	set(value):
		shape_sizing.position = value.position.clamp(Vector2.ZERO, Vector2(1, 1))
		shape_sizing.size = value.size.clamp(Vector2.ZERO, Vector2(1, 1))
		scale_refresh()

@export var default_active_time: float = 1

var timer: Timer
var collision_shape: CollisionShape2D

signal entity_hit(entity: Node, damage: int)

func _enter_tree():
	_ensure_collision_shape()
	if Engine.is_editor_hint():
		scale_refresh()

func _ensure_collision_shape() -> void:
	collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		return

	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	collision_shape.shape = RectangleShape2D.new()
	add_child(collision_shape)
	if Engine.is_editor_hint():
		# without this, the shape works fine visually but Godot won't
		# persist it into the .tscn and it won't show in the Scene dock
		collision_shape.owner = get_tree().edited_scene_root

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	timer = Timer.new()
	timer.wait_time = default_active_time
	timer.autostart = false
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

	body_entered.connect(_on_body_entered)
	get_viewport().size_changed.connect(scale_refresh)

	scale_refresh()

func scale_refresh() -> void:
	if not collision_shape or not collision_shape.shape:
		return

	if self.global_position != Vector2.ZERO:
		self.global_position = Vector2.ZERO

	var viewport_size: Vector2

	# when running as a tool script it uses the editors viewport size which is different than the game's viewport size
	if Engine.is_editor_hint():
		viewport_size = Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height"),
		)
	else:
		viewport_size = get_viewport().get_visible_rect().size

	var actual_size = Vector2(
		viewport_size.x * shape_sizing.size.x,
		viewport_size.y * shape_sizing.size.y,
	)
	collision_shape.shape.size = actual_size

	var top_left = Vector2(
		viewport_size.x * shape_sizing.position.x,
		viewport_size.y * shape_sizing.position.y,
	)
	collision_shape.position = top_left + actual_size / 2

func _on_body_entered(body: Node) -> void:
	entity_hit.emit(body, default_damage)

func _on_timer_timeout() -> void:
	self.monitoring = false
	self.monitorable = false

func activate() -> void:
	timer.start()
	self.monitoring = true
	self.monitorable = true

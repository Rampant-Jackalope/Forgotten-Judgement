@tool
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
@onready var timer: Timer = Timer.new()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

signal entity_hit(entity: Node, damage: int)

func _enter_tree():
	if Engine.is_editor_hint():
		self.collision_shape = get_node_or_null("CollisionShape2D")
		scale_refresh()

func _ready() -> void:
	timer.wait_time = default_active_time
	timer.autostart = false
	timer.one_shot = true

	add_child(timer)
	get_viewport().size_changed.connect(scale_refresh)

func scale_refresh() -> void:
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
	Util.disable_node(self)

func activate() -> void:
	timer.start()
	Util.enable_node(self)

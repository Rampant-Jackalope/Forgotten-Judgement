class_name Inspectable extends Interactable

@export_file("*.png", "*.jpg", "*.jpeg") var inspect_image: String:
	set(value):
		_texture = load(value)
		inspect_image = value
var _texture: Texture2D = load(inspect_image)

@export var maximum_size: Vector2 = Vector2(1000, 1000) ## Maximum size for the created TextureRect

var _posessions: Array[Node] = []

func _enter_tree() -> void:
	super()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	interacted.connect(_interacted)

func _interacted(interactor: Interactor, _pop: Callable) -> void:
	var rect = create_texture_rect(_texture)
	_posessions.push_back(rect)
	interactor.player.add_child(rect)

func create_texture_rect(texture: Texture2D) -> TextureRect:
	var rect = TextureRect.new()

	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	# rect.custom_maximum_size = maximum_size
	rect.mouse_filter = Control.MOUSE_FILTER_STOP

	return rect

func _input(event: InputEvent) -> void:
	if not event.is_pressed(): return
	if not event is InputEventMouseMotion:
		_cleanup()

func _exit_tree() -> void:
	_cleanup()
	super()

func _cleanup() -> void:
	for v in _posessions:
		if v: v.queue_free()
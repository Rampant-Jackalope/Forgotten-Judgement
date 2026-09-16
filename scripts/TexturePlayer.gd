class_name TexturePlayer
extends TextureRect

## Root directory bc `@export_dir` does not work within `Dictionary`
@export_dir var root_dir: String
@export_group("[Identifier : Directory]")
@export var frame_sources: Dictionary[String, String]
@export var fps := 30.0
@export var loop := false

var current_source: String 
var frames: Array[Texture2D] = []
var current_frame := 0
var elapsed := 0.0

func _ready():
	if frame_sources.is_empty():
		return

func _process(delta: float):
	if frames.is_empty() or fps <= 0.0:
		return

	elapsed += delta

	if elapsed >= 1.0 / fps:
		elapsed -= 1.0 / fps
		play()

func play(identifier: String = "") -> bool:
	if frame_sources.is_empty():
		return false

	# Switch source if a different identifier was requested
	if identifier != "" and (current_source == null or identifier not in frame_sources):
		var source: Resource = frame_sources.get(identifier)
		if source == null:
			return false
		current_source = source.to_string()
		set_frame_dir(source)

	if frames.is_empty():
		return false

	current_frame += 1

	if current_frame >= frames.size():
		if loop:
			current_frame = 0
		else:
			current_frame = frames.size() - 1

	texture = frames[current_frame]
	return true

func set_frame_dir(source: Resource):
	frames.clear()
	current_frame = 0
	elapsed = 0.0

	var directory := DirAccess.open(source.to_string())

	if directory == null:
		push_error("Could not open: " + source.to_string())
		return

	var files := directory.get_files()
	files.sort()

	for file in files:
		if file.ends_with(".png"):
			var tex := load(current_source + file) as Texture2D
			if tex:
				frames.append(tex)

	if not frames.is_empty():
		texture = frames[0]

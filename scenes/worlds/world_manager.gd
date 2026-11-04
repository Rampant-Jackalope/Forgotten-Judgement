class_name WorldManager
extends Node

signal world_changed(in_2d: bool)

@export var world_3d: WorldEnvironment
@export var worlds_2d: Dictionary[String, PackedScene]

@onready var container_2d: Node = $'2D'

# recreating singleton pattern bc managing configuration with scene editor is better than keeping path strings up to date in code
static var instance: WorldManager

var _mouse_mode_3d: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
var _in_2d := false

# set in _enter_tree (top-down) rather than _ready (bottom-up) so listeners
# can safely connect to the instance from their own _ready
func _enter_tree() -> void:
	assert(WorldManager.instance == null, "WorldManager instance already exists")
	WorldManager.instance = self

func _ready() -> void:
	assert(world_3d != null, "No 3D world found")
	assert(container_2d != null, "No 2D container found")

func _exit_tree() -> void:
	# clear as to not fuck ourselves over
	if WorldManager.instance == self:
		WorldManager.instance = null

static func set_world_to_3d() -> void:
	var local_instance := WorldManager.instance
	assert(local_instance != null, "WorldManager has not been initialized")
	_clear_2d(local_instance)
	Util.set_enabled(local_instance.world_3d, true)

	if local_instance._in_2d:
		local_instance._in_2d = false
		Input.mouse_mode = local_instance._mouse_mode_3d

	# after Util.set_enabled so listeners get the last word over whatever it restored
	local_instance.world_changed.emit(false)

static func set_world_to_2d(identifier: String) -> void:
	var local_instance := WorldManager.instance
	assert(local_instance != null, "WorldManager has not been initialized")
	assert(local_instance.worlds_2d.has(identifier), "Could not find '%s' 2d world" % identifier)

	Util.set_enabled(local_instance.world_3d, false)
	assert(local_instance.world_3d.process_mode == Node.PROCESS_MODE_DISABLED, "Failed to disable 3d world while setting 2d world")

	# swapping 2d -> 2d shouldn't stack scenes
	_clear_2d(local_instance)

	local_instance._in_2d = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	# after Util.set_enabled so listeners get the last word over whatever it saved/hid
	local_instance.world_changed.emit(true)

	var scene_instance := local_instance.worlds_2d[identifier].instantiate()
	local_instance.container_2d.add_child(scene_instance)

static func _clear_2d(local_instance: WorldManager) -> void:
	for child in local_instance.container_2d.get_children():
		child.queue_free()

## The mouse mode the 3D side wants. Always remembered, applied immediately
## only when 3D is active, otherwise applied when we return to 3D.
static func set_3d_mouse_mode(mode: Input.MouseMode) -> void:
	var inst := WorldManager.instance
	if inst == null:
		Input.mouse_mode = mode
		return
	inst._mouse_mode_3d = mode
	if not inst._in_2d:
		Input.mouse_mode = mode

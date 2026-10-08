class_name PlayerController3D
extends Node3D

@export var cam_pivot: Node3D
@export var camera: Camera3D
@export var collider: CollisionShape3D
@export var body: CharacterBody3D
@export var player_root: Player3D

@export var run_speed := 5.0
@export var jump_height := 0.5 # meters, average casual human jump
@export var gravity := 9.81

@export var mouse_sensitivity := 0.0025
@export_range(0, -90) var min_pitch_deg := -90.0 # how far down you can look
@export_range(0, 90) var max_pitch_deg := 90.0 # how far up you can look

var jump_speed: float

func _ready() -> void:
	camera.current = true
	jump_speed = sqrt(2.0 * gravity * jump_height)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if player_root.dialogue_locked:
		return
	# Mouse look: yaw rotates the whole body, pitch only rotates the camera
	if event is InputEventMouseMotion:
		body.rotate_y(-event.relative.x * mouse_sensitivity)
		cam_pivot.rotate_x(wrapf(-event.relative.y * mouse_sensitivity, -PI, PI))
		cam_pivot.rotation.x = clamp(
			cam_pivot.rotation.x,
			deg_to_rad(min_pitch_deg),
			deg_to_rad(max_pitch_deg)
		)

	# Let Esc release the mouse (debugging/menu purposes)
	# if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
	# 	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

func get_input() -> void:
	if player_root.dialogue_locked:
		body.velocity.x = 0.0
		body.velocity.z = 0.0
		return

	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1.0
	if Input.is_action_pressed("move_backward"):
		input_dir.z += 1.0
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1.0
	input_dir = input_dir.normalized()

	# Transform local input into world space using the body's yaw only
	var direction: Vector3 = (body.transform.basis * input_dir)
	body.velocity.x = direction.x * run_speed
	body.velocity.z = direction.z * run_speed

	if body.is_on_floor() and Input.is_action_just_pressed("jump"):
		body.velocity.y = jump_speed

func _process(delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta
	get_input()
	body.move_and_slide()

@export_group("Look At")
@export_range(0, 100) var minimum_pitch_distance = 0.2 ## The minimum distance to the target before pitch is also included

var is_looking_at: bool = false

func smooth_look_at(target_position: Vector3, duration: float = 0.35) -> void:
	var look_vector = target_position - camera.global_position
	var distance = look_vector.length()
	var horizontal_distance = Vector2(look_vector.x, look_vector.z).length()
	if distance < 0.05:
		return # target is basically on top of us; nothing to turn

	var goal_yaw = atan2(-look_vector.x, -look_vector.z)
	var yaw = body.rotation.y + wrapf(goal_yaw - body.rotation.y, -PI, PI)

	var goal_pitch = 0.0
	if distance > minimum_pitch_distance:
		goal_pitch = atan2(look_vector.y, horizontal_distance)
		goal_pitch = clampf(goal_pitch, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))

	is_looking_at = true
	var t = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(body, "rotation:y", yaw, duration)
	t.parallel().tween_property(cam_pivot, "rotation:x", goal_pitch, duration)
	await t.finished
	is_looking_at = false

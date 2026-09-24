extends CharacterBody2D

@export var health: Health
@export var stamina: Stamina

func _ready() -> void:
	assert(health)
	assert(stamina)

	health.became_empty.connect(died.emit)

signal died()

func _unhandled_input(event: InputEvent) -> void:
	if not stamina:
		return

	# Only proceed if a button was pressed down (ignore button releases)
	if not event.is_pressed():
		return

	# Left Click / Attack Action -> Consumes 20% stamina
	if event.is_action_pressed("attack") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		var amount: int = ceil(stamina.max_stamina * 0.2)
		if not stamina.try_consume(amount):
			print("Not enough stamina to attack!")
		get_viewport().set_input_as_handled()

	# Right Click / Block Action -> Consumes 10% stamina
	elif event.is_action_pressed("block") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT):
		var amount: int = ceil(stamina.max_stamina * 0.1)
		if not stamina.try_consume(amount):
			print("Not enough stamina to block!")
		get_viewport().set_input_as_handled()

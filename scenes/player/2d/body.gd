extends CharacterBody2D

@export var health: Health
@export var stamina: Stamina
@export var attack_consume_percentage: float
@export var block_consume_percentage: float

var attack_consume_value: int
var block_consume_value: int
func _ready() -> void:
	assert(health)
	assert(stamina)
	
	attack_consume_value = ceil(stamina.max_stamina * attack_consume_percentage)
	block_consume_value = ceil(stamina.max_stamina * block_consume_percentage)
	health.became_empty.connect(died.emit)

signal died()

func _unhandled_input(event: InputEvent) -> void:
	if not stamina:
		return

	# Only proceed if a button was pressed down (ignore button releases)
	if not event.is_pressed():
		return

	# Left Click / Attack Action -> Consumes 20% stamina
	if event.is_action_pressed("attack"):
		if not stamina.try_consume(attack_consume_value):
			print("Not enough stamina to attack!")
		get_viewport().set_input_as_handled()

	# Right Click / Block Action -> Consumes 10% stamina
	elif event.is_action_pressed("block"):
		if not stamina.try_consume(block_consume_value):
			print("Not enough stamina to block!")
		get_viewport().set_input_as_handled()

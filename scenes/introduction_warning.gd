extends Area3D

# Reference to the collision shape of the parent node (IntroductionChecker)
@onready var blocker_collision: CollisionShape3D = $"../CollisionShape3D"

# Cooldown flag to prevent the dialogue from spamming
var can_trigger: bool = true

func _ready() -> void:
	# Connect the body_entered signal programmatically
	body_entered.connect(_on_body_entered)
	
	# Check immediately upon loading whether the barrier should be removed
	_check_barrier_status()

func _check_barrier_status() -> void:
	# If the player has already talked to the bartender, disable the collision
	if Dialogic.VAR.bartender.HasMetBartender:
		blocker_collision.disabled = true

func _on_body_entered(body: Node3D) -> void:
	# Check if it is the player (adjust "Player3D" if your node name differs)
	if body.name == "Player3D" or body.is_in_group("Player"):
		if Dialogic.VAR.bartender.HasMetBartender:
			blocker_collision.disabled = true
		elif can_trigger:
			# Temporarily disable triggering to create a pause/cooldown
			can_trigger = false
			
			# Run the locked dialogue
			body.run_locked_dialogue("introduction-warning")
			
			# Wait for 10 seconds before allowing the warning to trigger again
			await get_tree().create_timer(10.0).timeout
			can_trigger = true

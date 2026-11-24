extends Area3D

@export var blocker_collision: CollisionShape3D ## Reference to the collision shape of the parent node (IntroductionChecker)

# Cooldown flag to prevent the dialogue from spamming
var can_trigger: bool = true

func _ready() -> void:
	# Assert that blocker_collision is assigned in the Inspector
	assert(blocker_collision != null, "Blocker collision shape must be assigned in the Inspector!")
	
	# Connect the body_entered signal programmatically
	body_entered.connect(_on_body_entered)
	
	# If the player has already talked to the bartender, disable the collision
	if Dialogic.VAR.bartender.HasMetBartender:
		blocker_collision.disabled = true

func _on_body_entered(body: Node3D) -> void:
	pass
	# TODO: remove after refactor done
	# # Check if it is the player
	# if body is Player3D or body.is_in_group("Player"):
	# 	if Dialogic.VAR.bartender.HasMetBartender:
	# 		blocker_collision.disabled = true
	# 	elif can_trigger:
	# 		# Temporarily disable triggering to create a pause/cooldown
	# 		can_trigger = false
	#
	# 		# Run the locked dialogue
	# 		body.run_locked_dialogue("introduction-warning")
	#
	# 		# Wait for 10 seconds before allowing the warning to trigger again
	# 		await get_tree().create_timer(10.0).timeout
	# 		can_trigger = true

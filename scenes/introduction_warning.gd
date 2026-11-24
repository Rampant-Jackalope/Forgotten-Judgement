extends Area3D

@export var blocker_collision: CollisionShape3D ## Reference to the collision shape of the parent node (IntroductionChecker)

# Cooldown flag to prevent the dialogue from spamming
var can_trigger: bool = true

func _ready() -> void:
	assert(blocker_collision != null, "Blocker collision shape must be assigned in the Inspector!")
	body_entered.connect(_on_body_entered)
	# If the player has already talked to the bartender, disable the collision
	if Util.talked_to(Util.NPC.BARTENDER):
		blocker_collision.disabled = true

func _on_body_entered(body: Node3D) -> void:
	pass
	# TODO: remove after refactor done
	if body is Player3D or body.is_in_group("Player"):
		if Util.talked_to(Util.NPC.BARTENDER):
			blocker_collision.disabled = true
		elif can_trigger:
			can_trigger = false
			body.run_locked_dialogue("misc-popups", "introduction_warning")

			# Wait for 10 seconds before allowing the warning to trigger again
			await get_tree().create_timer(10.0).timeout
			can_trigger = true

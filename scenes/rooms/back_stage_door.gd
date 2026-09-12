extends OpenCloseDoor

func _ready() -> void:
	child.left_clicked.connect(_on_interactable_door_left_clicked)
	child.close()

func _on_interactable_door_left_clicked(_hit_position: Vector3, _normal: Vector3) -> void:
	if Dialogic.VAR.michael.STAGE_DOOR_OPENED:
		child.toggle()
		return

	if Dialogic.VAR.michael.RESPECT >= 5.0:
		if Dialogic.VAR.michael.HAS_STAGE_KEY:
			Util.run_locked_dialogue("michael_jackson/warning", "respect_pass_key_pass")
			Dialogic.VAR.michael.STAGE_DOOR_OPENED = true
			self.child.open()
		else:
			Util.run_locked_dialogue("michael_jackson/warning", "respect_pass_key_fail")
	else:
		if Dialogic.VAR.michael.HAS_STAGE_KEY:
			Util.run_locked_dialogue("michael_jackson/warning", "respect_fail_key_pass")
		else:
			Util.run_locked_dialogue("michael_jackson/warning", "respect_fail_key_fail")

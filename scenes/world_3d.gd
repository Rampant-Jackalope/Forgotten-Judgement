extends WorldEnvironment

func _enter_tree() -> void:
	if GameState.data[GameState.DataKey.LOAD_SAVE]:
		GameState.load_from_disk()

func _exit_tree() -> void:
	GameState.save_to_disk()

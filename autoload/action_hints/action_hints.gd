extends Control

@export var container: VBoxContainer

class Hint extends Label:	
	func pop() -> void:
		self.queue_free()

func _ready() -> void:
	assert(container != null, "No container assigned for action hints")

func push_hint(action_name: String) -> Callable:
	var instance := Hint.new()
	instance.text = "Press [" + Util.get_action_key_text(action_name) + "] to " + action_name
	container.add_child(instance)

	return instance.pop

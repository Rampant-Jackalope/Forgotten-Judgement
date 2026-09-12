extends Area3D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_exited(_area: Area3D) -> void:
	print_debug("area exited")
	Dialogic.VAR.michael.NEARBY = false

func _on_area_entered(_area: Area3D) -> void:
	print_debug("area entered")
	Dialogic.VAR.michael.NEARBY = true

extends CanvasLayer
## Hides the whole HUD while any Dialogic timeline is running.

func _ready() -> void:
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_started() -> void:
	$Hotbar.set_expanded(false) # in case the hotbar was open when dialogue started
	hide()

func _on_timeline_ended() -> void:
	show()

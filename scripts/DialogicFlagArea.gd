class_name DialogicFlagArea
extends Area3D
## Sets a Dialogic variable to true while the player is inside this area, false otherwise.
## Lets timelines branch on where the player is, e.g. `if {singer.PLAYER_ON_STAGE} == true:`.
## Give it a CollisionShape3D child like any Area3D.
## 
## Reason for adding: for if we need dialogue options to be dependant on where the player is.

@export var flag: String ## Dialogic variable to drive, e.g. "singer.PLAYER_ON_STAGE"


func _ready() -> void:
	assert(Dialogic.VAR.has(flag), "DialogicFlagArea: unknown Dialogic variable '%s'" % flag)
	collision_layer = 0 # only detects, nothing needs to detect this area
	body_entered.connect(_on_body_moved.bind(true))
	body_exited.connect(_on_body_moved.bind(false))


func _exit_tree() -> void:
	# e.g. scene change to a fight while standing inside: don't leave the flag stuck on true
	if Dialogic.VAR.has(flag):
		Dialogic.VAR.set_variable(flag, false)


func _on_body_moved(body: Node3D, inside: bool) -> void:
	if body is Player3D:
		Dialogic.VAR.set_variable(flag, inside)

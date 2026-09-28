extends CanvasLayer
#made autoloadable so I can access it for Util.gd

#different name than the autoload name, otherwise it gives a warning.
class_name InstantiatableEffectScreen

var _fade_timer : Timer = Timer.new()

var _fadingRect: ColorRect

func _ready() -> void:
	layer = 100                              # above gameplay
	process_mode = Node.PROCESS_MODE_ALWAYS  # doesn't care about tree being paused
	
	#for the screenfading
	_fadingRect = ColorRect.new()
	_fadingRect.color = Color(0, 0, 0, 0)          # transparent black
	_fadingRect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fadingRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fadingRect.visible = false
	add_child(_fadingRect)
	

## Fade to black. Awaitable.
func fade_in(duration: float = 0.4) -> void:
	_fadingRect.visible = true
	_fade_timer.set_wait_time(duration)
	await _fadingTo(1.0, _fade_timer.wait_time)

## Fade back in. Awaitable.
func fade_to(duration: float = 0.5) -> void:
	_fadingRect.visible = true
	_fade_timer.set_wait_time(duration)
	await _fadingTo(0.0, _fade_timer.wait_time)

## Fade out, run 'midpoint' while black, then fade in. Awaitable.
func screenFadeTransition(midpoint: Callable, out_time: float = 0.4,
		hold: float = 0.1, in_time: float = 0.5) -> void:
	await fade_in(out_time)
	if hold > 0.0:
		#note: original code used await get_tree().create_timer(hold).timeout, which is a SceneTreeTimer node and not a Timer node.
		_fade_timer.set_wait_time(hold)
		_fade_timer.start()
		await _fade_timer.timeout
	if midpoint.is_valid():
		midpoint.call()
	await fade_to(in_time)

func _fadingTo(alpha: float, duration: float) -> void:
	var t := create_tween()
	t.tween_property(_fadingRect, "color:a", alpha, duration)
	await t.finished

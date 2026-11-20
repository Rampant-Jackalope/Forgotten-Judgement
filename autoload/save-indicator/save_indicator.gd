extends Control

@export var video_stream_player: VideoStreamPlayer
@export var animations: Array[VideoStream]
## Minimum time the indicator stays visible, so fast saves don't flicker.
@export_range(0.0, 5.0, 0.1, "suffix:s") var minimum_display_time: float = 1.0

var _play_started_msec := 0
var _session := 0 # bumped on every play(), invalidates pending stops
var _playing := false

func _ready() -> void:
	assert(video_stream_player != null, "No video stream player assigned")
	assert(animations.size() > 0, "No animations assigned")

	process_mode = PROCESS_MODE_ALWAYS # so its visible in pause menu

	video_stream_player.loop = true
	GameState.about_to_save.connect(play)
	GameState.save_done.connect(stop)

func play() -> void:
	if !Settings.show_save_indicator: return
	_session += 1
	_playing = true
	_play_started_msec = Time.get_ticks_msec()
	video_stream_player.stream = animations.pick_random()
	video_stream_player.play()

func stop() -> void:
	if not _playing: return

	var session := _session
	var elapsed := (Time.get_ticks_msec() - _play_started_msec) / 1000.0
	var remaining := minimum_display_time - elapsed

	if remaining > 0.0:
		# process_always = true so the timer keeps running while paused,
		# ignore_time_scale = true so slow-mo doesn't stretch it
		await get_tree().create_timer(remaining, true, false, true).timeout
		# a new save started while we were waiting, leave its playback alone
		if session != _session: return

	_playing = false
	video_stream_player.stop()
	video_stream_player.stream = null

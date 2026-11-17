extends Control
## Official opening cinematic controller for ASHVALE: THE THIRTEENTH BELL.
## Plays the 720p Ogg Theora cinematic on New Game, supports Space/Esc skip,
## and transitions into the clean Bellhaven prologue.

const OGV_PATH := "res://assets/cinematics/ASHVALE_Opening_Godot_720p.ogv"
const BELLHAVEN_SCENE := "res://scenes/sjt_exterior.tscn"
const QuestManagerScript := preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript := preload("res://scripts/systems/audio_manager.gd")

@onready var video_player: VideoStreamPlayer = $AspectRatioContainer/VideoPlayer
@onready var skip_hint: Label = $SkipHint

var _transitioning: bool = false
var _frames_alive: int = 0
var _stream_started: bool = false

func _ready() -> void:
	# Ensure audio manager buses exist and game ambience is silent
	var audio_mgr := AudioManagerScript.ensure(get_tree()) if is_inside_tree() else null
	if audio_mgr != null:
		if audio_mgr.has_method("set_menu_ducking"):
			audio_mgr.set_menu_ducking(false)
		if audio_mgr.has_method("stop_all_audio"):
			audio_mgr.stop_all_audio()

	# Verify video asset exists on disk or in PCK
	if not FileAccess.file_exists(OGV_PATH) and not ResourceLoader.exists(OGV_PATH):
		push_warning("[IntroCinematic] Video not found at " + OGV_PATH + ", bypassing cinematic.")
		_transition_to_gameplay("video_missing")
		return

	# Setup stream
	var stream: VideoStreamTheora
	if ResourceLoader.exists(OGV_PATH):
		var res: Resource = load(OGV_PATH)
		if res is VideoStreamTheora:
			stream = res
	if stream == null:
		stream = VideoStreamTheora.new()
		stream.file = OGV_PATH

	video_player.stream = stream
	video_player.bus = &"Master"
	video_player.expand = true
	video_player.finished.connect(_on_video_finished)

	# Start playback
	video_player.play()

func _process(_delta: float) -> void:
	if _transitioning:
		return
	_frames_alive += 1

	if video_player != null and video_player.is_playing():
		_stream_started = true

	# Watchdog: If after 30 frames the stream hasn't started and we're headless or decoding failed, bypass gracefully
	if _frames_alive > 30 and not _stream_started:
		if DisplayServer.get_name() == "headless" or video_player.get_stream_length() <= 0.0:
			push_warning("[IntroCinematic] Video playback did not start or running headless, bypassing.")
			_transition_to_gameplay("playback_timeout_or_headless")

func _input(event: InputEvent) -> void:
	if _transitioning or event.is_echo():
		return
	var is_skip: bool = false
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact") or event.is_action_pressed("dismiss"):
		is_skip = true
	elif event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE or event.keycode == KEY_ESCAPE or event.keycode == KEY_ENTER:
			is_skip = true

	if is_skip:
		var vp := get_viewport()
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
		_transition_to_gameplay("skipped_by_user")

func _on_video_finished() -> void:
	_transition_to_gameplay("video_completed")

func _transition_to_gameplay(reason: String = "") -> void:
	if _transitioning:
		return
	_transitioning = true

	if video_player != null and is_instance_valid(video_player):
		video_player.stop()

	# Execute existing fresh-game initialization exactly once
	QuestManagerScript.reset_session_state()
	QuestManagerScript.pending_load_path = ""
	QuestManagerScript.pending_entry_pose = false
	QuestManagerScript.carry_prologue_completed = false
	QuestManagerScript.carry_chapter1_completed = false
	QuestManagerScript.carry_chapter2_completed = false
	QuestManagerScript.carry_chapter3_completed = false
	QuestManagerScript.carry_chapter4_completed = false
	QuestManagerScript.carry_storm_resolved = false
	QuestManagerScript.carry_optional_discoveries.clear()
	QuestManagerScript.pending_chapter5_snapshot = {}

	if is_inside_tree():
		var audio_mgr := AudioManagerScript.ensure(get_tree())
		if audio_mgr != null and audio_mgr.has_method("set_menu_ducking"):
			audio_mgr.set_menu_ducking(false)
		get_tree().change_scene_to_file(BELLHAVEN_SCENE)

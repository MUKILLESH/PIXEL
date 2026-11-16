extends Node
class_name AudioManager
## Lightweight procedural audio manager with Master, Music, SFX, and Ambient buses.
## Generates soft PCM16 AudioStreamWAV assets in memory (no external unlicensed files).

const SETTINGS_PATH := "user://ashvale_audio_settings.json"
const BUS_NAMES := ["Master", "Music", "SFX", "Ambient"]
const SAMPLE_RATE := 22050

var _cached_waves: Dictionary = {}

var master_volume: float = 0.85
var music_volume: float = 0.70
var sfx_volume: float = 0.80
var ambient_volume: float = 0.75

var active_region_id: String = ""
var last_played_sfx: String = ""

var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var _sfx_cursor: int = 0

static func ensure(tree: SceneTree) -> Node:
	if tree == null or tree.root == null:
		return null
	var existing: Node = tree.root.get_node_or_null("AshvaleAudio")
	if existing != null:
		return existing
	if tree.root.has_meta("_pending_ashvale_audio"):
		var pending: Variant = tree.root.get_meta("_pending_ashvale_audio")
		if pending is Node and is_instance_valid(pending):
			return pending
	var mgr: Node = load("res://scripts/systems/audio_manager.gd").new()
	mgr.name = "AshvaleAudio"
	if tree.root.is_node_ready():
		tree.root.add_child(mgr)
	else:
		tree.root.set_meta("_pending_ashvale_audio", mgr)
		tree.root.add_child.call_deferred(mgr)
	return mgr

static func play_global_sfx(tree: SceneTree, sfx_id: String) -> void:
	var mgr := ensure(tree)
	if mgr != null and mgr.has_method("play_sfx"):
		mgr.play_sfx(sfx_id)

static func play_global_region(tree: SceneTree, region_id: String) -> void:
	var mgr := ensure(tree)
	if mgr != null and mgr.has_method("play_region_ambience"):
		mgr.play_region_ambience(region_id)

func _ready() -> void:
	_ensure_audio_buses()
	_build_players()
	load_settings()
	_apply_all_volumes()

func stop_all() -> void:
	if music_player != null:
		music_player.stop()
		music_player.stream = null
	if ambient_player != null:
		ambient_player.stop()
		ambient_player.stream = null
	for p in sfx_players:
		if p != null:
			p.stop()
			p.stream = null
	active_region_id = ""

func _exit_tree() -> void:
	stop_all()
	_cached_waves.clear()

func _ensure_audio_buses() -> void:
	for bname in BUS_NAMES:
		if bname == "Master":
			continue
		if AudioServer.get_bus_index(bname) == -1:
			var idx: int = AudioServer.bus_count
			AudioServer.add_bus(idx)
			AudioServer.set_bus_name(idx, bname)
			AudioServer.set_bus_send(idx, "Master")

func _build_players() -> void:
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		music_player.bus = &"Music"
		music_player.volume_db = -10.0
		add_child(music_player)
	if ambient_player == null:
		ambient_player = AudioStreamPlayer.new()
		ambient_player.name = "AmbientPlayer"
		ambient_player.bus = &"Ambient"
		ambient_player.volume_db = -8.0
		add_child(ambient_player)
	if sfx_players.is_empty():
		for i in range(4):
			var p := AudioStreamPlayer.new()
			p.name = "SfxPlayer%d" % i
			p.bus = &"SFX"
			p.volume_db = -4.0
			p.max_polyphony = 2
			add_child(p)
			sfx_players.append(p)

func set_bus_linear(bus_name: String, linear_val: float) -> void:
	var clamped: float = clampf(linear_val, 0.0, 1.0)
	match bus_name:
		"Master":
			master_volume = clamped
		"Music":
			music_volume = clamped
		"SFX":
			sfx_volume = clamped
		"Ambient":
			ambient_volume = clamped
		_:
			return
	_apply_bus_volume(bus_name, clamped)

func get_bus_linear(bus_name: String) -> float:
	match bus_name:
		"Master":
			return master_volume
		"Music":
			return music_volume
		"SFX":
			return sfx_volume
		"Ambient":
			return ambient_volume
	return 1.0

func _apply_all_volumes() -> void:
	_apply_bus_volume("Master", master_volume)
	_apply_bus_volume("Music", music_volume)
	_apply_bus_volume("SFX", sfx_volume)
	_apply_bus_volume("Ambient", ambient_volume)

func _apply_bus_volume(bus_name: String, value_0_to_1: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_mute(idx, value_0_to_1 <= 0.001)
	if value_0_to_1 > 0.001:
		AudioServer.set_bus_volume_linear(idx, value_0_to_1)

func play_region_ambience(region_id: String) -> void:
	if region_id == "" or region_id == active_region_id:
		return
	active_region_id = region_id
	_ensure_audio_buses()
	_build_players()
	var can_play: bool = (DisplayServer.get_name() != "headless")
	if ambient_player != null:
		ambient_player.stream = _get_or_make_stream("amb_" + region_id)
		if can_play:
			ambient_player.play()
	if music_player != null:
		music_player.stream = _get_or_make_stream("mus_" + region_id)
		if can_play:
			music_player.play()

func play_sfx(sfx_id: String) -> void:
	last_played_sfx = sfx_id
	_ensure_audio_buses()
	_build_players()
	if sfx_players.is_empty():
		return
	var p: AudioStreamPlayer = sfx_players[_sfx_cursor % sfx_players.size()]
	_sfx_cursor += 1
	p.stream = _get_or_make_stream("sfx_" + sfx_id)
	p.pitch_scale = randf_range(0.96, 1.04) if sfx_id == "footstep" else 1.0
	if DisplayServer.get_name() != "headless":
		p.play()

func save_settings(custom_path: String = "") -> Error:
	var path: String = SETTINGS_PATH if custom_path == "" else custom_path
	var payload := {
		"version": 1,
		"master": master_volume,
		"music": music_volume,
		"sfx": sfx_volume,
		"ambient": ambient_volume,
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return OK

func load_settings(custom_path: String = "") -> bool:
	var path: String = SETTINGS_PATH if custom_path == "" else custom_path
	if not FileAccess.file_exists(path):
		return false
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return false
	master_volume = clampf(float(parsed.get("master", master_volume)), 0.0, 1.0)
	music_volume = clampf(float(parsed.get("music", music_volume)), 0.0, 1.0)
	sfx_volume = clampf(float(parsed.get("sfx", sfx_volume)), 0.0, 1.0)
	ambient_volume = clampf(float(parsed.get("ambient", ambient_volume)), 0.0, 1.0)
	_apply_all_volumes()
	return true

func _get_or_make_stream(key: String) -> AudioStreamWAV:
	if _cached_waves.has(key):
		return _cached_waves[key]
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false

	var samples := PackedByteArray()
	var dur: float = 0.25
	var loop_mode := AudioStreamWAV.LOOP_DISABLED

	if key.begins_with("amb_") or key.begins_with("mus_"):
		dur = 1.6
		loop_mode = AudioStreamWAV.LOOP_FORWARD
		samples = _synth_pad_or_ambience(key, dur)
	else:
		samples = _synth_sfx(key)
		dur = float(samples.size()) / float(SAMPLE_RATE * 2)

	wav.data = samples
	wav.loop_mode = loop_mode
	wav.loop_begin = 0
	wav.loop_end = int(samples.size() / 2)
	_cached_waves[key] = wav
	return wav

func _synth_pad_or_ambience(key: String, dur: float) -> PackedByteArray:
	var count: int = int(dur * SAMPLE_RATE)
	var buf := PackedByteArray()
	buf.resize(count * 2)
	var seed_val: float = 0.0
	var base_freq: float = 196.0
	var fifth_freq: float = 293.66
	var is_noise_bed: bool = key.begins_with("amb_")
	match key:
		"mus_bellhaven", "amb_bellhaven":
			base_freq = 220.0
			fifth_freq = 329.63
		"mus_briarwood", "amb_briarwood":
			base_freq = 174.61
			fifth_freq = 261.63
		"mus_floodmill", "amb_floodmill":
			base_freq = 146.83
			fifth_freq = 220.0
		"mus_ironwatch", "amb_ironwatch":
			base_freq = 130.81
			fifth_freq = 196.0
		"mus_dawnspire", "amb_dawnspire":
			base_freq = 164.81
			fifth_freq = 246.94
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var sample_f: float = 0.0
		if is_noise_bed:
			# Soft wind/water harmonic wash locked cleanly across loop seam
			seed_val = sin(float(i) * 12.9898) * 43758.5453
			var white: float = (seed_val - floor(seed_val)) * 2.0 - 1.0
			var swell: float = 0.55 + 0.45 * sin(TAU * t / dur)
			sample_f = (white * 0.045 * swell) + sin(TAU * base_freq * 0.5 * t) * 0.03
		else:
			var pad: float = sin(TAU * base_freq * t) * 0.06 + sin(TAU * fifth_freq * t) * 0.04
			sample_f = pad * (0.85 + 0.15 * sin(TAU * t / dur))
		var pcm: int = clampi(int(sample_f * 32767.0), -32767, 32767)
		buf[i * 2] = pcm & 0xFF
		buf[i * 2 + 1] = (pcm >> 8) & 0xFF
	return buf

func _synth_sfx(key: String) -> PackedByteArray:
	var f1: float = 523.25
	var f2: float = 659.25
	var dur: float = 0.22
	var amp: float = 0.16
	match key:
		"sfx_footstep":
			f1 = 120.0
			f2 = 90.0
			dur = 0.07
			amp = 0.08
		"sfx_dialogue_open":
			f1 = 392.0
			f2 = 523.25
			dur = 0.12
			amp = 0.12
		"sfx_item_pickup":
			f1 = 587.33
			f2 = 880.0
			dur = 0.24
			amp = 0.16
		"sfx_puzzle_solve":
			f1 = 523.25
			f2 = 783.99
			dur = 0.36
			amp = 0.18
		"sfx_save_game":
			f1 = 440.0
			f2 = 659.25
			dur = 0.28
			amp = 0.15
		"sfx_beacon_activate":
			f1 = 293.66
			f2 = 587.33
			dur = 0.48
			amp = 0.20
		"sfx_chapter_complete":
			f1 = 392.0
			f2 = 783.99
			dur = 0.55
			amp = 0.22
		"sfx_bell_toll":
			f1 = 196.0
			f2 = 392.0
			dur = 0.65
			amp = 0.22
		"sfx_mountain_wind":
			f1 = 210.0
			f2 = 155.0
			dur = 0.34
			amp = 0.11
		"sfx_distant_thunder":
			f1 = 98.0
			f2 = 72.0
			dur = 0.52
			amp = 0.16
		"sfx_stone_movement":
			f1 = 138.0
			f2 = 116.0
			dur = 0.26
			amp = 0.14
		"sfx_bridge_mechanism":
			f1 = 246.94
			f2 = 329.63
			dur = 0.38
			amp = 0.16
		"sfx_observatory_activate":
			f1 = 392.0
			f2 = 659.25
			dur = 0.44
			amp = 0.18
		"sfx_celestial_align":
			f1 = 440.0
			f2 = 880.0
			dur = 0.42
			amp = 0.18
		"sfx_sanctuary_awaken":
			f1 = 293.66
			f2 = 587.33
			dur = 0.56
			amp = 0.20
		"sfx_great_bell_resonance":
			f1 = 146.83
			f2 = 293.66
			dur = 0.68
			amp = 0.22
	var count: int = int(dur * SAMPLE_RATE)
	var buf := PackedByteArray()
	buf.resize(count * 2)
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var env: float = minf(1.0, t / 0.015) * pow(1.0 - t / dur, 1.5)
		var freq: float = f1 if t < dur * 0.45 else f2
		var tone: float = (sin(TAU * freq * t) * 0.72 + sin(TAU * freq * 1.5 * t) * 0.28) * env * amp
		var pcm: int = clampi(int(tone * 32767.0), -32767, 32767)
		buf[i * 2] = pcm & 0xFF
		buf[i * 2 + 1] = (pcm >> 8) & 0xFF
	return buf

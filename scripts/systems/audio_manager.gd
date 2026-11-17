extends Node
class_name AudioManager
## Adaptive soundtrack, natural ambience, and SFX mixer for ASHVALE: THE THIRTEENTH BELL.
## Routes audio through Master <- (MusicDuck <- Music), SFX, Ambient, and Cinematic buses
## with seamless crossfades, dialogue/revelation ducking, and Master hard limiting.

const SETTINGS_PATH := "user://ashvale_audio_settings.json"
const BUS_NAMES := ["Master", "MusicDuck", "Music", "SFX", "Ambient", "Cinematic"]
const SAMPLE_RATE := 22050

const MUSIC_BASE_DB := -2.5
const AMBIENT_BASE_DB := -6.5
const SFX_BASE_DB := -4.0
const CINEMATIC_BASE_DB := -3.0

const REGION_MUSIC_PATHS := {
	"bellhaven": "res://assets/audio/music/mus_bellhaven.ogg",
	"briarwood": "res://assets/audio/music/mus_briarwood.ogg",
	"floodmill": "res://assets/audio/music/mus_floodmill.ogg",
	"ironwatch": "res://assets/audio/music/mus_ironwatch.ogg",
	"dawnspire": "res://assets/audio/music/mus_dawnspire.ogg",
	"great_bell": "res://assets/audio/music/mus_great_bell.ogg",
	"great_bell_climax": "res://assets/audio/music/mus_great_bell_climax.ogg",
	"epilogue_dawn": "res://assets/audio/music/mus_epilogue_dawn.ogg",
}

const REGION_AMBIENCE_PATHS := {
	"bellhaven": "res://assets/audio/ambience/amb_bellhaven.ogg",
	"briarwood": "res://assets/audio/ambience/amb_briarwood.ogg",
	"floodmill": "res://assets/audio/ambience/amb_floodmill.ogg",
	"ironwatch": "res://assets/audio/ambience/amb_ironwatch.ogg",
	"dawnspire": "res://assets/audio/ambience/amb_dawnspire.ogg",
	"great_bell": "res://assets/audio/ambience/amb_great_bell.ogg",
	"epilogue_dawn": "res://assets/audio/ambience/amb_epilogue_dawn.ogg",
}

const CINEMATIC_SFX_IDS := [
	"bell_toll", "great_bell_resonance", "binding_sever", "beacon_activate",
	"observatory_activate", "sanctuary_awaken", "ritual_stabilize",
	"chapter_complete", "dawn_chord", "storm_recede", "distant_thunder",
]

var _stream_cache: Dictionary = {}

var master_volume: float = 0.85
var music_volume: float = 0.70
var sfx_volume: float = 0.80
var ambient_volume: float = 0.75

var active_region_id: String = ""
var active_music_key: String = ""
var last_played_sfx: String = ""

# Primary exposed player refs (always point to currently foreground A/B deck)
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

var _music_decks: Array[AudioStreamPlayer] = []
var _ambient_decks: Array[AudioStreamPlayer] = []
var _music_deck_idx: int = 0
var _ambient_deck_idx: int = 0
var _sfx_cursor: int = 0

var _music_fade_tween: Tween
var _ambient_fade_tween: Tween
var _duck_tween: Tween

# Adaptive mix state
var _dialogue_ducking: bool = false
var _emotional_silence: bool = false
var _menu_ducking: bool = false
var _cinematic_id: String = ""
var _intensity_boost_db: float = 0.0
var _duck_bus_db: float = 0.0


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
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()
	_build_players()
	load_settings()
	_apply_all_volumes()
	_preload_core_sfx()


func stop_all() -> void:
	_kill_tween(_music_fade_tween)
	_kill_tween(_ambient_fade_tween)
	_kill_tween(_duck_tween)
	_music_fade_tween = null
	_ambient_fade_tween = null
	_duck_tween = null

	for p in _music_decks:
		if p != null:
			p.stop()
			p.stream = null
	for p in _ambient_decks:
		if p != null:
			p.stop()
			p.stream = null
	for p in sfx_players:
		if p != null:
			p.stop()
			p.stream = null

	active_region_id = ""
	active_music_key = ""
	_dialogue_ducking = false
	_emotional_silence = false
	_menu_ducking = false
	_cinematic_id = ""
	_intensity_boost_db = 0.0
	_duck_bus_db = 0.0
	_set_music_duck_db(0.0)


func _exit_tree() -> void:
	stop_all()
	_stream_cache.clear()


func _kill_tween(tw: Tween) -> void:
	if tw != null and is_instance_valid(tw):
		tw.kill()


func _ensure_audio_buses() -> void:
	for bname in BUS_NAMES:
		if bname == "Master":
			continue
		if AudioServer.get_bus_index(bname) == -1:
			var idx: int = AudioServer.bus_count
			AudioServer.add_bus(idx)
			AudioServer.set_bus_name(idx, bname)
			var send_target: String = "MusicDuck" if bname == "Music" else "Master"
			AudioServer.set_bus_send(idx, send_target)
	# Ensure Music -> MusicDuck routing even if bus layout had flat send
	var mus_idx: int = AudioServer.get_bus_index("Music")
	var duck_idx: int = AudioServer.get_bus_index("MusicDuck")
	if mus_idx != -1 and duck_idx != -1 and AudioServer.get_bus_send(mus_idx) != &"MusicDuck":
		AudioServer.set_bus_send(mus_idx, &"MusicDuck")

	# Safety peak limiter on Master so layered audio never clips digitally
	var master_idx: int = AudioServer.get_bus_index("Master")
	if master_idx != -1 and AudioServer.get_bus_effect_count(master_idx) == 0:
		var limiter := AudioEffectHardLimiter.new()
		limiter.ceiling_db = -1.0
		limiter.release = 0.1
		AudioServer.add_bus_effect(master_idx, limiter)


func _build_players() -> void:
	if _music_decks.is_empty():
		for i in range(2):
			var mp := AudioStreamPlayer.new()
			mp.name = "MusicPlayer" if i == 0 else "MusicPlayerAlt"
			mp.bus = &"Music"
			mp.volume_db = MUSIC_BASE_DB
			add_child(mp)
			_music_decks.append(mp)
		music_player = _music_decks[0]

	if _ambient_decks.is_empty():
		for i in range(2):
			var ap := AudioStreamPlayer.new()
			ap.name = "AmbientPlayer" if i == 0 else "AmbientPlayerAlt"
			ap.bus = &"Ambient"
			ap.volume_db = AMBIENT_BASE_DB
			add_child(ap)
			_ambient_decks.append(ap)
		ambient_player = _ambient_decks[0]

	if sfx_players.is_empty():
		for i in range(6):
			var p := AudioStreamPlayer.new()
			p.name = "SfxPlayer%d" % i
			p.bus = &"SFX"
			p.volume_db = SFX_BASE_DB
			p.max_polyphony = 3
			add_child(p)
			sfx_players.append(p)


func _normalize_bus_key(bus_name: String) -> String:
	if bus_name == "Ambience":
		return "Ambient"
	return bus_name


func set_bus_linear(bus_name: String, linear_val: float) -> void:
	var key := _normalize_bus_key(bus_name)
	var clamped: float = clampf(linear_val, 0.0, 1.0)
	match key:
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
	_apply_bus_volume(key, clamped)
	if key == "SFX":
		_apply_bus_volume("Cinematic", clamped)


func get_bus_linear(bus_name: String) -> float:
	var key := _normalize_bus_key(bus_name)
	match key:
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
	_apply_bus_volume("Cinematic", sfx_volume)
	_apply_bus_volume("Ambient", ambient_volume)


func _apply_bus_volume(bus_name: String, value_0_to_1: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var clamped: float = clampf(value_0_to_1, 0.0, 1.0)
	AudioServer.set_bus_mute(idx, clamped <= 0.001)
	if clamped > 0.001:
		# Squared taper spreads perceptible loudness evenly across all 10 slider steps
		AudioServer.set_bus_volume_linear(idx, clamped * clamped)


func play_region_ambience(region_id: String, crossfade_s: float = 1.8) -> void:
	if region_id == "":
		return
	_ensure_audio_buses()
	_build_players()

	if region_id == active_region_id and active_music_key != "":
		return

	active_region_id = region_id
	var amb_stream := _get_ambience_stream(region_id)
	var mus_key := region_id
	if _cinematic_id == "last_bell_climax":
		mus_key = "great_bell_climax"
	var mus_stream := _get_music_stream(mus_key)
	var can_play: bool = (DisplayServer.get_name() != "headless")

	_crossfade_ambient(amb_stream, minf(crossfade_s, 1.4), can_play)
	if mus_key != active_music_key or music_player == null or (can_play and not music_player.playing):
		active_music_key = mus_key
		_crossfade_music(mus_stream, crossfade_s, can_play)


func transition_music_track(music_key: String, crossfade_s: float = 1.8) -> void:
	if music_key == "" or music_key == active_music_key:
		return
	_ensure_audio_buses()
	_build_players()
	active_music_key = music_key
	var mus_stream := _get_music_stream(music_key)
	var can_play: bool = (DisplayServer.get_name() != "headless")
	_crossfade_music(mus_stream, crossfade_s, can_play)


func _crossfade_music(stream: AudioStream, secs: float, can_play: bool) -> void:
	if _music_decks.size() < 2:
		return
	var old_deck: AudioStreamPlayer = _music_decks[_music_deck_idx]
	_music_deck_idx = 1 - _music_deck_idx
	var new_deck: AudioStreamPlayer = _music_decks[_music_deck_idx]
	music_player = new_deck

	new_deck.stream = stream
	_kill_tween(_music_fade_tween)

	if not can_play:
		old_deck.stop()
		new_deck.volume_db = MUSIC_BASE_DB
		return

	if not old_deck.playing or secs <= 0.05:
		old_deck.stop()
		new_deck.volume_db = MUSIC_BASE_DB if not old_deck.playing else -36.0
		new_deck.play()
		if old_deck.playing:
			pass
		else:
			# Gentle fade-in on fresh startup so music swells in warmly
			new_deck.volume_db = -24.0
			_music_fade_tween = create_tween()
			_music_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			_music_fade_tween.tween_property(new_deck, "volume_db", MUSIC_BASE_DB, minf(1.2, maxf(0.4, secs)))
		return

	new_deck.volume_db = -40.0
	new_deck.play()
	_music_fade_tween = create_tween()
	_music_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_fade_tween.set_parallel(true)
	_music_fade_tween.tween_property(old_deck, "volume_db", -42.0, secs)
	_music_fade_tween.tween_property(new_deck, "volume_db", MUSIC_BASE_DB, secs)
	_music_fade_tween.chain().tween_callback(old_deck.stop)


func _crossfade_ambient(stream: AudioStream, secs: float, can_play: bool) -> void:
	if _ambient_decks.size() < 2:
		return
	var old_deck: AudioStreamPlayer = _ambient_decks[_ambient_deck_idx]
	_ambient_deck_idx = 1 - _ambient_deck_idx
	var new_deck: AudioStreamPlayer = _ambient_decks[_ambient_deck_idx]
	ambient_player = new_deck

	new_deck.stream = stream
	_kill_tween(_ambient_fade_tween)

	if not can_play:
		old_deck.stop()
		new_deck.volume_db = AMBIENT_BASE_DB
		return

	if not old_deck.playing or secs <= 0.05:
		old_deck.stop()
		new_deck.volume_db = -28.0
		new_deck.play()
		_ambient_fade_tween = create_tween()
		_ambient_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_ambient_fade_tween.tween_property(new_deck, "volume_db", AMBIENT_BASE_DB, 1.0)
		return

	new_deck.volume_db = -40.0
	new_deck.play()
	_ambient_fade_tween = create_tween()
	_ambient_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_ambient_fade_tween.set_parallel(true)
	_ambient_fade_tween.tween_property(old_deck, "volume_db", -42.0, secs)
	_ambient_fade_tween.tween_property(new_deck, "volume_db", AMBIENT_BASE_DB, secs)
	_ambient_fade_tween.chain().tween_callback(old_deck.stop)


func set_dialogue_ducking(active: bool, emotional_silence: bool = false) -> void:
	_dialogue_ducking = active
	_emotional_silence = active and emotional_silence
	_refresh_ducking(0.55 if _emotional_silence else (0.30 if active else 0.85))


func set_menu_ducking(active: bool) -> void:
	_menu_ducking = active
	_refresh_ducking(0.25)


func set_cinematic_context(cinematic_id: String, active: bool) -> void:
	_cinematic_id = cinematic_id if active else ""
	if active:
		if cinematic_id == "last_bell_climax":
			transition_music_track("great_bell_climax", 1.6)
		elif cinematic_id in ["elena_final_message", "dawnspire_elena_journal", "prologue_thirteenth_bell"]:
			_emotional_silence = true
	else:
		_emotional_silence = false
		if active_region_id == "great_bell" and active_music_key == "great_bell_climax":
			# Climax transitions calmly back only when storm resolves or epilogue begins; keep energy if unfinished
			pass
	_refresh_ducking(0.50)


func sync_quest_music_state(quest_manager: Node) -> void:
	if quest_manager == null:
		return
	var region_now := active_region_id
	if region_now == "great_bell":
		var storm_done: bool = bool(quest_manager.get("storm_resolved"))
		var epi_done: bool = bool(quest_manager.get("epilogue_completed"))
		var terrace_ret: bool = bool(quest_manager.get("dawn_terrace_returned"))
		var binding_sev: bool = bool(quest_manager.get("binding_severed"))
		var net_stab: bool = bool(quest_manager.get("protective_network_stabilized"))
		var conduits_lit: int = quest_manager.get_activated_beacon_conduit_count() if quest_manager.has_method("get_activated_beacon_conduit_count") else 0

		if storm_done or epi_done or terrace_ret:
			_intensity_boost_db = 0.0
			transition_music_track("epilogue_dawn", 2.2)
		elif binding_sev:
			_intensity_boost_db = 1.5
			transition_music_track("great_bell_climax", 1.5)
		elif net_stab or conduits_lit >= 2:
			_intensity_boost_db = 1.2
			if active_music_key == "":
				transition_music_track("great_bell", 1.6)
		else:
			_intensity_boost_db = float(conduits_lit) * 0.4
	else:
		_intensity_boost_db = 0.0
	_refresh_ducking(0.65)


func _refresh_ducking(fade_s: float = 0.4) -> void:
	var target_db: float = _intensity_boost_db
	if _emotional_silence:
		target_db = minf(target_db, -10.5)
	elif _dialogue_ducking:
		target_db -= 4.2
	if _menu_ducking:
		target_db -= 3.8
	if _cinematic_id in ["briarwood_first_beacon", "floodmill_beacon_awakens", "ironwatch_beacon_awakens", "dawnspire_beacons_synchronized", "dawnspire_observatory_activated"]:
		target_db = maxf(target_db, 1.0)
	target_db = clampf(target_db, -16.0, 2.0)

	if not is_inside_tree():
		_duck_bus_db = target_db
		_set_music_duck_db(target_db)
		return

	_kill_tween(_duck_tween)
	_duck_tween = create_tween()
	_duck_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var start_db := _duck_bus_db
	_duck_tween.tween_method(func(val: float) -> void:
		_duck_bus_db = val
		_set_music_duck_db(val)
	, start_db, target_db, maxf(0.05, fade_s))


func _set_music_duck_db(db: float) -> void:
	var idx: int = AudioServer.get_bus_index("MusicDuck")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, db)


func play_sfx(sfx_id: String) -> void:
	last_played_sfx = sfx_id
	_ensure_audio_buses()
	_build_players()
	if sfx_players.is_empty():
		return
	var p: AudioStreamPlayer = sfx_players[_sfx_cursor % sfx_players.size()]
	_sfx_cursor += 1
	p.stream = _get_sfx_stream(sfx_id)
	if sfx_id in CINEMATIC_SFX_IDS:
		p.bus = &"Cinematic"
		p.volume_db = CINEMATIC_BASE_DB
	else:
		p.bus = &"SFX"
		p.volume_db = SFX_BASE_DB
	p.pitch_scale = 1.0 if sfx_id == "footstep" else randf_range(0.985, 1.015)
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


func _preload_core_sfx() -> void:
	for sid in ["footstep", "dialogue_open", "item_pickup", "save_game"]:
		_get_sfx_stream(sid)


func _get_music_stream(region_or_key: String) -> AudioStream:
	var cache_key := "mus_" + region_or_key
	if _stream_cache.has(cache_key):
		return _stream_cache[cache_key]
	var path: String = REGION_MUSIC_PATHS.get(region_or_key, REGION_MUSIC_PATHS["bellhaven"])
	if ResourceLoader.exists(path):
		var res := ResourceLoader.load(path)
		if res is AudioStream:
			if res is AudioStreamOggVorbis:
				res.loop = true
			_stream_cache[cache_key] = res
			return res
	var fb := _make_gentle_fallback_wav(true)
	_stream_cache[cache_key] = fb
	return fb


func _get_ambience_stream(region_id: String) -> AudioStream:
	var cache_key := "amb_" + region_id
	if _stream_cache.has(cache_key):
		return _stream_cache[cache_key]
	var path: String = REGION_AMBIENCE_PATHS.get(region_id, REGION_AMBIENCE_PATHS["bellhaven"])
	if ResourceLoader.exists(path):
		var res := ResourceLoader.load(path)
		if res is AudioStream:
			if res is AudioStreamOggVorbis:
				res.loop = true
			_stream_cache[cache_key] = res
			return res
	var fb := _make_gentle_fallback_wav(false)
	_stream_cache[cache_key] = fb
	return fb


func _get_sfx_stream(sfx_id: String) -> AudioStream:
	var cache_key := "sfx_" + sfx_id
	if _stream_cache.has(cache_key):
		return _stream_cache[cache_key]

	if sfx_id == "footstep":
		var rnd := AudioStreamRandomizer.new()
		rnd.random_pitch = 1.06
		rnd.random_volume_offset_db = 1.5
		for v in range(3):
			var p_step := "res://assets/audio/sfx/sfx_footstep_%d.wav" % v
			if ResourceLoader.exists(p_step):
				var s := ResourceLoader.load(p_step)
				if s is AudioStream:
					rnd.add_stream(-1, s)
		if rnd.streams_count > 0:
			_stream_cache[cache_key] = rnd
			return rnd

	var path := "res://assets/audio/sfx/sfx_%s.wav" % sfx_id
	if ResourceLoader.exists(path):
		var res := ResourceLoader.load(path)
		if res is AudioStream:
			_stream_cache[cache_key] = res
			return res

	var fb := _make_gentle_fallback_wav(false)
	_stream_cache[cache_key] = fb
	return fb


func _make_gentle_fallback_wav(is_loop: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	var count := int(0.5 * SAMPLE_RATE) if is_loop else int(0.1 * SAMPLE_RATE)
	var buf := PackedByteArray()
	buf.resize(count * 2)
	wav.data = buf
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD if is_loop else AudioStreamWAV.LOOP_DISABLED
	wav.loop_begin = 0
	wav.loop_end = count
	return wav


func verify_all_assets_loadable() -> Dictionary:
	var missing: Array[String] = []
	var loaded_count: int = 0
	for k in REGION_MUSIC_PATHS.keys():
		var p: String = REGION_MUSIC_PATHS[k]
		if ResourceLoader.exists(p) and ResourceLoader.load(p) is AudioStream:
			loaded_count += 1
		else:
			missing.append(p)
	for k in REGION_AMBIENCE_PATHS.keys():
		var p: String = REGION_AMBIENCE_PATHS[k]
		if ResourceLoader.exists(p) and ResourceLoader.load(p) is AudioStream:
			loaded_count += 1
		else:
			missing.append(p)
	for v in range(3):
		var ps := "res://assets/audio/sfx/sfx_footstep_%d.wav" % v
		if ResourceLoader.exists(ps) and ResourceLoader.load(ps) is AudioStream:
			loaded_count += 1
		else:
			missing.append(ps)
	var all_sfx := [
		"dialogue_open", "item_pickup", "puzzle_solve", "save_game",
		"beacon_activate", "chapter_complete", "bell_toll", "mountain_wind",
		"distant_thunder", "stone_movement", "bridge_mechanism", "observatory_activate",
		"celestial_align", "sanctuary_awaken", "great_bell_resonance", "memory_fragment",
		"conduit_align", "ritual_stabilize", "binding_sever", "storm_recede", "dawn_chord",
	]
	for sid in all_sfx:
		var ps := "res://assets/audio/sfx/sfx_%s.wav" % sid
		if ResourceLoader.exists(ps) and ResourceLoader.load(ps) is AudioStream:
			loaded_count += 1
		else:
			missing.append(ps)
	return {"loaded": loaded_count, "missing": missing}

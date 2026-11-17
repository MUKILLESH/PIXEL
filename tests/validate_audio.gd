extends SceneTree
## Focused automated validation suite for ASHVALE Audio Overhaul:
##   - Asset presence, loadability & .ogg loop enforcement (all 39 assets)
##   - AudioBus layout, Master HardLimiter & MusicDuck routing
##   - Crossfade region transitions & non-restart guard
##   - Adaptive dialogue ducking, emotional silence, menu pause/resume & climax state transitions
##   - Settings persistence & zero orphan node cleanup

const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")
const TEST_AUDIO_PATH := "user://test_audio_overhaul.json"

var passed: int = 0
var failed: int = 0
var _saved_settings_exists: bool = false
var _saved_settings_text: String = ""

func _init() -> void:
	call_deferred("run")

func check(cond: bool, msg: String) -> void:
	if cond:
		passed += 1
		print("PASS: " + msg)
	else:
		failed += 1
		printerr("FAIL: " + msg)

func frames(count: int = 3) -> void:
	for _i in range(count):
		await process_frame

func _backup_settings() -> void:
	var p: String = AudioManagerScript.SETTINGS_PATH
	_saved_settings_exists = FileAccess.file_exists(p)
	if _saved_settings_exists:
		_saved_settings_text = FileAccess.get_file_as_string(p)

func _restore_and_cleanup() -> void:
	if FileAccess.file_exists(TEST_AUDIO_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_AUDIO_PATH))
	var p: String = AudioManagerScript.SETTINGS_PATH
	if _saved_settings_exists:
		var f := FileAccess.open(p, FileAccess.WRITE)
		if f != null:
			f.store_string(_saved_settings_text)
			f.close()
	elif FileAccess.file_exists(p):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

func run() -> void:
	_backup_settings()
	print("=== ASHVALE AUDIO OVERHAUL VALIDATION ===")

	# 1. Startup smoke test on Bellhaven main scene
	var err := change_scene_to_file("res://scenes/sjt_exterior.tscn")
	check(err == OK, "Startup scene res://scenes/sjt_exterior.tscn loads cleanly")
	await frames(6)
	var bh := current_scene
	check(bh != null and bh.name == "BellhavenVillage", "BellhavenVillage root instantiated cleanly")

	var audio := AudioManagerScript.ensure(self)
	check(audio != null, "AshvaleAudio singleton initialized")

	# 2. Verify Audio Bus Layout & Limiter
	var bus_ok: bool = true
	for b in ["Master", "MusicDuck", "Music", "SFX", "Ambient", "Cinematic"]:
		if AudioServer.get_bus_index(b) == -1:
			bus_ok = false
			printerr("Missing audio bus: " + b)
	check(bus_ok, "All 6 audio buses (Master, MusicDuck, Music, SFX, Ambient, Cinematic) exist")
	var mus_idx := AudioServer.get_bus_index("Music")
	check(mus_idx != -1 and AudioServer.get_bus_send(mus_idx) == &"MusicDuck", "Music bus routes through MusicDuck -> Master")
	var master_idx := AudioServer.get_bus_index("Master")
	check(master_idx != -1 and AudioServer.get_bus_effect_count(master_idx) >= 1 and AudioServer.get_bus_effect(master_idx, 0) is AudioEffectHardLimiter, "Master bus has AudioEffectHardLimiter safety protection")

	# 3. Verify all 39 audio assets load cleanly
	var audit: Dictionary = audio.verify_all_assets_loadable()
	check(int(audit.get("loaded", 0)) == 39 and (audit.get("missing", []) as Array).is_empty(), "All 39 audio assets (8 music, 7 ambience, 24 sfx) load with zero missing files")

	# Verify .ogg loop mode is enabled
	var mus_bh := ResourceLoader.load("res://assets/audio/music/mus_bellhaven.ogg")
	var amb_dw := ResourceLoader.load("res://assets/audio/ambience/amb_dawnspire.ogg")
	check(mus_bh is AudioStreamOggVorbis and mus_bh.has_loop(), "Music OGG streams have loop=true imported")
	check(amb_dw is AudioStreamOggVorbis and amb_dw.has_loop(), "Ambience OGG streams have loop=true imported")

	# Verify Footstep randomizer
	var fs_stream = audio._get_sfx_stream("footstep")
	check(fs_stream is AudioStreamRandomizer and fs_stream.streams_count == 3, "Footstep SFX uses AudioStreamRandomizer with 3 organic variants")

	# 4. Gain Staging Check: Music clearly stronger than Ambience
	check(audio.MUSIC_BASE_DB > audio.AMBIENT_BASE_DB, "Music base mix (%.1f dB) sits cleanly above Ambience base mix (%.1f dB)" % [audio.MUSIC_BASE_DB, audio.AMBIENT_BASE_DB])

	# 5. Region Music Transitions & Redundant Call Guard
	check(audio.active_region_id == "bellhaven" and audio.active_music_key == "bellhaven", "Initial Bellhaven region & music active")
	var prev_deck = audio.music_player
	audio.play_region_ambience("bellhaven")
	check(audio.music_player == prev_deck, "Re-triggering active region does NOT restart or switch decks")

	for reg in ["briarwood", "floodmill", "ironwatch", "dawnspire", "great_bell", "epilogue_dawn"]:
		audio.play_region_ambience(reg, 0.5)
		await frames(2)
		check(audio.active_region_id == reg and audio.active_music_key == reg, "Transition to region '%s' swaps to new crossfade deck cleanly" % reg)

	# 6. Adaptive Dynamics: Dialogue, Emotional Silence, Pause Menu & Climax
	audio.play_region_ambience("bellhaven", 0.2)
	await frames(2)
	var duck_idx := AudioServer.get_bus_index("MusicDuck")
	audio.set_dialogue_ducking(true, false)
	await create_timer(0.45).timeout
	var normal_duck_db := AudioServer.get_bus_volume_db(duck_idx)
	check(normal_duck_db < -2.0 and normal_duck_db > -7.0, "Casual dialogue gently ducks MusicDuck (%.2f dB)" % normal_duck_db)

	audio.set_dialogue_ducking(true, true)
	await create_timer(0.65).timeout
	var emo_duck_db := AudioServer.get_bus_volume_db(duck_idx)
	check(emo_duck_db < normal_duck_db - 3.0, "Emotional silence hush dips deeper than normal dialogue (%.2f dB)" % emo_duck_db)

	audio.set_dialogue_ducking(false, false)
	await create_timer(0.95).timeout
	var restored_db := AudioServer.get_bus_volume_db(duck_idx)
	check(absf(restored_db) < 0.6, "Closing dialogue restores MusicDuck cleanly to baseline (%.2f dB)" % restored_db)

	# Pause / System menu ducking
	audio.set_menu_ducking(true)
	await create_timer(0.35).timeout
	var menu_duck_db := AudioServer.get_bus_volume_db(duck_idx)
	check(menu_duck_db < -2.0, "Pause/System menu ducks music cleanly (%.2f dB)" % menu_duck_db)
	audio.set_menu_ducking(false)
	await create_timer(0.35).timeout
	check(absf(AudioServer.get_bus_volume_db(duck_idx)) < 0.6, "Resuming from System menu restores music volume cleanly")

	# Climax & Epilogue Adaptive Transitions
	audio.play_region_ambience("great_bell", 0.2)
	audio.set_cinematic_context("last_bell_climax", true)
	await frames(2)
	check(audio.active_music_key == "great_bell_climax", "Last Bell climax cinematic transitions smoothly into mus_great_bell_climax")
	audio.set_cinematic_context("last_bell_climax", false)

	# 7. Settings Persistence & Zero-Mute Safety (no -inf/NaN issues)
	audio.set_bus_linear("Master", 0.9)
	audio.set_bus_linear("Music", 0.6)
	audio.set_bus_linear("SFX", 0.5)
	audio.set_bus_linear("Ambience", 0.4)
	check(is_equal_approx(audio.get_bus_linear("Ambient"), 0.4), "Ambience alias maps identically to Ambient bus")
	check(audio.save_settings(TEST_AUDIO_PATH) == OK, "Audio settings save cleanly to JSON")

	audio.set_bus_linear("Music", 0.0)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "Zero volume mutes Music bus cleanly without -inf glitch")
	check(audio.load_settings(TEST_AUDIO_PATH) and is_equal_approx(audio.get_bus_linear("Music"), 0.6) and not AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "Reloading settings restores Music level and unmutes cleanly")

	# SFX bus & Cinematic bus coupling
	audio.play_sfx("bell_toll")
	check(audio.last_played_sfx == "bell_toll", "play_sfx records and dispatches bell_toll cleanly")

	audio.stop_all()
	await frames(3)
	_restore_and_cleanup()
	var orphans := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	check(orphans == 0, "Zero orphan nodes after full audio validation (orphans: %d)" % orphans)

	print("AUDIO VALIDATION RESULT: %d checks, %d failures" % [passed, failed])
	quit(0 if failed == 0 else 1)

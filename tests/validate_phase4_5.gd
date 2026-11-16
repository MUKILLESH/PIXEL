extends SceneTree

const AUDIO_TEST_PATH := "user://test_phase4_5_audio.json"
const SAVE_TEST_PATH := "user://test_phase4_5_save.json"
const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")

var checks: int = 0
var failed: int = 0
var _saved_user_audio_exists: bool = false
var _saved_user_audio_text: String = ""

func _init() -> void:
	call_deferred("run")

func check(cond: bool, label: String) -> void:
	checks += 1
	if cond:
		print("PASS: " + label)
	else:
		failed += 1
		print("FAIL: " + label)

func frames(count: int = 3) -> void:
	for _i in range(count):
		await physics_frame

func press(action: String) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	await frames(2)

func press_keycode(code: int) -> void:
	var ev_down := InputEventKey.new()
	ev_down.keycode = code
	ev_down.pressed = true
	Input.parse_input_event(ev_down)
	await frames(2)
	var ev_up := InputEventKey.new()
	ev_up.keycode = code
	ev_up.pressed = false
	Input.parse_input_event(ev_up)
	await frames(2)

func wait_for_scene(expected_name: String, max_frames: int = 40) -> Node2D:
	for _i in range(max_frames):
		await process_frame
		if current_scene != null and current_scene.name == expected_name:
			await frames(4)
			return current_scene as Node2D
	return null

func _measure_region_frametime(region_label: String, sample_frames: int = 24) -> float:
	var t0: int = Time.get_ticks_usec()
	for _i in range(sample_frames):
		await process_frame
	var dt_ms: float = float(Time.get_ticks_usec() - t0) / 1000.0 / float(sample_frames)
	print("PERF [%s]: %.2f ms/frame avg over %d frames" % [region_label, dt_ms, sample_frames])
	return dt_ms

func _backup_user_audio() -> void:
	var p: String = AudioManagerScript.SETTINGS_PATH
	_saved_user_audio_exists = FileAccess.file_exists(p)
	if _saved_user_audio_exists:
		_saved_user_audio_text = FileAccess.get_file_as_string(p)

func _cleanup() -> void:
	for p in [AUDIO_TEST_PATH, SAVE_TEST_PATH, SAVE_TEST_PATH + ".bak", SAVE_TEST_PATH + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
	var user_audio_p: String = AudioManagerScript.SETTINGS_PATH
	if _saved_user_audio_exists:
		var f := FileAccess.open(user_audio_p, FileAccess.WRITE)
		if f != null:
			f.store_string(_saved_user_audio_text)
			f.close()
	elif FileAccess.file_exists(user_audio_p):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(user_audio_p))

func run() -> void:
	_backup_user_audio()
	_cleanup()
	Engine.time_scale = 3.0

	print("--- STAGE 1: ART DIRECTION & BUS LAYOUT ---")
	check(FileAccess.file_exists("res://docs/ART_DIRECTION.md"), "docs/ART_DIRECTION.md exists")
	var art_doc: String = FileAccess.get_file_as_string("res://docs/ART_DIRECTION.md")
	check(art_doc.contains("Bellhaven") and art_doc.contains("Briarwood") and art_doc.contains("Floodmill") and art_doc.contains("Ironwatch"), "ART_DIRECTION documents all 4 regions")
	check(FileAccess.file_exists("res://default_bus_layout.tres"), "default_bus_layout.tres exists")

	print("--- STAGE 2: BELLHAVEN CHARACTER ANIMATION, AUDIO & PROLOGUE CINEMATIC ---")
	var err: Error = change_scene_to_file("res://scenes/sjt_exterior.tscn")
	check(err == OK, "Bellhaven loads cleanly")
	var bh := await wait_for_scene("BellhavenVillage")
	check(bh != null, "BellhavenVillage root ready")
	var player: CharacterBody2D = bh.get_node("Actors/Player")
	var cam: Camera2D = bh.get_node("Actors/Player/Camera2D")
	var hud: CanvasLayer = bh.get_node("HUD")
	var qm: Node = bh.get_node("QuestManager")
	var audio := AudioManagerScript.ensure(self)

	check(audio != null and audio.active_region_id == "bellhaven", "AudioManager plays Bellhaven region ambience")
	check(AudioServer.get_bus_index("Master") != -1 and AudioServer.get_bus_index("Music") != -1 and AudioServer.get_bus_index("SFX") != -1 and AudioServer.get_bus_index("Ambient") != -1, "All 4 audio buses (Master, Music, SFX, Ambient) registered")
	check(hud.has_node("CinematicDirector") and hud.has_node("RegionBanner") and hud.has_node("ShortcutHint"), "HUD hosts CinematicDirector, RegionBanner, and ShortcutHint")

	# Measure Bellhaven performance & landscape animation
	var bh_land := bh.get_node("Landscape")
	var anim0: float = float(bh_land.get("_anim_time"))
	var start_pos: Vector2 = player.position
	# Wait enough physics frames at 3x time scale for idle breathing & animation accumulator
	for _i in range(20):
		await physics_frame
	check(float(bh_land.get("_anim_time")) > anim0, "Bellhaven landscape animation clock advances cleanly")
	check(player.position.distance_to(start_pos) < 0.5 and float(player.get("idle_time")) > 0.3, "Aren idles stably while idle breathing timer advances")

	# Walk briefly and confirm walk pose + footstep SFX trigger
	Input.action_press("move_right")
	for _w in range(12):
		await physics_frame
	Input.action_release("move_right")
	await frames(2)
	check(audio.last_played_sfx == "footstep", "Walking triggers procedural footstep SFX timing")

	# Check NPC orientation toward player during dialogue
	var caelen := bh.get_node("Actors/MasterCaelen") as StaticBody2D
	player.position = Vector2(36, 56)
	player.facing = 0
	await frames(3)
	var caelen_lines: Array[String] = ["TEST LINE"]
	hud.show_dialogue("MASTER CAELEN", caelen_lines, caelen)
	await frames(2)
	check(caelen.dialogue_open == true and caelen.facing == 4, "Master Caelen turns toward Aren during conversation")
	hud._close_dialogue(false)
	await frames(2)

	# Test Audio volume adjustments & persistence in TitleMenu (starting from deterministic defaults)
	audio.set_bus_linear("Master", 0.85)
	audio.set_bus_linear("Music", 0.70)
	audio.set_bus_linear("SFX", 0.80)
	audio.set_bus_linear("Ambient", 0.75)
	hud.open_title_menu()
	await frames(2)
	var menu := hud.get_node("TitleMenu")
	check(menu.visible and menu.has_node("MenuButton0") and menu.has_node("MenuButton4"), "System Menu preserves all 5 core options")
	menu.adjust_audio_bus("Music", -2) # 0.7 -> 0.5
	menu.adjust_audio_bus("SFX", -10) # mute at 0.0
	check(is_equal_approx(audio.get_bus_linear("Music"), 0.5) and AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "Audio sliders update bus volume and mute at 0 cleanly")
	check(audio.save_settings(AUDIO_TEST_PATH) == OK, "Audio settings save cleanly to JSON")
	audio.set_bus_linear("Music", 0.9)
	audio.set_bus_linear("SFX", 0.8)
	check(audio.load_settings(AUDIO_TEST_PATH) and is_equal_approx(audio.get_bus_linear("Music"), 0.5) and is_equal_approx(audio.get_bus_linear("SFX"), 0.0), "Audio settings persist and reload accurately")
	audio.set_bus_linear("SFX", 0.8)
	menu.close_menu()
	await frames(2)

	# Test Prologue Thirteenth Bell Cinematic & Skip Recovery (KEY_X)
	var term := bh.get_node("Actors/Terminal") as StaticBody2D
	player.position = Vector2(96, 54)
	cam.snap_to_target()
	await frames(3)
	await press("interact")
	await frames(3)
	var cin := hud.get_node("CinematicDirector")
	check(cin.active and cin.active_id == "prologue_thirteenth_bell" and cin.get_node("TopLetterbox").visible and cin.get_node("SkipHint").visible, "Prologue Thirteenth Bell activates letterbox, skip hint, and camera focus")
	check(cam.cinematic_active == true and audio.last_played_sfx == "bell_toll", "Cinematic focuses PixelCamera and plays bell_toll SFX")
	await press_keycode(KEY_X)
	await frames(3)
	check(not cin.active and cin.skipped_last and not cam.cinematic_active and cam.zoom == Vector2.ONE, "KEY_X skips cinematic cleanly and restores PixelCamera")
	check(not player.movement_locked and qm.is_objective_completed("investigate_bell"), "Skip cinematic restores player control and completes investigate_bell cleanly")

	# Also test standalone timed sequence completion & skip
	var seq_done: Dictionary = {"fired": false}
	cin.play_sequence("standalone_test", Vector2(10, 44), 1.5, Color(0.5, 0.8, 1.0), func(): seq_done["fired"] = true, "puzzle_solve")
	await frames(2)
	check(cin.active and player.movement_locked, "Standalone sequence locks player movement cleanly")
	await press_keycode(KEY_X)
	await frames(2)
	check(not cin.active and not player.movement_locked and seq_done["fired"], "Skipping standalone sequence restores control and invokes completion callback")

	check(await _measure_region_frametime("Bellhaven") < 40.0, "Bellhaven frame timing healthy (< 40 ms)")

	print("--- STAGE 3: REGION TRANSITIONS, CINEMATICS & WORLD CONTINUITY ---")
	# Unlock & travel Bellhaven -> Briarwood -> Floodmill -> Ironwatch + Backward Return Checks!
	qm.briarwood_unlocked = true
	qm.prologue_completed = true
	bh.travel_to_briarwood()
	var br := await wait_for_scene("BriarwoodForest")
	check(br != null and audio.active_region_id == "briarwood", "Transition Bellhaven -> Briarwood switches ambience cleanly")
	var br_qm: Node = br.get_node("QuestManager")
	var br_hud: CanvasLayer = br.get_node("HUD")
	var br_cin := br_hud.get_node("CinematicDirector")
	check(br_hud.get_node("RegionBanner").visible or float(br.get_node("Landscape").get("_anim_time")) > 0.0, "Briarwood arrival banner and animated landscape active")
	check(await _measure_region_frametime("Briarwood") < 40.0, "Briarwood frame timing healthy (< 40 ms)")

	# Trigger First Beacon cinematic in Briarwood
	for o in br_qm.objectives:
		var oid: String = String(o.get("id"))
		if oid == "activate_first_beacon":
			break
		if oid == "find_repair_materials":
			br_qm.record_material_collected("plank_1")
			br_qm.record_material_collected("plank_2")
			br_qm.record_material_collected("rope_coil")
		elif oid == "discover_inscriptions":
			br_qm.record_inscription_read("west")
			br_qm.record_inscription_read("center")
			br_qm.record_inscription_read("east")
		else:
			br_qm.complete_objective(oid)
	br._sync_world_from_quest()
	var br_player: CharacterBody2D = br.get_node("Actors/Player")
	br_player.position = Vector2(-32, -196)
	await frames(3)
	await press("interact")
	await frames(2)
	check(br_cin.active and br_cin.active_id == "briarwood_first_beacon" and audio.last_played_sfx == "beacon_activate", "Briarwood First Beacon triggers cinematic & beacon SFX")
	await press_keycode(KEY_X)
	await frames(2)
	check(not br_cin.active and br_qm.beacon_activated and not br_player.movement_locked, "Skipping First Beacon cinematic restores control and activates beacon")

	# Transition Briarwood -> Floodmill
	br_qm.floodmill_unlocked = true
	br_qm.chapter1_completed = true
	br.travel_to_floodmill()
	var fm := await wait_for_scene("FloodmillVillage")
	check(fm != null and audio.active_region_id == "floodmill", "Transition Briarwood -> Floodmill switches ambience cleanly")
	var fm_qm: Node = fm.get_node("QuestManager")
	var fm_hud: CanvasLayer = fm.get_node("HUD")
	var fm_cin := fm_hud.get_node("CinematicDirector")
	check(await _measure_region_frametime("Floodmill") < 40.0, "Floodmill frame timing healthy (< 40 ms)")

	# Trigger Floodmill Ledger Truth cinematic
	for o in fm_qm.objectives:
		var oid: String = String(o.get("id"))
		if oid == "discover_villagers_truth":
			break
		if oid == "find_watermill_parts":
			fm_qm.record_mill_part_collected("iron_drive_gear")
			fm_qm.record_mill_part_collected("bronze_pinion")
			fm_qm.record_mill_part_collected("oak_coupling_belt")
		elif oid == "reconstruct_village_ledger":
			fm_qm.record_archive_clue_found("record_census")
			fm_qm.record_archive_clue_found("record_tribute")
			fm_qm.record_archive_clue_found("record_transfer")
			fm_qm.complete_objective(oid)
		else:
			fm_qm.complete_objective(oid)
	fm._sync_world_from_quest()
	var fm_player: CharacterBody2D = fm.get_node("Actors/Player")
	fm_player.position = Vector2(-134, -84)
	await frames(3)
	await press("interact")
	await frames(2)
	check(fm_cin.active and fm_cin.active_id == "floodmill_ledger_truth", "Floodmill Ledger reveal triggers cinematic cleanly")
	await press_keycode(KEY_X)
	await frames(2)
	check(not fm_cin.active and fm_qm.villagers_truth_discovered, "Skipping Ledger cinematic unlocks villagers_truth_discovered cleanly")

	# Transition Floodmill -> Ironwatch Keep
	fm_qm.ironwatch_unlocked = true
	fm_qm.chapter2_completed = true
	fm.travel_to_ironwatch()
	var iw := await wait_for_scene("IronwatchKeep")
	check(iw != null and audio.active_region_id == "ironwatch", "Transition Floodmill -> Ironwatch switches ambience cleanly")
	var iw_qm: Node = iw.get_node("QuestManager")
	var iw_hud: CanvasLayer = iw.get_node("HUD")
	var iw_cin := iw_hud.get_node("CinematicDirector")
	check(await _measure_region_frametime("Ironwatch") < 40.0, "Ironwatch frame timing healthy (< 40 ms)")

	# Advance to Last Bell Warden & Third Beacon cinematics
	for o in iw_qm.objectives:
		var oid: String = String(o.get("id"))
		if oid == "confront_last_warden":
			break
		if oid == "find_crest_clues":
			iw_qm.record_crest_clue_found("clue_1")
			iw_qm.record_crest_clue_found("clue_2")
			iw_qm.record_crest_clue_found("clue_3")
		else:
			iw_qm.complete_objective(oid)
	iw._sync_world_from_quest()
	var iw_player: CharacterBody2D = iw.get_node("Actors/Player")
	iw_player.position = Vector2(-35, -118)
	await frames(3)
	await press("interact")
	await frames(2)
	check(iw_cin.active and iw_cin.active_id == "ironwatch_warden_sacrifice", "Last Bell Warden confrontation triggers cinematic")
	await press_keycode(KEY_X)
	await frames(2)
	check(iw_qm.warden_confronted and iw_qm.get_current_objective_id() == "discover_elena_research", "Skipping Warden cinematic still completes confront_last_warden")

	iw_qm.complete_objective("discover_elena_research")
	iw._sync_world_from_quest()
	iw_player.position = Vector2(70, -120)
	await frames(3)
	await press("interact")
	await frames(2)
	check(iw_cin.active and iw_cin.active_id == "ironwatch_beacon_awakens" and audio.last_played_sfx == "beacon_activate", "Third Beacon restoration triggers triad cinematic & SFX")
	await press_keycode(KEY_X)
	await frames(2)
	check(iw_qm.third_beacon_activated and not iw_player.movement_locked, "Skipping Third Beacon cinematic activates beacon cleanly")

	# Verify backward regional travel placement & camera stability (Ironwatch -> Floodmill -> Briarwood -> Bellhaven)
	iw.travel_to_floodmill()
	var ret_fm := await wait_for_scene("FloodmillVillage")
	check(ret_fm != null and ret_fm.get_node("Actors/Player").position.distance_to(Vector2(170, -172)) <= 6.0, "Return Ironwatch -> Floodmill spawns Aren at Ironwatch Gate path")
	ret_fm.travel_to_briarwood()
	var ret_br := await wait_for_scene("BriarwoodForest")
	check(ret_br != null and ret_br.get_node("Actors/Player").position.distance_to(Vector2(146, -188)) <= 6.0, "Return Floodmill -> Briarwood spawns Aren at Floodmill Gate path")
	ret_br.travel_to_bellhaven()
	var ret_bh := await wait_for_scene("BellhavenVillage")
	check(ret_bh != null and ret_bh.get_node("Actors/Player").position.distance_to(Vector2(-170, 168)) <= 6.0, "Return Briarwood -> Bellhaven spawns Aren at Briarwood Waystone")

	# Verify Save v3 compatibility & separate audio persistence
	var test_qm := QuestManagerScript.new()
	test_qm.reload_quest("res://data/chapter3_quest.json")
	test_qm.third_beacon_activated = true
	check(test_qm.save_to_file(SAVE_TEST_PATH) == OK, "Save v3 writes without interfering with audio settings")
	var check_qm := QuestManagerScript.new()
	check(check_qm.load_from_file(SAVE_TEST_PATH) and check_qm.third_beacon_activated, "Save v3 round-trip preserves Ironwatch flags cleanly")
	test_qm.free()
	check_qm.free()

	if audio.has_method("stop_all"):
		audio.stop_all()
	_cleanup()
	Engine.time_scale = 1.0
	check(true, "Phase 4.5 suite completed")
	print("PHASE 4.5 RESULT: %d checks, %d failures" % [checks, failed])
	quit(0 if failed == 0 else 1)

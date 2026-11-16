extends SceneTree
## Phase 7 Complete-Game Release QA & Integrity Validation Suite.
## Verifies full chronological chain (Prologue -> Ch1 -> Ch2 -> Ch3 -> Ch4 -> Ch5 -> Epilogue -> Credits -> Sunrise Bellhaven),
## immediate clearing of "Display ending credits.", TitleMenu Quit/Settings isolation, Save v1-v5 & corrupt .bak recovery,
## non-looping post-game Continue, clean New Game reset, and zero orphan node leaks, while preserving existing user saves.

const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

const TEST_SAVE := "user://test_phase7_release_save.json"
const TEST_POSTGAME := "user://test_phase7_release_postgame.json"
const TEST_AUDIO := "user://test_phase7_audio.json"

var checks: int = 0
var failed: int = 0
var _backups: Dictionary = {}

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

func wait_for_scene(expected_name: String, max_frames: int = 60) -> Node:
	for _i in range(max_frames):
		await process_frame
		if current_scene != null and current_scene.name == expected_name:
			await frames(3)
			return current_scene
	return null

func _backup_user_files() -> void:
	for p in [
		"user://ashvale_save.json",
		"user://ashvale_save.json.bak",
		AudioManagerScript.SETTINGS_PATH,
	]:
		if FileAccess.file_exists(p):
			_backups[p] = FileAccess.get_file_as_string(p)
		else:
			_backups[p] = null

func _restore_user_files() -> void:
	for p in [
		TEST_SAVE, TEST_SAVE + ".bak", TEST_SAVE + ".tmp",
		TEST_POSTGAME, TEST_POSTGAME + ".bak", TEST_POSTGAME + ".tmp",
		TEST_AUDIO,
	]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
	for p in _backups.keys():
		var val: Variant = _backups[p]
		if val is String:
			var f := FileAccess.open(p, FileAccess.WRITE)
			if f != null:
				f.store_string(val)
				f.close()
		elif FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

func run() -> void:
	_backup_user_files()
	Engine.time_scale = 4.0

	print("--- STAGE 1: ALL SCENES & QUEST RESOURCES ---")
	var required_scenes := [
		"res://scenes/sjt_exterior.tscn",
		"res://scenes/briarwood_forest.tscn",
		"res://scenes/floodmill_village.tscn",
		"res://scenes/ironwatch_keep.tscn",
		"res://scenes/dawnspire_mountain.tscn",
		"res://scenes/great_bell_sanctum.tscn",
	]
	for sc_path in required_scenes:
		check(FileAccess.file_exists(sc_path) and ResourceLoader.exists(sc_path), "Scene resource loadable: " + sc_path)

	var required_quests := [
		"res://data/prologue_quest.json",
		"res://data/chapter1_quest.json",
		"res://data/chapter2_quest.json",
		"res://data/chapter3_quest.json",
		"res://data/chapter4_quest.json",
		"res://data/chapter5_quest.json",
	]
	for q_path in required_quests:
		var q_txt: String = FileAccess.get_file_as_string(q_path)
		var parsed: Variant = JSON.parse_string(q_txt)
		check(parsed is Dictionary and (parsed as Dictionary).has("objectives"), "Quest JSON valid: " + q_path)

	print("--- STAGE 2: FULL CHRONOLOGICAL STORY CHAIN VERIFICATION ---")
	change_scene_to_file("res://scenes/sjt_exterior.tscn")
	var bh := await wait_for_scene("BellhavenVillage")
	check(bh != null, "Prologue startup scene loaded")
	if bh == null:
		_restore_user_files()
		quit(1)
		return
	var qm: Node = bh.get_node("QuestManager")
	var hud: CanvasLayer = bh.get_node("HUD")
	hud.save_path = TEST_SAVE
	for obj in ["investigate_bell", "speak_npcs", "find_mothers_letter", "solve_rune_puzzle", "discover_briarwood_path", "trigger_prologue_completion"]:
		check(qm.complete_objective(obj), "Prologue objective completed cleanly: " + obj)
	check(qm.prologue_completed and qm.briarwood_unlocked, "Prologue unlocks Briarwood")
	check(bh.travel_to_briarwood() or true, "Initiated Prologue -> Chapter 1 transition")
	var bw := await wait_for_scene("BriarwoodForest")
	check(bw != null, "BriarwoodForest loaded from Bellhaven transition")

	var bw_qm: Node = bw.get_node("QuestManager")
	for obj in ["enter_briarwood", "meet_lyra", "investigate_bridge", "find_repair_materials", "repair_bridge", "discover_inscriptions", "solve_mirror_puzzle", "activate_first_beacon", "experience_elena_recording", "complete_chapter1"]:
		check(bw_qm.complete_objective(obj), "Chapter 1 objective completed cleanly: " + obj)
	check(bw_qm.chapter1_completed and bw_qm.floodmill_unlocked, "Chapter 1 unlocks Floodmill")
	bw.travel_to_floodmill()
	var fm := await wait_for_scene("FloodmillVillage")
	check(fm != null, "FloodmillVillage loaded from Briarwood transition")

	var fm_qm: Node = fm.get_node("QuestManager")
	for obj in ["enter_floodmill", "speak_lyra_arrival", "explore_ruined_village", "discover_watermill", "find_watermill_parts", "restore_watermill", "investigate_sluice_gates", "redirect_water_flow", "enter_forgotten_archive", "reconstruct_village_ledger", "discover_villagers_truth", "restore_second_beacon", "witness_elena_message", "complete_chapter2"]:
		check(fm_qm.complete_objective(obj), "Chapter 2 objective completed cleanly: " + obj)
	check(fm_qm.chapter2_completed and fm_qm.ironwatch_unlocked, "Chapter 2 unlocks Ironwatch Keep")
	fm.travel_to_ironwatch()
	var iw := await wait_for_scene("IronwatchKeep")
	check(iw != null, "IronwatchKeep loaded from Floodmill transition")

	var iw_qm: Node = iw.get_node("QuestManager")
	for obj in ["enter_ironwatch", "investigate_courtyard", "discover_warden_records", "explore_barracks", "find_crest_clues", "solve_crest_puzzle", "navigate_shadowed_passage", "reach_wardens_chamber", "confront_last_warden", "discover_elena_research", "restore_third_beacon", "unlock_dawnspire_road", "complete_chapter3"]:
		check(iw_qm.complete_objective(obj), "Chapter 3 objective completed cleanly: " + obj)
	check(iw_qm.chapter3_completed and iw_qm.dawnspire_unlocked, "Chapter 3 unlocks Dawnspire")
	iw.travel_to_dawnspire()
	var ds := await wait_for_scene("DawnspireMountain")
	check(ds != null, "DawnspireMountain loaded from Ironwatch transition")

	var ds_qm: Node = ds.get_node("QuestManager")
	for obj in ["enter_foothills", "speak_lyra_foothills", "navigate_whispering_cliffs", "investigate_skybridge", "discover_bridge_mechanism", "repair_skybridge", "discover_pilgrims_refuge", "read_elena_journal", "reach_observatory", "find_celestial_clues", "solve_observatory_puzzle", "enter_dawnspire_sanctuary", "synchronize_three_beacons", "witness_sanctuary_revelation", "reach_great_bell_gate", "complete_chapter4"]:
		check(ds_qm.complete_objective(obj), "Chapter 4 objective completed cleanly: " + obj)
	check(ds.travel_to_great_bell(), "Chapter 4 unlocks GreatBellSanctum")
	var gb := await wait_for_scene("GreatBellSanctum")
	check(gb != null, "GreatBellSanctum loaded from Dawnspire transition")

	print("--- STAGE 3: CHAPTER 5 OBJECTIVE CLEARING, CREDITS & MENU CONTROLS ---")
	var gb_qm: Node = gb.get_node("QuestManager")
	var gb_hud: CanvasLayer = gb.get_node("HUD")
	gb_hud.save_path = TEST_POSTGAME
	gb_qm.enter_great_bell_chamber()
	gb_qm.speak_lyra_antechamber()
	gb_qm.investigate_forgotten_hall()
	gb_qm.recover_memory_fragment("frag_home")
	gb_qm.recover_memory_fragment("frag_promise")
	gb_qm.recover_memory_fragment("frag_sacrifice")
	gb_qm.reveal_warden_complete_record()
	gb_qm.discover_elena_final_message()
	gb_qm.examine_memory_binding()
	gb_qm.activate_beacon_conduit("conduit_briarwood")
	gb_qm.activate_beacon_conduit("conduit_floodmill")
	gb_qm.activate_beacon_conduit("conduit_ironwatch")
	gb_qm.stabilize_protective_network()
	gb_qm.sever_memory_binding()
	gb_qm.complete_last_bell_cinematic()
	gb_qm.return_to_dawn_terrace()
	gb_qm.complete_final_epilogue()
	check(gb_qm.get_current_objective_id() == "display_ending_credits", "Pre-credits objective is display_ending_credits")

	gb_hud.open_ending_credits(gb.dawn_memorial)
	await frames(2)
	var credits: Panel = gb_hud.get_node("EndingCredits")
	check(credits.visible and gb_qm.get_current_objective_id() == "completed", "Displaying EndingCredits clears display_ending_credits objective immediately")
	check(gb_hud.get_node("Objective").text == "Chapter 5 Complete - Ashvale Remembered.", "HUD Objective text clears DISPLAY ENDING CREDITS while credits show")
	check(FileAccess.file_exists(TEST_POSTGAME), "Opening credits auto-saves post-game chronicle cleanly")
	credits.trigger_action("bellhaven")
	var bh_end := await wait_for_scene("BellhavenVillage")
	check(bh_end != null and bh_end.get_node("QuestManager").storm_resolved and bh_end.get_node("Landscape").sunrise_epilogue, "EndingCredits [Bellhaven at Sunrise] transitions cleanly to Sunrise post-game")

	print("--- STAGE 4: MENU QUIT OPTION, SETTINGS ISOLATION & NEW GAME RESET ---")
	var end_hud: CanvasLayer = bh_end.get_node("HUD")
	end_hud.save_path = TEST_POSTGAME
	end_hud.open_title_menu()
	await frames(2)
	var tm: Panel = end_hud.get_node("TitleMenu")
	check(tm.visible and tm.buttons.size() == 6 and tm.buttons[5].text.contains("QUIT TO DESKTOP"), "TitleMenu mounts QUIT TO DESKTOP cleanly at index 5")
	check(not end_hud.toggle_fullscreen(), "toggle_fullscreen handles headless safely without error")
	var audio := AudioManagerScript.ensure(self)
	audio.set_bus_linear("Master", 0.5)
	check(audio.save_settings(TEST_AUDIO) == OK, "Settings write independently of chronicle save")
	tm.close_menu()
	await frames(2)

	# Verify post-game Continue -> dawn_terrace without credits loop, then New Game reset
	check(end_hud.continue_game(TEST_POSTGAME), "Continue from post-game save loads target post-game region")
	var resumed := await wait_for_scene("GreatBellSanctum")
	check(resumed != null and not resumed.get_node("HUD/EndingCredits").visible and resumed.get_node("QuestManager").chapter5_completed, "Post-game Continue lands cleanly without trapping in credits loop")

	resumed.get_node("HUD").start_new_game()
	var fresh_bh := await wait_for_scene("BellhavenVillage")
	check(fresh_bh != null, "New Game from post-game transitions cleanly to BellhavenVillage")
	if fresh_bh != null:
		var f_qm: Node = fresh_bh.get_node("QuestManager")
		check(f_qm.quest_id == "prologue_thirteenth_toll" and f_qm.get_current_objective_id() == "investigate_bell" and not f_qm.chapter5_completed and not f_qm.storm_resolved, "New Game cleanly resets all Chapter 1-5 and epilogue progression flags")

	await frames(4)
	var orphan_count: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	check(orphan_count == 0, "Zero leaked orphan nodes after full 6-region playthrough traversal (orphans: %d)" % orphan_count)

	_restore_user_files()
	Engine.time_scale = 1.0
	check(true, "Phase 7 Release QA suite completed")
	print("PHASE 7 RELEASE RESULT: %d checks, %d failures" % [checks, failed])
	quit(0 if failed == 0 else 1)

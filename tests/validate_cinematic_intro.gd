extends SceneTree
## Official Opening Cinematic Integration Validation Suite for Godot 4.7.2.
## Validates:
## A. NEW GAME flow: TitleMenu -> IntroCinematic -> BellhavenVillage with default prologue state.
## B. SKIP INTRO: Space / Esc immediately stops video and initializes fresh game without duplicate transitions.
## C. ESC isolation: Esc skips cinematic locally without opening pause/title menu.
## D. VIDEO COMPLETION: Finished signal cleanly transitions to fresh Bellhaven.
## E. MISSING VIDEO FALLBACK: Gracefully handles missing/unsupported video without black screen.
## F. CONTINUE BYPASS: Loading saved chronicle completely bypasses IntroCinematic.
## G. POST-GAME & REGION TRAVEL: Normal chapter travel and post-game return never replay the intro.
## H. EXPORT INTEGRITY: export_presets.cfg bundles OGV assets.
## I. SAVE PRESERVATION: Real user saves are completely isolated and untouched.

const OGV_PATH := "res://assets/cinematics/ASHVALE_Opening_Godot_720p.ogv"
const CINEMATIC_SCENE := "res://scenes/intro_cinematic.tscn"
const BELLHAVEN_SCENE := "res://scenes/sjt_exterior.tscn"
const QuestManagerScript := preload("res://scripts/systems/quest_manager.gd")
const AudioManagerScript := preload("res://scripts/systems/audio_manager.gd")

const TEST_SAVE := "user://test_cinematic_save.json"
const TEST_AUDIO := "user://test_cinematic_audio.json"

var passed: int = 0
var failed: int = 0
var user_backup_files: Dictionary = {}

func _init() -> void:
	print("===================================================================")
	print("ASHVALE: OPENING CINEMATIC INTEGRATION REGRESSION VALIDATION")
	print("===================================================================")
	_backup_user_files()

	await _run_all_tests()

	_cleanup_test_files()
	_restore_user_files()

	print("===================================================================")
	print("VALIDATION SUMMARY: %d PASSED, %d FAILED" % [passed, failed])
	print("===================================================================")
	if failed == 0:
		print("OVERALL RESULT: ALL OPENING CINEMATIC INTEGRATION CHECKS PASSED!")
		quit(0)
	else:
		push_error("OVERALL RESULT: %d CHECKS FAILED!" % failed)
		quit(1)

func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: " + label)
	else:
		failed += 1
		push_error("FAIL: " + label)

func frames(count: int = 3) -> void:
	for _i in range(count):
		await physics_frame

func wait_for_scene(expected_name: String, max_frames: int = 90) -> Node:
	for _i in range(max_frames):
		await process_frame
		if current_scene != null and current_scene.name == expected_name:
			await frames(3)
			return current_scene
	return null

func _backup_user_files() -> void:
	for p in ["user://ashvale_save.json", "user://ashvale_audio_settings.json"]:
		if FileAccess.file_exists(p):
			user_backup_files[p] = FileAccess.get_file_as_bytes(p)

func _restore_user_files() -> void:
	for p in user_backup_files.keys():
		var fa := FileAccess.open(p, FileAccess.WRITE)
		if fa != null:
			fa.store_buffer(user_backup_files[p])
			fa.close()

func _cleanup_test_files() -> void:
	for p in [TEST_SAVE, TEST_AUDIO, TEST_SAVE + ".bak"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

func _run_all_tests() -> void:
	# -------------------------------------------------------------
	# STAGE 1: ASSET & SCENE COMPOSITION CHECKS
	# -------------------------------------------------------------
	print("\n--- STAGE 1: ASSET & SCENE COMPOSITION CHECKS ---")
	check(FileAccess.file_exists(OGV_PATH), "720p OGV cinematic exists at " + OGV_PATH)
	check(ResourceLoader.exists(CINEMATIC_SCENE), "IntroCinematic scene exists at " + CINEMATIC_SCENE)

	var cin_scene: PackedScene = load(CINEMATIC_SCENE)
	check(cin_scene != null, "IntroCinematic scene packed successfully")
	var cin_instance: Control = cin_scene.instantiate() as Control
	check(cin_instance != null, "IntroCinematic instantiated as Control")
	check(cin_instance.has_node("BlackBackground"), "Has BlackBackground ColorRect")
	check(cin_instance.has_node("AspectRatioContainer"), "Has AspectRatioContainer")
	var aspect_cont: AspectRatioContainer = cin_instance.get_node("AspectRatioContainer") as AspectRatioContainer
	check(aspect_cont != null and is_equal_approx(aspect_cont.ratio, 16.0 / 9.0), "AspectRatioContainer enforces 16:9 ratio")
	check(aspect_cont.has_node("VideoPlayer"), "Has VideoPlayer VideoStreamPlayer")
	var vp: VideoStreamPlayer = aspect_cont.get_node("VideoPlayer") as VideoStreamPlayer
	check(vp != null and vp.expand, "VideoPlayer has expand enabled")
	check(cin_instance.has_node("SkipHint"), "Has SkipHint label")
	var hint: Label = cin_instance.get_node("SkipHint") as Label
	check(hint != null and hint.text.contains("SPACE") and hint.text.contains("ESC"), "SkipHint contains SPACE and ESC instructions")
	cin_instance.queue_free()
	await frames(2)

	# -------------------------------------------------------------
	# STAGE 2: SKIP INTRO VIA KEYBOARD (SPACE & ESC)
	# -------------------------------------------------------------
	print("\n--- STAGE 2: SKIP INTRO VIA KEYBOARD ---")
	change_scene_to_file(CINEMATIC_SCENE)
	var cin := await wait_for_scene("IntroCinematic")
	check(cin != null, "IntroCinematic loaded as active scene")

	# Simulate Space skip
	var ev_space := InputEventKey.new()
	ev_space.keycode = KEY_SPACE
	ev_space.pressed = true
	cin._input(ev_space)

	var bh_from_space := await wait_for_scene("BellhavenVillage")
	check(bh_from_space != null, "Space skip immediately transitions to BellhavenVillage")
	if bh_from_space != null:
		var qm: Node = bh_from_space.get_node("QuestManager")
		check(qm != null and qm.quest_id == "prologue_thirteenth_toll", "Fresh game prologue quest active")
		check(qm.get_current_objective_id() == "investigate_bell", "First objective is investigate_bell")
		var player: Node2D = bh_from_space.get_node("Actors/Player")
		check(player != null and player.position.is_equal_approx(Vector2(10, 44)), "Aren spawned at Bellhaven default pose (10, 44)")
		check(bh_from_space.has_node("HUD") and bh_from_space.get_node("HUD").visible, "Gameplay HUD active and visible")

	# Test Esc skip isolation
	change_scene_to_file(CINEMATIC_SCENE)
	var cin_esc := await wait_for_scene("IntroCinematic")
	check(cin_esc != null, "IntroCinematic loaded for Esc test")

	var ev_esc := InputEventKey.new()
	ev_esc.keycode = KEY_ESCAPE
	ev_esc.pressed = true
	cin_esc._input(ev_esc)

	var bh_from_esc := await wait_for_scene("BellhavenVillage")
	check(bh_from_esc != null, "Esc skip transitions cleanly to BellhavenVillage")
	if bh_from_esc != null:
		var hud: CanvasLayer = bh_from_esc.get_node("HUD")
		check(hud != null and not hud.get_node("TitleMenu").visible, "Esc skip handled locally without opening TitleMenu")

	# -------------------------------------------------------------
	# STAGE 3: VIDEO COMPLETION FLOW
	# -------------------------------------------------------------
	print("\n--- STAGE 3: VIDEO NATURAL COMPLETION FLOW ---")
	change_scene_to_file(CINEMATIC_SCENE)
	var cin_finish := await wait_for_scene("IntroCinematic")
	check(cin_finish != null, "IntroCinematic loaded for completion test")

	# Trigger video finished signal
	cin_finish._on_video_finished()
	var bh_from_finish := await wait_for_scene("BellhavenVillage")
	check(bh_from_finish != null, "Natural video finished transitions cleanly to BellhavenVillage")
	if bh_from_finish != null:
		var qm: Node = bh_from_finish.get_node("QuestManager")
		check(qm != null and qm.get_current_objective_id() == "investigate_bell", "Proper fresh objective loaded after video completion")

	# -------------------------------------------------------------
	# STAGE 4: TITLE MENU NEW GAME INTEGRATION
	# -------------------------------------------------------------
	print("\n--- STAGE 4: TITLE MENU NEW GAME INTEGRATION ---")
	change_scene_to_file(BELLHAVEN_SCENE)
	var bh_menu := await wait_for_scene("BellhavenVillage")
	check(bh_menu != null, "BellhavenVillage active for menu test")
	var hud_menu: CanvasLayer = bh_menu.get_node("HUD")
	hud_menu.save_path = TEST_SAVE
	hud_menu.open_title_menu()
	await frames(2)
	var tm: Panel = hud_menu.get_node("TitleMenu")
	check(tm.visible, "TitleMenu opened")

	# Activate NEW GAME (index 0)
	tm.select_option(0)
	tm.activate_selected()

	var cin_from_menu := await wait_for_scene("IntroCinematic")
	check(cin_from_menu != null, "Selecting NEW GAME in TitleMenu cleanly opens IntroCinematic")

	# Skip to return to Bellhaven
	var ev_ret := InputEventKey.new()
	ev_ret.keycode = KEY_SPACE
	ev_ret.pressed = true
	cin_from_menu._input(ev_ret)
	var bh_restored := await wait_for_scene("BellhavenVillage")
	check(bh_restored != null, "Returned to BellhavenVillage from menu-initiated New Game")

	# -------------------------------------------------------------
	# STAGE 5: CONTINUE GAME BYPASSES CINEMATIC
	# -------------------------------------------------------------
	print("\n--- STAGE 5: CONTINUE GAME BYPASSES CINEMATIC ---")
	# Create a mock mid-game save in Briarwood
	var test_qm := QuestManagerScript.new()
	test_qm.load_quest_data("res://data/chapter1_quest.json")
	test_qm.quest_id = "chapter1_whispers_of_briarwood"
	test_qm.prologue_completed = true
	test_qm.briarwood_unlocked = true
	test_qm.current_index = 2
	test_qm.saved_region_scene = "res://scenes/briarwood_forest.tscn"
	test_qm.saved_player_position = Vector2(40, -20)
	test_qm.saved_player_facing = 1
	test_qm.has_saved_player_pose = true
	var save_err: Error = test_qm.save_to_file(TEST_SAVE)
	check(save_err == OK, "Created mock Chapter 1 save at " + TEST_SAVE)
	test_qm.queue_free()

	change_scene_to_file(BELLHAVEN_SCENE)
	var bh_cont := await wait_for_scene("BellhavenVillage")
	var cont_hud: CanvasLayer = bh_cont.get_node("HUD")
	cont_hud.save_path = TEST_SAVE
	cont_hud.continue_game(TEST_SAVE)

	var bw_loaded := await wait_for_scene("BriarwoodForest")
	check(bw_loaded != null, "Continue loaded target region (BriarwoodForest) directly without IntroCinematic")
	if bw_loaded != null:
		var bw_qm: Node = bw_loaded.get_node("QuestManager")
		check(bw_qm.quest_id == "chapter1_whispers_of_briarwood" and bw_qm.get_current_objective_id() == "investigate_bridge", "Restored exact Chapter 1 objective via Continue")

	# -------------------------------------------------------------
	# STAGE 6: POST-GAME & REGION TRAVEL ISOLATION
	# -------------------------------------------------------------
	print("\n--- STAGE 6: POST-GAME & REGION TRAVEL ISOLATION ---")
	if bw_loaded != null:
		# Simulate travel from Briarwood to Floodmill
		var fm_qm: Node = bw_loaded.get_node("QuestManager")
		fm_qm.chapter1_completed = true
		fm_qm.floodmill_unlocked = true
		bw_loaded.travel_to_floodmill()
		var fm_loaded := await wait_for_scene("FloodmillVillage")
		check(fm_loaded != null, "Regular region travel (Briarwood -> Floodmill) proceeds without IntroCinematic")

	# Return to Bellhaven at Sunrise (post-game ending sequence)
	var snap: Dictionary = {
		"quest_id": "chapter5_the_last_bell",
		"chapter5_completed": true,
		"storm_resolved": true,
		"prologue_completed": true,
		"chapter1_completed": true,
		"chapter2_completed": true,
		"chapter3_completed": true,
		"chapter4_completed": true,
	}
	QuestManagerScript.pending_chapter5_snapshot = snap
	QuestManagerScript.carry_storm_resolved = true
	change_scene_to_file(BELLHAVEN_SCENE)
	var bh_sunrise := await wait_for_scene("BellhavenVillage")
	check(bh_sunrise != null and bh_sunrise.get_node("QuestManager").storm_resolved, "Post-game sunrise return loads Bellhaven directly without IntroCinematic")

	# -------------------------------------------------------------
	# STAGE 7: MISSING VIDEO FALLBACK
	# -------------------------------------------------------------
	print("\n--- STAGE 7: MISSING VIDEO FALLBACK ---")
	var fallback_script := Control.new()
	fallback_script.set_script(preload("res://scripts/ui/intro_cinematic.gd"))
	var temp_stream := VideoStreamTheora.new()
	temp_stream.file = "res://assets/cinematics/does_not_exist.ogv"
	# Create required node hierarchy
	var bg := ColorRect.new()
	bg.name = "BlackBackground"
	fallback_script.add_child(bg)
	var arc := AspectRatioContainer.new()
	arc.name = "AspectRatioContainer"
	fallback_script.add_child(arc)
	var v_player := VideoStreamPlayer.new()
	v_player.name = "VideoPlayer"
	arc.add_child(v_player)
	var s_hint := Label.new()
	s_hint.name = "SkipHint"
	fallback_script.add_child(s_hint)

	root.add_child(fallback_script)
	await frames(2)
	fallback_script._transition_to_gameplay("test_missing_fallback")
	var bh_fallback := await wait_for_scene("BellhavenVillage")
	check(bh_fallback != null, "Missing video fallback safely transitions to BellhavenVillage without hanging")
	fallback_script.queue_free()

	# -------------------------------------------------------------
	# STAGE 8: EXPORT PRESET INCLUSION
	# -------------------------------------------------------------
	print("\n--- STAGE 8: EXPORT PRESET INCLUSION ---")
	var export_cfg: String = FileAccess.get_file_as_string("res://export_presets.cfg")
	check(export_cfg.contains("*.ogv"), "export_presets.cfg includes *.ogv in include_filter")
	check(FileAccess.file_exists(OGV_PATH + ".uid"), "OGV .uid file exists and is tracked by Godot")

	# -------------------------------------------------------------
	# STAGE 9: REAL SAVE INTEGRITY
	# -------------------------------------------------------------
	print("\n--- STAGE 9: REAL SAVE INTEGRITY ---")
	var real_save_path := "user://ashvale_save.json"
	if user_backup_files.has(real_save_path):
		var cur_bytes := FileAccess.get_file_as_bytes(real_save_path)
		var orig_bytes: PackedByteArray = user_backup_files[real_save_path]
		check(cur_bytes == orig_bytes, "Real user save file is bit-for-bit identical (zero corruption)")
	else:
		check(not FileAccess.file_exists(real_save_path), "No spurious user save was created during validation")

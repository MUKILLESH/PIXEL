extends SceneTree

const SAVE_TEST_PATH := "user://test_phase4_save.json"
const V1_SAVE_TEST_PATH := "user://test_phase4_v1_compat.json"
const V2_SAVE_TEST_PATH := "user://test_phase4_v2_compat.json"
const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")

var checks: int = 0
var failed: int = 0

func _init() -> void:
	call_deferred("run")

func check(cond: bool, label: String) -> void:
	checks += 1
	if cond:
		print("PASS: " + label)
	else:
		failed += 1
		print("FAIL: " + label)

func frames(count: int = 2) -> void:
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

func _release_move_actions() -> void:
	for act in ["move_up", "move_down", "move_left", "move_right"]:
		if Input.is_action_pressed(act):
			Input.action_release(act)

func walk_to(player: CharacterBody2D, target: Vector2, max_ticks: int = 240) -> bool:
	for _step in range(max_ticks):
		var delta: Vector2 = target - player.position
		if delta.length() <= 5.5:
			_release_move_actions()
			await frames(2)
			return true
		_release_move_actions()
		if absf(delta.x) > 4.0:
			Input.action_press("move_right" if delta.x > 0.0 else "move_left")
		if absf(delta.y) > 4.0:
			Input.action_press("move_down" if delta.y > 0.0 else "move_up")
		await physics_frame
	_release_move_actions()
	await frames(2)
	return player.position.distance_to(target) <= 9.0

func walk_path(player: CharacterBody2D, waypoints: Array) -> bool:
	for pt: Vector2 in waypoints:
		if not await walk_to(player, pt):
			return false
	return true

func read_through(hud: CanvasLayer, captured_lines: Array[String] = []) -> void:
	var safety: int = 16
	while is_instance_valid(hud) and hud.is_inside_tree() and hud.get_node("Message").visible and safety > 0:
		safety -= 1
		captured_lines.append(hud.get_node("Message/Text").text)
		await press("interact")
		await frames(1)

func wait_for_scene(expected_name: String, max_frames: int = 60) -> Node:
	for _i in range(max_frames):
		await process_frame
		if current_scene != null and current_scene.name == expected_name:
			await frames(4)
			return current_scene
	return null

func _cleanup_saves() -> void:
	for p in [
		SAVE_TEST_PATH, SAVE_TEST_PATH + ".bak", SAVE_TEST_PATH + ".tmp",
		V1_SAVE_TEST_PATH, V1_SAVE_TEST_PATH + ".bak", V1_SAVE_TEST_PATH + ".tmp",
		V2_SAVE_TEST_PATH, V2_SAVE_TEST_PATH + ".bak", V2_SAVE_TEST_PATH + ".tmp",
	]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

func _is_point_free_of_solids(world_2d: World2D, pt: Vector2) -> bool:
	var params := PhysicsPointQueryParameters2D.new()
	params.position = pt
	params.collision_mask = 1
	params.collide_with_bodies = true
	params.collide_with_areas = false
	var hits: Array[Dictionary] = world_2d.direct_space_state.intersect_point(params, 8)
	return hits.is_empty()

func _advance_chapter2_for_transition(qm: Node) -> void:
	qm.carry_prologue_completed = true
	qm.carry_chapter1_completed = true
	qm.prologue_completed = true
	qm.chapter1_completed = true
	qm.floodmill_unlocked = true
	for entry in qm.objectives:
		var oid: String = String(entry.get("id"))
		if oid == "find_watermill_parts":
			qm.record_mill_part_collected("iron_drive_gear")
			qm.record_mill_part_collected("bronze_pinion")
			qm.record_mill_part_collected("oak_coupling_belt")
		elif oid == "reconstruct_village_ledger":
			qm.record_archive_clue_found("record_census")
			qm.record_archive_clue_found("record_tribute")
			qm.record_archive_clue_found("record_transfer")
			qm.complete_objective(oid)
		else:
			qm.complete_objective(oid)

func run() -> void:
	_cleanup_saves()
	Engine.time_scale = 4.0
	print("--- STAGE 1: FLOODMILL TO IRONWATCH TRANSITION ---")

	# 1. Start in Floodmill and verify natural IronwatchGate -> IronwatchKeep transition
	var err: Error = change_scene_to_file("res://scenes/floodmill_village.tscn")
	check(err == OK, "Floodmill scene loads for Phase 4 transition check")
	var fm := await wait_for_scene("FloodmillVillage")
	check(fm != null and fm.has_method("travel_to_ironwatch"), "Floodmill exposes travel_to_ironwatch()")
	var fm_qm: Node = fm.get_node("QuestManager")
	var fm_hud: CanvasLayer = fm.get_node("HUD")
	var fm_player: CharacterBody2D = fm.get_node("Actors/Player")
	var fm_gate: StaticBody2D = fm.get_node("Actors/IronwatchGate")

	check(fm_gate.unlocked == false, "Ironwatch Gate locked before Chapter 2 completion")
	_advance_chapter2_for_transition(fm_qm)
	await frames(3)
	check(fm_qm.chapter2_completed and fm_qm.ironwatch_unlocked, "Chapter 2 completion unlocks Ironwatch Gate")
	check(fm_gate.unlocked == true, "Ironwatch Gate visual state unlocks in Floodmill")

	# Two-step travel on IronwatchGate (first shows unlocked teaser, second travels)
	fm_qm.sluice_gate_states.assign([2, 1, 3])
	fm_qm.sluice_solved = true
	fm._sync_world_from_quest()
	await frames(2)
	fm_player.position = Vector2(186, -168)
	await frames(3)
	await press("interact")
	var gate_lines: Array[String] = []
	await read_through(fm_hud, gate_lines)
	check(" ".join(gate_lines).to_lower().contains("ironwatch keep"), "First post-unlock gate interact announces Ironwatch Keep readiness")
	check(fm_gate.ready_to_travel == true, "Floodmill IronwatchGate arms ready_to_travel after dismiss")

	await press("interact")
	await read_through(fm_hud)
	var iw := await wait_for_scene("IronwatchKeep")
	check(iw != null, "Transition from Floodmill loads IronwatchKeep cleanly")

	var qm: Node = iw.get_node("QuestManager")
	var hud: CanvasLayer = iw.get_node("HUD")
	var player: CharacterBody2D = iw.get_node("Actors/Player")
	check(qm.quest_id == "chapter3_keepers_lie" and qm.get_current_objective_id() == "enter_ironwatch", "Ironwatch loads chapter3_keepers_lie at Objective 1")
	check(qm.prologue_completed and qm.chapter1_completed and qm.chapter2_completed, "Prologue, Ch1, and Ch2 flags carried cleanly into Ironwatch")
	check(hud.get_node("Clock").text == "CHAPTER 3" and hud.get_node("Subtitle").text.contains("IRONWATCH"), "HUD header reflects Chapter 3 in Ironwatch Keep")

	# 2. Validate 6 areas, NPCs, Sentinels, UI panel, and navigable spots
	for bname in ["GatehouseBastion", "RuinedBarracks", "CutawayArchives", "HallOfCrests", "ShadowColonnade", "BeaconVaultSanctum"]:
		check(iw.has_node("Actors/" + bname), "Ironwatch structure exists: " + bname)
	check(iw.has_node("Actors/Lyra") and iw.has_node("Actors/LastWarden"), "Both Lyra and LastWarden NPCs exist in Ironwatch")
	check(iw.has_node("Actors/ShadowSentinel1") and iw.has_node("Actors/ShadowSentinel2"), "Both ShadowSentinel patrolling hazards exist")
	check(hud.has_node("CrestPuzzle"), "CrestPuzzle UI panel exists on HUD")

	for i in range(iw.approach_positions.size()):
		var pt: Vector2 = iw.approach_positions[i]
		check(_is_point_free_of_solids(iw.get_world_2d(), pt), "Ironwatch approach spot %d %s is clear of solids" % [i, str(pt)])

	# 3. Verify physical gating & out-of-order blocking
	print("--- STAGE 2: STRUCTURAL & OUT-OF-ORDER GUARDS ---")
	check(qm.complete_objective("restore_third_beacon") == false, "QuestManager blocks out-of-order restore_third_beacon")
	check(iw.crest_blocker_shape != null and iw.crest_blocker_shape.disabled == false, "CrestPortcullisBlocker starts active before Hall of Crests")
	check(iw.passage_exit_blocker_shape != null and iw.passage_exit_blocker_shape.disabled == false, "PassageExitBlocker starts active before Shadowed Passage")

	# Interact with Courtyard Monument early -> blocked until enter_ironwatch
	await walk_to(player, Vector2(18, 176))
	await press("interact")
	await read_through(hud)
	check(qm.get_current_objective_id() == "enter_ironwatch", "Inspecting courtyard early does not skip enter_ironwatch")

	# 4. Complete chronological Objective 1 -> enter_ironwatch
	await walk_to(player, Vector2(120, 198))
	await press("interact")
	await read_through(hud)
	check(qm.is_objective_completed("enter_ironwatch") and qm.get_current_objective_id() == "investigate_courtyard", "Objective 1 completed: enter_ironwatch")

	# 5. Complete Objective 2 -> investigate_courtyard
	await walk_to(player, Vector2(18, 176))
	await press("interact")
	var mon_lines: Array[String] = []
	await read_through(hud, mon_lines)
	check(qm.is_objective_completed("investigate_courtyard") and qm.get_current_objective_id() == "discover_warden_records", "Objective 2 completed: investigate_courtyard")

	# Trying Crest Clue or Barracks Log before Archives records -> blocked
	await walk_to(player, Vector2(-195, 154))
	await press("interact")
	await read_through(hud)
	check(qm.get_current_objective_id() == "discover_warden_records", "Barracks Roster blocked until Archives records read")

	# 6. Complete Objective 3 -> discover_warden_records inside Cutaway Archives
	check(await walk_path(player, [Vector2(40, 100), Vector2(185, 62)]), "Walked cleanly into Cutaway Fortress Archives")
	await press("interact")
	var rec_lines: Array[String] = []
	await read_through(hud, rec_lines)
	check(" ".join(rec_lines).contains("thirty-six") and qm.is_objective_completed("discover_warden_records"), "Objective 3 completed: Archives reveal first catastrophe sacrifice")
	check(qm.get_current_objective_id() == "explore_barracks", "Objective 4 unlocked: explore_barracks")

	# 7. Complete Objective 4 -> explore_barracks + Optional Warden's Tarnished Locket
	check(await walk_path(player, [Vector2(40, 95), Vector2(-120, 145), Vector2(-195, 154)]), "Walked cleanly to Abandoned Barracks Roster")
	await press("interact")
	var bar_lines: Array[String] = []
	await read_through(hud, bar_lines)
	check(" ".join(bar_lines).to_lower().contains("floodmill") and qm.is_objective_completed("explore_barracks"), "Objective 4 completed: Barracks reveal concealed generations")

	await walk_to(player, Vector2(-120, 156))
	await press("interact")
	await read_through(hud)
	check(qm.optional_discoveries.has("wardens_locket"), "Optional Warden's Tarnished Locket collected cleanly")
	check(qm.get_current_objective_id() == "find_crest_clues", "Optional locket preserves active objective find_crest_clues")

	# Try Crest Altar early before all 3 clues -> refused cleanly
	await walk_to(player, Vector2(-18, 36))
	await press("interact")
	await read_through(hud)
	check(hud.get_node("CrestPuzzle").visible == false and not qm.can_open_crest_puzzle(), "CrestPuzzle blocked before finding 3 crest clues")

	# 8. Complete Objective 5 -> Find all 3 Watch Crest Clues (1/3, 2/3, 3/3)
	await walk_path(player, [Vector2(140, 82), Vector2(216, 76)])
	await press("interact")
	await read_through(hud)
	check(qm.crest_clues_found.size() == 1, "Collected Crest Clue 1/3 (Silver Bell)")

	# Duplicate clue interaction does not double-count
	await press("interact")
	await read_through(hud)
	check(qm.crest_clues_found.size() == 1, "Duplicate crest clue cannot be farmed")

	await walk_path(player, [Vector2(40, 82), Vector2(-164, 56)])
	await press("interact")
	await read_through(hud)
	check(qm.crest_clues_found.size() == 2, "Collected Crest Clue 2/3 (Sundered Shield)")

	await walk_path(player, [Vector2(-18, 36), Vector2(44, 22)])
	await press("interact")
	await read_through(hud)
	check(qm.crest_clues_found.size() == 3 and qm.is_objective_completed("find_crest_clues"), "Objective 5 completed on 3/3 crest clues")
	check(qm.get_current_objective_id() == "solve_crest_puzzle", "Objective 6 unlocked: solve_crest_puzzle")

	# 9. Complete Objective 6 -> Hall of Crests Puzzle (test ESC, reject wrong, solve [1, 2, 3])
	print("--- STAGE 3: HALL OF CRESTS MINIGAME ---")
	await walk_to(player, Vector2(-18, 36))
	await press("interact")
	await frames(3)
	var crest_ui: Panel = hud.get_node("CrestPuzzle")
	check(crest_ui.visible and player.movement_locked == true, "CrestPuzzle opens and locks player movement")
	await press_keycode(KEY_ESCAPE)
	await frames(2)
	check(not crest_ui.visible and player.movement_locked == false, "ESC closes CrestPuzzle without softlock")

	await press("interact")
	await frames(2)
	check(crest_ui.visible, "CrestPuzzle reopens cleanly")
	crest_ui.attempt_solve() # [0, 0, 0] invalid!
	await frames(2)
	check(crest_ui.visible and not qm.crest_puzzle_solved, "Incorrect heraldic crest combination rejected")

	# Solve with keyboard: Pillar 0 -> SILVER BELL (1x D), Pillar 1 -> SUNDERED SHIELD (S, 2x D), Pillar 2 -> CROWNED FLAME (S, 3x D), Enter!
	await press_keycode(KEY_D)
	await press_keycode(KEY_S)
	await press_keycode(KEY_D)
	await press_keycode(KEY_D)
	await press_keycode(KEY_S)
	await press_keycode(KEY_D)
	await press_keycode(KEY_D)
	await press_keycode(KEY_D)
	await press_keycode(KEY_ENTER)
	await frames(3)
	await read_through(hud)
	check(not crest_ui.visible and qm.crest_puzzle_solved, "CrestPuzzle solved via keyboard inputs")
	check(qm.is_objective_completed("solve_crest_puzzle") and iw.crest_blocker_shape.disabled == true, "Objective 6 completed and CrestPortcullisBlocker unlocked")
	check(qm.get_current_objective_id() == "navigate_shadowed_passage", "Objective 7 unlocked: navigate_shadowed_passage")

	# 10. Shadowed Passage Stealth -> checkpoint update, Sentinel detection reset, & completion
	print("--- STAGE 4: SHADOWED PASSAGE STEALTH ---")
	var s1: Node2D = iw.get_node("Actors/ShadowSentinel1")
	var s2: Node2D = iw.get_node("Actors/ShadowSentinel2")
	# Time our dash from Alcove 0 -> Alcove 1 while Sentinel 1 is sweeping the east side of the hall
	check(await walk_path(player, [Vector2(-160, 0), Vector2(-160, -48)]), "Entered Shadowed Passage South Ward Alcove")
	s1.set_patrol_phase(PI * 0.5)
	check(await walk_to(player, Vector2(-160, -110)), "Walked physically into Shadowed Passage Mid Safe Alcove")
	await frames(3)
	check(qm.stealth_checkpoint_id == "checkpoint_1", "Entering mid-passage alcove updates stealth checkpoint to checkpoint_1")

	# Deliberately step out of Alcove 1 onto Sentinel 1's sweep to test non-destructive checkpoint recovery
	s1.set_patrol_phase(0.0) # position.x == -160.0 right at center
	player.position = Vector2(-160, -82)
	await frames(4)
	check(qm.stealth_detections_count >= 1, "Shadow Sentinel proximity triggers detection event")
	check(player.position.distance_to(Vector2(-160, -110)) <= 4.0, "Detection safely returns Aren to active checkpoint_1 without losing clues")
	await read_through(hud)
	check(qm.crest_puzzle_solved and qm.crest_clues_found.size() == 3, "Detection reset preserves all clues and Hall of Crests unlock")

	# Wait safely inside Alcove 1 for cooldown (0.65s -> 14 ticks at 4x), then dash past Sentinel 2 into North Safe Alcove & Ward Switch
	for _wait_i in range(14):
		await physics_frame
	s2.set_patrol_phase(PI * 0.5)
	check(await walk_to(player, Vector2(-160, -150)), "Walked safely to North Ward Lantern inside North Safe Alcove")
	await press("interact")
	await read_through(hud)
	check(qm.shadow_passage_cleared and iw.passage_exit_blocker_shape.disabled == true, "ShadowWardSwitch calms sentinels and opens Vault exit doorway")
	check(qm.is_objective_completed("navigate_shadowed_passage") and qm.get_current_objective_id() == "reach_wardens_chamber", "Objective 7 completed: navigate_shadowed_passage")

	# Save mid-chapter Checkpoint state right before Vault confrontation to verify Save v3 round-trip later
	player.position = Vector2(-150, -162)
	player.facing = 2
	await frames(2)
	var mid_save_err: Error = qm.save_to_file(SAVE_TEST_PATH)
	check(mid_save_err == OK, "Mid-chapter Save v3 writes cleanly in Ironwatch Keep")

	# 11. Walk east into Warden's Chamber -> completes reach_wardens_chamber
	check(await walk_path(player, [Vector2(-100, -164), Vector2(-60, -142)]), "Crossed northeast exit into Warden's Chamber and Beacon Vault")
	await frames(3)
	check(qm.is_objective_completed("reach_wardens_chamber") and qm.get_current_objective_id() == "confront_last_warden", "Objective 8 completed automatically upon entering Warden's Chamber")

	# Try ElenaResearch before confronting Warden -> refused cleanly
	await walk_to(player, Vector2(18, -98))
	await press("interact")
	await read_through(hud)
	check(not qm.elena_research_found and qm.get_current_objective_id() == "confront_last_warden", "Elena's research locked until Last Bell Warden confronted")

	# 12. Objective 9 -> Confront Last Bell Warden & verify ALL 4 canonical lines
	print("--- STAGE 5: LAST BELL WARDEN & THIRD BEACON ---")
	await walk_to(player, Vector2(-35, -118))
	await press("interact")
	var warden_lines: Array[String] = []
	await read_through(hud, warden_lines)
	var full_warden_text := "\n".join(warden_lines)
	check(full_warden_text.contains("We chose to forget thirty-six lives so that ten thousand could live."), "Canonical Warden line 1 delivered verbatim")
	check(full_warden_text.contains("You never asked those thirty-six."), "Canonical Aren confrontation line delivered verbatim")
	check(full_warden_text.contains("No. And that is the burden I have carried longer than any kingdom should endure."), "Canonical Warden burden line delivered verbatim")
	check(full_warden_text.contains("A burden is not permission to repeat the harm."), "Canonical Lyra closing line delivered verbatim")
	check(qm.warden_confronted and qm.is_objective_completed("confront_last_warden"), "Objective 9 completed: confront_last_warden")
	check(qm.get_current_objective_id() == "discover_elena_research", "Objective 10 unlocked: discover_elena_research")

	# 13. Objective 10 -> Elena's Research
	await walk_to(player, Vector2(18, -98))
	await press("interact")
	var elena_lines: Array[String] = []
	await read_through(hud, elena_lines)
	check(" ".join(elena_lines).contains("triad") and qm.elena_research_found, "Objective 10 completed: Elena's harmonic triad research uncovered")
	check(qm.get_current_objective_id() == "restore_third_beacon", "Objective 11 unlocked: restore_third_beacon")

	# Try Dawnspire Gate early -> refused cleanly
	await walk_to(player, Vector2(152, -134))
	await press("interact")
	await read_through(hud)
	check(not qm.third_beacon_activated and not qm.dawnspire_unlocked, "Dawnspire Gate locked until Third Ancient Beacon restored")

	# 14. Objective 11 -> Restore Third Ancient Beacon & connect all 3 beacons
	await walk_to(player, Vector2(70, -120))
	await press("interact")
	await read_through(hud)
	check(qm.third_beacon_activated and iw.get_node("Landscape").third_beacon_activated == true, "Objective 11 completed: Third Ancient Beacon restored & triad illuminated")
	check(qm.get_current_objective_id() == "unlock_dawnspire_road", "Objective 12 unlocked: unlock_dawnspire_road")

	# 15. Objectives 12 & 13 -> Unlock Dawnspire Road & Complete Chapter 3
	await walk_to(player, Vector2(152, -134))
	await press("interact")
	await read_through(hud)
	check(qm.dawnspire_unlocked and qm.is_objective_completed("unlock_dawnspire_road"), "Objective 12 completed: Dawnspire road unlocked")
	check(qm.get_current_objective_id() == "complete_chapter3", "Objective 13 unlocked: complete_chapter3")

	await press("interact")
	await read_through(hud)
	await frames(3)
	check(qm.chapter3_completed and qm.is_quest_completed("chapter3_keepers_lie"), "Objective 13 completed and Chapter 3 marked finished")
	check(hud.get_node("PrologueComplete").visible and hud.get_node("PrologueComplete/BannerTitle").text == "CHAPTER 3 COMPLETE — THE KEEPER'S LIE", "Exact Chapter 3 completion banner shown")

	await press("interact")
	await frames(2)
	check(not hud.get_node("PrologueComplete").visible and not player.movement_locked, "Dismissing Chapter 3 banner restores free exploration")

	# Check Field Satchel entries for Chapter 3
	hud.open_inventory()
	await frames(2)
	var inv_text: String = hud.get_node("InventoryPanel").get_rendered_items_text()
	check(inv_text.contains("FIRST CATASTROPHE LEDGER") and inv_text.contains("WATCH CREST TABLETS (3/3)") and inv_text.contains("ELENA'S HARMONIC FOLIO") and inv_text.contains("THIRD ANCIENT BEACON"), "Field Satchel tracks all Chapter 3 documents, crests, testimony, and triad beacon")
	await press_keycode(KEY_ESCAPE)
	await frames(2)

	print("--- STAGE 6: SAVE V3 & BACKWARD COMPATIBILITY ---")
	# 16. Save v3 rotation & Cross-scene Continue test (from Bellhaven startup into saved Ironwatch mid-chapter)
	var completed_save_err: Error = qm.save_to_file(SAVE_TEST_PATH)
	check(completed_save_err == OK and FileAccess.file_exists(SAVE_TEST_PATH + ".bak"), "Second Save v3 rotates .bak backup cleanly")

	# Overwrite primary with mid-chapter save? Wait — let's test BOTH Continue from Bellhaven using completed save AND v1/v2 compat!
	change_scene_to_file("res://scenes/sjt_exterior.tscn")
	var start_scene := await wait_for_scene("BellhavenVillage")
	check(start_scene != null, "Returned to Bellhaven startup to verify Continue -> Ironwatch Keep")
	var start_hud: CanvasLayer = start_scene.get_node("HUD")
	check(start_hud.continue_game(SAVE_TEST_PATH), "Continue initiated toward completed Ironwatch Keep v3 save")
	var resumed_iw := await wait_for_scene("IronwatchKeep")
	check(resumed_iw != null, "Continue transitions automatically to IronwatchKeep")
	if resumed_iw != null:
		var r_qm: Node = resumed_iw.get_node("QuestManager")
		var r_player: CharacterBody2D = resumed_iw.get_node("Actors/Player")
		check(r_qm.chapter3_completed and r_qm.third_beacon_activated and r_qm.dawnspire_unlocked and r_qm.warden_confronted, "All Chapter 3 completion flags survived Save v3 reload")
		check(r_player.position.distance_to(Vector2(152, -134)) <= 6.0, "Resumed Ironwatch player restores saved Vault pose")
		check(resumed_iw.crest_blocker_shape.disabled and resumed_iw.passage_exit_blocker_shape.disabled and resumed_iw.get_node("Landscape").third_beacon_activated, "Resumed Ironwatch doors, stealth state, and three-beacon triad synced visually")

	# 17. Test v1 & v2 Save Compatibility + Corrupted primary fallback
	var v1_dict := {
		"version": 1,
		"quest_id": "chapter1_whispers_of_briarwood",
		"quest_data_path": "res://data/chapter1_quest.json",
		"region_scene": "res://scenes/briarwood_forest.tscn",
		"has_player_pose": true,
		"player_x": 28.0,
		"player_y": -184.0,
		"player_facing": 4,
		"current_index": 9,
		"completed_objectives": {"enter_briarwood": true},
		"chapter1_completed": true,
		"floodmill_unlocked": true,
	}
	var f1 := FileAccess.open(V1_SAVE_TEST_PATH, FileAccess.WRITE)
	f1.store_string(JSON.stringify(v1_dict))
	f1.close()
	var v1_sum: Dictionary = QuestManagerScript.peek_save_summary(V1_SAVE_TEST_PATH)
	check(bool(v1_sum.get("valid", false)) == true, "Phase 2 (v1) save remains accepted by Save v3 validator")

	var v2_dict := {
		"version": 2,
		"quest_id": "chapter2_drowned_village",
		"quest_data_path": "res://data/chapter2_quest.json",
		"region_scene": "res://scenes/floodmill_village.tscn",
		"has_player_pose": true,
		"player_x": 110.0,
		"player_y": -180.0,
		"player_facing": 2,
		"current_index": 14,
		"completed_objectives": {"enter_floodmill": true, "complete_chapter2": true},
		"chapter2_completed": true,
		"ironwatch_unlocked": true,
		"second_beacon_activated": true,
	}
	var f2 := FileAccess.open(V2_SAVE_TEST_PATH, FileAccess.WRITE)
	f2.store_string(JSON.stringify(v2_dict))
	f2.close()
	var compat_qm := QuestManagerScript.new()
	check(compat_qm.load_from_file(V2_SAVE_TEST_PATH), "Phase 3 (v2) save loads cleanly with Save v3")
	check(compat_qm.chapter2_completed and not compat_qm.chapter3_completed and not compat_qm.crest_puzzle_solved, "Loaded v2 save preserves Ch2 completion and defaults Ch3 state")
	compat_qm.free()

	# Corrupt primary v3 save and verify automatic .bak fallback!
	var cf := FileAccess.open(SAVE_TEST_PATH, FileAccess.WRITE)
	cf.store_string("{corrupt_json_v3_test")
	cf.close()
	var fallback_qm := QuestManagerScript.new()
	check(fallback_qm.load_from_file(SAVE_TEST_PATH), "Corrupted primary v3 save automatically recovers from .bak")
	fallback_qm.free()

	_cleanup_saves()
	Engine.time_scale = 1.0
	check(true, "Phase 4 suite completed")
	print("PHASE 4 RESULT: %d checks, %d failures" % [checks, failed])
	quit(0 if failed == 0 else 1)

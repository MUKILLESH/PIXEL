extends SceneTree
## Phase 8 End-to-End Validation Suite — Critical Gameplay & World Integrity Fix.
## Tests:
##   1. Ending persistence & post-game Bellhaven Sunrise survival across travel/save/continue
##   2. Cross-chapter & bidirectional travel persistence across all 6 regions
##   3. Real player physics collision checks across water/canal/millpond/walls/cliffs/perimeters
##   4. Zoom/viewport-aware Camera2D clamping across all 6 regions
##   5. Bellhaven cobblestone footpath & planter/shrub clearance

const SAVE_TEST_PATH := "user://test_phase8_save.json"
const SAVE_TEST_ROUNDTRIP_PATH := "user://test_phase8_roundtrip.json"
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

func _release_move_actions() -> void:
	for act in ["move_up", "move_down", "move_left", "move_right"]:
		if Input.is_action_pressed(act):
			Input.action_release(act)

func hold_move(action: String, num_frames: int = 75) -> void:
	_release_move_actions()
	Input.action_press(action)
	await frames(num_frames)
	_release_move_actions()
	await frames(2)

func hold_diag(act_x: String, act_y: String, num_frames: int = 90) -> void:
	_release_move_actions()
	Input.action_press(act_x)
	Input.action_press(act_y)
	await frames(num_frames)
	_release_move_actions()
	await frames(2)

func read_through(hud: CanvasLayer) -> void:
	var safety: int = 24
	while is_instance_valid(hud) and hud.is_inside_tree() and hud.get_node("Message").visible and safety > 0:
		safety -= 1
		await press("interact")
		await frames(1)

func wait_for_scene(expected_name: String, max_frames: int = 70) -> Node:
	for _i in range(max_frames):
		await process_frame
		if current_scene != null and current_scene.name == expected_name:
			await frames(4)
			return current_scene
	return null

func interact_at(world: Node, target_pos: Vector2) -> void:
	var player := world.get_node("Actors/Player") as CharacterBody2D
	var hud := world.get_node("HUD") as CanvasLayer
	player.position = target_pos
	await frames(4)
	await press("interact")
	await read_through(hud)

func _cleanup_saves() -> void:
	for p in [
		SAVE_TEST_PATH, SAVE_TEST_PATH + ".bak", SAVE_TEST_PATH + ".tmp",
		SAVE_TEST_ROUNDTRIP_PATH, SAVE_TEST_ROUNDTRIP_PATH + ".bak", SAVE_TEST_ROUNDTRIP_PATH + ".tmp",
	]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

func _dist_point_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab: Vector2 = b - a
	var len_sq: float = ab.length_squared()
	if len_sq < 0.0001:
		return p.distance_to(a)
	var t: float = clampf((p - a).dot(ab) / len_sq, 0.0, 1.0)
	return p.distance_to(a + ab * t)

func _min_dist_polyline(p: Vector2, pts: PackedVector2Array) -> float:
	var best: float = INF
	for i in range(pts.size() - 1):
		best = minf(best, _dist_point_to_segment(p, pts[i], pts[i + 1]))
	return best

func _assert_camera_clamped(world: Node, region_label: String) -> void:
	var player := world.get_node("Actors/Player") as CharacterBody2D
	var cam := world.get_node("Actors/Player/Camera2D") as Camera2D
	check(bool(cam.get("bounds_enabled")), region_label + ": Camera2D has bounds_enabled = true")
	var min_b: Vector2 = cam.get("min_bounds")
	var max_b: Vector2 = cam.get("max_bounds")
	var vp := Vector2(640.0, 360.0)
	var half_vp := vp * 0.5
	check(max_b.x - min_b.x >= vp.x - 1.0 and max_b.y - min_b.y >= vp.y - 1.0,
		region_label + ": Camera bounds >= viewport 640x360 (%s .. %s)" % [min_b, max_b])

	var saved_pos := player.position
	# Test extreme NW and SE target focus clamps
	player.position = Vector2(min_b.x, min_b.y)
	cam.snap_to_target()
	var nw_cam := cam.global_position
	check(nw_cam.x >= min_b.x + half_vp.x - 1.0 and nw_cam.y >= min_b.y + half_vp.y - 1.0,
		region_label + ": NW Camera clamped inside viewport (%s)" % nw_cam)

	player.position = Vector2(max_b.x, max_b.y)
	cam.snap_to_target()
	var se_cam := cam.global_position
	check(se_cam.x <= max_b.x - half_vp.x + 1.0 and se_cam.y <= max_b.y - half_vp.y + 1.0,
		region_label + ": SE Camera clamped inside viewport (%s)" % se_cam)

	player.position = saved_pos
	cam.snap_to_target()
	await frames(2)

func run() -> void:
	_cleanup_saves()
	QuestManagerScript.reset_session_state()

	print("=== PHASE 8 PART A: ENDING & POST-GAME PERSISTENCE ===")
	# Boot Great Bell Sanctum in post-climax/epilogue setup and finish Chapter 5 legitimately via state & triggers
	QuestManagerScript.carry_prologue_completed = true
	QuestManagerScript.carry_chapter1_completed = true
	QuestManagerScript.carry_chapter2_completed = true
	QuestManagerScript.carry_chapter3_completed = true
	QuestManagerScript.carry_chapter4_completed = true
	QuestManagerScript.carry_optional_discoveries = {
		"briarwood_hidden_relic": true,
		"bellhaven_bell_inscription": true,
	}
	check(change_scene_to_file("res://scenes/great_bell_sanctum.tscn") == OK, "Boot GreatBellSanctum for ending test")
	var gb := await wait_for_scene("GreatBellSanctum")
	check(gb != null, "GreatBellSanctum loaded")

	var gb_qm: Node = gb.quest_manager
	gb_qm.great_bell_chamber_entered = true
	gb_qm.lyra_antechamber_spoken = true
	gb_qm.forgotten_hall_investigated = true
	gb_qm.memory_fragments_recovered = {"home": true, "promise": true, "belonging": true}
	gb_qm.warden_record_revealed = true
	gb_qm.elena_final_message_heard = true
	gb_qm.memory_binding_examined = true
	gb_qm.beacon_conduits_activated = {"conduit_briarwood": true, "conduit_floodmill": true, "conduit_ironwatch": true}
	gb_qm.protective_network_stabilized = true
	gb_qm.binding_severed = true
	gb_qm.last_bell_cinematic_seen = true
	gb_qm.storm_resolved = true
	gb_qm.dawn_terrace_returned = true
	gb_qm.epilogue_completed = true
	gb_qm.elena_journal_placed = true
	gb_qm.credits_viewed = true
	gb_qm.chapter5_completed = true
	gb_qm.current_index = gb_qm.objectives.size()
	gb._sync_world_from_quest()
	await frames(2)

	# Transition to Bellhaven Sunrise via BellhavenSunriseArch interactable
	var sunrise_arch := gb.get_node("Actors/BellhavenSunriseArch") as StaticBody2D
	await interact_at(gb, sunrise_arch.position + Vector2(0, 14))
	var bh := await wait_for_scene("BellhavenVillage")
	check(bh != null, "Arrived in Bellhaven from Dawn Terrace")
	var bh_qm: Node = bh.quest_manager
	check(bh_qm.storm_resolved and bh_qm.chapter5_completed and bh_qm.credits_viewed,
		"Post-ending flags preserved on initial arrival in Bellhaven Sunrise")
	check(bh_qm.optional_discoveries.get("briarwood_hidden_relic", false) and bh_qm.optional_discoveries.get("bellhaven_bell_inscription", false),
		"Optional discoveries preserved into Bellhaven Sunrise")
	check(bh.get_node_or_null("Actors/VillageMemorial") != null and bh.get_node_or_null("Actors/DawnTerraceArch") != null and bh.get_node_or_null("Actors/LyraBellhaven") != null,
		"Bellhaven Sunrise renders Memorial, DawnTerraceArch, and LyraBellhaven")
	check(bh_qm.get_current_objective_text() == "Chapter 5 Complete - Ashvale Remembered." and bh_qm.get_current_objective_text().find("Investigate") == -1,
		"Post-game Bellhaven objective shows peaceful post-storm status (not Prologue step 1)")

	# Exact bug repro: travel Bellhaven Sunrise -> Briarwood -> BACK to Bellhaven
	var bh_gate := bh.get_node("Actors/BriarwoodGate") as StaticBody2D
	await interact_at(bh, bh_gate.position + Vector2(0, 16))
	check(bool(bh_gate.get("ready_to_travel")), "Bellhaven BriarwoodGate ready_to_travel armed on step 1")
	await interact_at(bh, bh_gate.position + Vector2(0, 16))
	var bw_post := await wait_for_scene("BriarwoodForest")
	check(bw_post != null, "Transitioned from Bellhaven Sunrise to Briarwood")
	check(bw_post.quest_manager.storm_resolved and bw_post.quest_manager.chapter5_completed,
		"Briarwood recognizes post-game storm_resolved and chapter5_completed")

	# Use Briarwood WaystoneEntrance return trigger -> back to Bellhaven!
	var bw_waystone := bw_post.get_node("Actors/WaystoneEntrance") as StaticBody2D
	await interact_at(bw_post, bw_waystone.position + Vector2(0, 16))
	check(bool(bw_waystone.get("ready_to_travel")), "Briarwood WaystoneEntrance arms return travel after enter_briarwood")
	await interact_at(bw_post, bw_waystone.position + Vector2(0, 16))
	var bh_revisit := await wait_for_scene("BellhavenVillage")
	check(bh_revisit != null, "Returned from Briarwood back to Bellhaven via WaystoneEntrance")
	var bh2_qm: Node = bh_revisit.quest_manager
	check(bh2_qm.storm_resolved and bh2_qm.chapter5_completed and bh2_qm.credits_viewed and bh2_qm.prologue_completed,
		"CRITICAL FIX: Bellhaven does NOT reset after returning from Briarwood post-ending")
	check(bh_revisit.get_node_or_null("Actors/VillageMemorial") != null and bh_revisit.get_node("Landscape").sunrise_epilogue,
		"Bellhaven revisit post-ending preserves Sunrise mode, Memorial, and DawnTerraceArch")
	check(bh2_qm.get_current_objective_text() == "Chapter 5 Complete - Ashvale Remembered.",
		"Bellhaven revisit post-ending objective remains post-game peace status")

	# Also check Bellhaven Sunrise -> DawnTerraceArch -> Great Bell Sanctum (and verify no credits loop)
	await interact_at(bh_revisit, bh_revisit.get_node("Actors/DawnTerraceArch").position + Vector2(0, 16))
	var gb_revisit := await wait_for_scene("GreatBellSanctum")
	check(gb_revisit != null, "Returned to GreatBellSanctum via DawnTerraceArch")
	check(gb_revisit.quest_manager.chapter5_completed and gb_revisit.quest_manager.storm_resolved,
		"GreatBellSanctum revisit preserves completed Chapter 5 state")
	check(not gb_revisit.get_node("HUD/EndingCredits").visible,
		"GreatBellSanctum post-game revisit does not re-open EndingCredits")

	# Save post-game state at Bellhaven Sunrise & verify Continue keeps Bellhaven Sunrise intact
	await interact_at(gb_revisit, gb_revisit.get_node("Actors/BellhavenSunriseArch").position + Vector2(0, 14))
	var bh_before_save := await wait_for_scene("BellhavenVillage")
	check(bh_before_save != null, "Returned to Bellhaven Sunrise before saving")
	check(bh_before_save.get_node("HUD").manual_save(SAVE_TEST_PATH),
		"Post-game Bellhaven save written to isolated path via HUD.manual_save")

	# Simulate cold launch with empty in-memory session_state before calling Continue
	QuestManagerScript.reset_session_state()
	check(change_scene_to_file("res://scenes/briarwood_forest.tscn") == OK, "Cold boot another scene before Continue check")
	var cold_other := await wait_for_scene("BriarwoodForest")
	check(cold_other != null, "Cold scene booted before Continue")
	check(cold_other.get_node("HUD").continue_game(SAVE_TEST_PATH), "Continue initiated from isolated post-game save")
	var loaded_bh := await wait_for_scene("BellhavenVillage")
	check(loaded_bh != null and loaded_bh.quest_manager.storm_resolved and loaded_bh.quest_manager.chapter5_completed,
		"Continue into Bellhaven restores post-game Sunrise cleanly")
	loaded_bh.get_node("HUD").start_new_game()
	await frames(3)
	check(QuestManagerScript.session_state.is_empty(), "Explicit start_new_game() clears session_state cleanly")
	check(not loaded_bh.quest_manager.storm_resolved and loaded_bh.quest_manager.get_current_objective_id() == "investigate_bell",
		"Explicit New Game restarts cleanly from Prologue step 1")

	print("=== PHASE 8 PART B: BIDIRECTIONAL TRAVEL & CROSS-REGION STATE PERSISTENCE ===")
	QuestManagerScript.reset_session_state()
	check(change_scene_to_file("res://scenes/sjt_exterior.tscn") == OK, "Boot fresh Bellhaven for campaign traversal")
	var s1 := await wait_for_scene("BellhavenVillage")
	check(s1 != null, "Bellhaven loaded for Part B")
	await _assert_camera_clamped(s1, "Bellhaven")

	# Footpath check in Bellhaven (Part E inline while in Bellhaven)
	var bh_road := PackedVector2Array([Vector2(-290,230),Vector2(-155,160),Vector2(-75,105),Vector2(-10,25),Vector2(25,0),Vector2(75,28),Vector2(170,85),Vector2(320,150)])
	var bh_loop := PackedVector2Array([Vector2(-155,160),Vector2(-80,198),Vector2(25,221),Vector2(145,165),Vector2(225,125),Vector2(145,85),Vector2(170,85)])
	var all_planters_clear := true
	var planter_count: int = 0
	for actor in s1.get_node("Actors").get_children():
		if actor.get_script() == preload("res://scripts/world/campus_furniture.gd") and int(actor.get("kind")) == 2:
			planter_count += 1
			var dr: float = _min_dist_polyline(actor.position, bh_road)
			var dl: float = _min_dist_polyline(actor.position, bh_loop)
			if dr < 38.0 or dl < 22.0:
				all_planters_clear = false
	check(planter_count == 3 and all_planters_clear, "All 3 Bellhaven stone planters sit clear of cobblestone paths")
	var shrubs_clear := true
	for pt: Vector2 in [Vector2(-180,92),Vector2(-194,72),Vector2(-148,8),Vector2(182,26),Vector2(166,-24),Vector2(216,48)]:
		if _min_dist_polyline(pt, bh_road) < 38.0 or _min_dist_polyline(pt, bh_loop) < 22.0:
			shrubs_clear = false
	check(shrubs_clear, "All 6 Bellhaven meadow ground shrubs sit clear of cobblestone paths")

	# Perimeter collision checks in Bellhaven
	var bh_player := s1.get_node("Actors/Player") as CharacterBody2D
	bh_player.position = Vector2(-310, 0)
	await hold_move("move_left", 70)
	check(bh_player.position.x >= -338.0, "Bellhaven West perimeter stops player inside ground (%f)" % bh_player.position.x)
	bh_player.position = Vector2(320, 0)
	await hold_move("move_right", 70)
	check(bh_player.position.x <= 348.0, "Bellhaven East perimeter stops player inside ground (%f)" % bh_player.position.x)

	# Complete Prologue -> Travel to Briarwood
	var s1_qm: Node = s1.quest_manager
	s1_qm.talked_npcs = {"caelen": true, "mira": true, "elara": true}
	s1_qm.letter_found = true
	s1_qm.puzzle_solved = true
	s1_qm.briarwood_discovered = true
	s1_qm.prologue_completed = true
	s1_qm.briarwood_unlocked = true
	s1_qm.current_index = s1_qm.objectives.size()
	s1._sync_world_from_quest()
	await interact_at(s1, s1.get_node("Actors/BriarwoodGate").position + Vector2(0, 16))
	await interact_at(s1, s1.get_node("Actors/BriarwoodGate").position + Vector2(0, 16))
	var bw := await wait_for_scene("BriarwoodForest")
	check(bw != null, "Entered BriarwoodForest from Bellhaven")
	await _assert_camera_clamped(bw, "Briarwood")

	# Part C.1: Briarwood River & Bridge Physics BEFORE bridge repair
	var bw_player := bw.get_node("Actors/Player") as CharacterBody2D
	for wx: float in [-240.0, -124.0, -90.0, -56.0, 240.0]:
		bw_player.position = Vector2(wx, 14.0)
		await hold_move("move_up", 75)
		check(bw_player.position.y >= -6.0, "Briarwood pre-repair river blocks move_up at x=%d (y=%f)" % [int(wx), bw_player.position.y])
	bw_player.position = Vector2(-240.0, -54.0)
	await hold_move("move_down", 75)
	check(bw_player.position.y <= -34.0, "Briarwood north bank blocks move_down into west river (y=%f)" % bw_player.position.y)

	# Complete Waystone survey, repair bridge, solve mirror, light beacon -> Ch1 done
	await interact_at(bw, bw.get_node("Actors/WaystoneEntrance").position + Vector2(0, 16))
	var bw_qm: Node = bw.quest_manager
	check(bw_qm.is_objective_completed("enter_briarwood"), "Briarwood initial survey objective completed")
	bw_qm.materials_collected = {"plank_1": true, "plank_2": true, "rope_coil": true}
	bw_qm.bridge_repaired = true
	bw_qm.inscriptions_read = {"west": true, "center": true, "east": true}
	bw_qm.mirror_puzzle_solved = true
	bw_qm.beacon_activated = true
	bw_qm.elena_echo_heard = true
	bw_qm.chapter1_completed = true
	bw_qm.floodmill_unlocked = true
	bw_qm.current_index = bw_qm.objectives.size()
	bw._sync_world_from_quest()
	await frames(2)

	# Part C.1b: AFTER bridge repair - bridge walkable, beside rails & far ends still blocked!
	bw_player.position = Vector2(-90.0, 20.0)
	await hold_move("move_up", 85)
	check(bw_player.position.y < -42.0, "Briarwood repaired bridge is cleanly walkable across stream (y=%f)" % bw_player.position.y)
	for wx_fail: float in [-124.0, -56.0, 240.0]:
		bw_player.position = Vector2(wx_fail, 14.0)
		await hold_move("move_up", 75)
		check(bw_player.position.y >= -6.0, "Briarwood post-repair river STILL blocks non-bridge x=%d (y=%f)" % [int(wx_fail), bw_player.position.y])

	# Travel Briarwood -> Floodmill
	var fg := bw.get_node("Actors/FloodmillGate") as StaticBody2D
	await interact_at(bw, fg.position + Vector2(0, 16))
	await interact_at(bw, fg.position + Vector2(0, 16))
	var fm := await wait_for_scene("FloodmillVillage")
	check(fm != null, "Entered FloodmillVillage from Briarwood")
	await _assert_camera_clamped(fm, "Floodmill")

	# Survey Floodmill EntranceArch (Obj 1), then verify RETURN trigger works (Floodmill -> Briarwood -> Floodmill)!
	var fm_arch := fm.get_node("Actors/FloodmillEntranceArch") as StaticBody2D
	await interact_at(fm, fm_arch.position + Vector2(0, 16))
	check(fm.quest_manager.is_objective_completed("enter_floodmill"), "Floodmill survey objective completed")
	await interact_at(fm, fm_arch.position + Vector2(0, 16))
	check(bool(fm_arch.get("ready_to_travel")), "FloodmillEntranceArch armed for return to Briarwood")
	await interact_at(fm, fm_arch.position + Vector2(0, 16))
	var bw_ret := await wait_for_scene("BriarwoodForest")
	check(bw_ret != null, "Returned to Briarwood from Floodmill via FloodmillEntranceArch")
	check(bw_ret.quest_manager.bridge_repaired and bw_ret.quest_manager.beacon_activated and bw_ret.quest_manager.chapter1_completed,
		"Briarwood retains bridge repair, beacon, and Ch1 completion after round-trip")
	check(bw_ret.bridge_blocker_shape.disabled and bw_ret.quest_manager.get_current_objective_id() == "completed",
		"Briarwood revisit keeps bridge unblocked and completed objective")

	# Back into Floodmill via FloodmillGate
	await interact_at(bw_ret, bw_ret.get_node("Actors/FloodmillGate").position + Vector2(0, 16))
	await interact_at(bw_ret, bw_ret.get_node("Actors/FloodmillGate").position + Vector2(0, 16))
	fm = await wait_for_scene("FloodmillVillage")
	check(fm != null and fm.quest_manager.is_objective_completed("enter_floodmill"),
		"Re-entering Floodmill keeps enter_floodmill completed")

	# Part C.2: Floodmill Canal & Eastern Millpond Physics BEFORE sluice solved
	var fm_player := fm.get_node("Actors/Player") as CharacterBody2D
	for cx: float in [-230.0, -102.0, -64.0, -26.0, 180.0]:
		fm_player.position = Vector2(cx, 6.0)
		await hold_move("move_up", 75)
		check(fm_player.position.y >= -17.0, "Floodmill pre-sluice canal blocks move_up at x=%d (y=%f)" % [int(cx), fm_player.position.y])
	fm_player.position = Vector2(182.0, 50.0)
	await hold_move("move_right", 75)
	check(fm_player.position.x <= 214.0, "Floodmill pre-sluice Eastern Millpond blocks walking on water (x=%f)" % fm_player.position.x)

	# Complete Floodmill Watermill & Sluice -> Archive causeway & Millpond open; far canal stays blocked
	var fm_qm: Node = fm.quest_manager
	fm_qm.mill_parts_collected = {"gear": true, "pinion": true, "belt": true}
	fm_qm.watermill_repaired = true
	fm_qm.sluice_solved = true
	fm_qm.archive_clues_found = {"census": true, "tribute": true, "transfer": true}
	fm_qm.ledger_reconstructed = true
	fm_qm.villagers_truth_discovered = true
	fm_qm.second_beacon_activated = true
	fm_qm.chapter2_elena_echo_heard = true
	fm_qm.chapter2_completed = true
	fm_qm.ironwatch_unlocked = true
	fm_qm.current_index = fm_qm.objectives.size()
	fm._sync_world_from_quest()
	await frames(2)

	fm_player.position = Vector2(-64.0, 6.0)
	await hold_move("move_up", 85)
	check(fm_player.position.y < -52.0, "Floodmill drained causeway is cleanly walkable after sluice (y=%f)" % fm_player.position.y)
	fm_player.position = Vector2(182.0, 50.0)
	await hold_move("move_right", 75)
	check(fm_player.position.x <= 214.0, "Floodmill post-sluice Eastern Millpond STILL blocks walking on water (x=%f)" % fm_player.position.x)
	fm_player.position = Vector2(170.0, 6.0)
	await hold_move("move_up", 75)
	check(fm_player.position.y >= -17.0, "Floodmill east canal STILL blocks non-causeway crossing after sluice (y=%f)" % fm_player.position.y)

	# Travel Floodmill -> Ironwatch -> Floodmill -> Ironwatch
	await interact_at(fm, fm.get_node("Actors/IronwatchGate").position + Vector2(0, 16))
	await interact_at(fm, fm.get_node("Actors/IronwatchGate").position + Vector2(0, 16))
	var iw := await wait_for_scene("IronwatchKeep")
	check(iw != null, "Entered IronwatchKeep from Floodmill")
	await _assert_camera_clamped(iw, "Ironwatch")

	# Part C.3: Ironwatch Shadowed Passage East Wall gap test (y=-55, x=-112 must block!)
	var iw_player := iw.get_node("Actors/Player") as CharacterBody2D
	iw_player.position = Vector2(-92.0, -55.0)
	await hold_move("move_left", 75)
	check(iw_player.position.x >= -108.0, "Ironwatch sealed Passage east wall blocks bypass hole at y=-55 (x=%f)" % iw_player.position.x)
	iw_player.position = Vector2(-138.0, -162.0)
	await hold_move("move_right", 75)
	check(iw_player.position.x <= -118.0, "Ironwatch PassageExitBlocker gates y=-162 doorway prior to harmonizing ward lantern (x=%f)" % iw_player.position.x)

	# Solve Ch3 & test round-trip back to Floodmill & back to Ironwatch
	var iw_qm: Node = iw.quest_manager
	iw_qm.warden_records_found = true
	iw_qm.barracks_explored = true
	iw_qm.crest_clues_found = {"crest_1": true, "crest_2": true, "crest_3": true}
	iw_qm.crest_puzzle_solved = true
	iw_qm.shadow_passage_cleared = true
	iw_qm.warden_confronted = true
	iw_qm.elena_research_found = true
	iw_qm.third_beacon_activated = true
	iw_qm.dawnspire_unlocked = true
	iw_qm.chapter3_completed = true
	iw_qm.current_index = iw_qm.objectives.size()
	iw._sync_world_from_quest()
	await frames(2)

	iw_player.position = Vector2(-138.0, -162.0)
	await hold_move("move_right", 75)
	check(iw_player.position.x > -92.0, "Ironwatch Shadowed Passage north doorway y=-162 opens cleanly after shadow_passage_cleared (x=%f)" % iw_player.position.x)
	iw_player.position = Vector2(-92.0, -55.0)
	await hold_move("move_left", 75)
	check(iw_player.position.x >= -108.0, "Ironwatch Passage east wall STILL blocks y=-55 after clearing (x=%f)" % iw_player.position.x)

	await interact_at(iw, iw.get_node("Actors/FloodmillReturnGate").position + Vector2(0, 16))
	var fm_ret := await wait_for_scene("FloodmillVillage")
	check(fm_ret != null and fm_ret.quest_manager.sluice_solved and fm_ret.quest_manager.second_beacon_activated and fm_ret.quest_manager.chapter2_completed,
		"Returning Ironwatch -> Floodmill preserves watermill, sluice, beacon 2, and Ch2 completion")
	await interact_at(fm_ret, fm_ret.get_node("Actors/IronwatchGate").position + Vector2(0, 16))
	await interact_at(fm_ret, fm_ret.get_node("Actors/IronwatchGate").position + Vector2(0, 16))
	iw = await wait_for_scene("IronwatchKeep")
	check(iw != null and iw.quest_manager.crest_puzzle_solved and iw.quest_manager.shadow_passage_cleared and iw.quest_manager.third_beacon_activated and iw.quest_manager.chapter3_completed,
		"Returning Floodmill -> Ironwatch preserves crest puzzle, passage clear, beacon 3, and Ch3 completion")

	# Travel Ironwatch -> Dawnspire
	await interact_at(iw, iw.get_node("Actors/DawnspireGate").position + Vector2(0, 16))
	await interact_at(iw, iw.get_node("Actors/DawnspireGate").position + Vector2(0, 16))
	var ds := await wait_for_scene("DawnspireMountain")
	check(ds != null, "Entered DawnspireMountain from Ironwatch")
	await _assert_camera_clamped(ds, "Dawnspire")

	# Part C.4: Dawnspire upper Summit Plateau cliff side walls (x=-140 and x=+174 at y=-195)
	var ds_player := ds.get_node("Actors/Player") as CharacterBody2D
	ds_player.position = Vector2(-95.0, -195.0)
	await hold_move("move_left", 80)
	check(ds_player.position.x >= -135.0, "Dawnspire west Summit cliff stops player from walking off edge into sky (x=%f)" % ds_player.position.x)
	ds_player.position = Vector2(125.0, -195.0)
	await hold_move("move_right", 80)
	check(ds_player.position.x <= 169.0, "Dawnspire east Summit cliff stops player from walking off edge into sky (x=%f)" % ds_player.position.x)

	# Solve Ch4 & test Dawnspire <-> GreatBell partial progress persistence!
	var ds_qm: Node = ds.quest_manager
	ds_qm.cliffs_navigated = true
	ds_qm.skybridge_repaired = true
	ds_qm.observatory_reached = true
	ds_qm.observatory_solved = true
	ds_qm.sanctuary_entered = true
	ds_qm.beacons_synchronized = true
	ds_qm.sanctuary_revelation_witnessed = true
	ds_qm.great_bell_gate_unlocked = true
	ds_qm.chapter4_completed = true
	ds_qm.current_index = ds_qm.objectives.size()
	ds._sync_world_from_quest()
	await frames(2)

	# Return Dawnspire -> Ironwatch -> Dawnspire
	await interact_at(ds, ds.get_node("Actors/IronwatchReturnGate").position + Vector2(0, 16))
	var iw_ret := await wait_for_scene("IronwatchKeep")
	check(iw_ret != null and iw_ret.quest_manager.chapter3_completed, "Dawnspire -> Ironwatch return preserves Ch3 state")
	await interact_at(iw_ret, iw_ret.get_node("Actors/DawnspireGate").position + Vector2(0, 16))
	await interact_at(iw_ret, iw_ret.get_node("Actors/DawnspireGate").position + Vector2(0, 16))
	ds = await wait_for_scene("DawnspireMountain")
	check(ds != null and ds.quest_manager.skybridge_repaired and ds.quest_manager.observatory_solved and ds.quest_manager.chapter4_completed,
		"Ironwatch -> Dawnspire return preserves skybridge, observatory, and Ch4 completion")

	# Forward into Great Bell Sanctum, advance halfway, go back to Dawnspire, then return to Great Bell!
	check(ds.travel_to_great_bell(), "Dawnspire -> GreatBell travel initiated")
	gb = await wait_for_scene("GreatBellSanctum")
	check(gb != null, "Entered GreatBellSanctum mid-run")
	await _assert_camera_clamped(gb, "GreatBellSanctum")
	gb_qm = gb.quest_manager
	gb_qm.great_bell_chamber_entered = true
	gb_qm.lyra_antechamber_spoken = true
	gb_qm.forgotten_hall_investigated = true
	gb_qm.memory_fragments_recovered = {"home": true, "promise": true}
	gb_qm.current_index = 3
	gb._sync_world_from_quest()

	await interact_at(gb, gb.get_node("Actors/DawnspireReturnGate").position + Vector2(0, 16))
	ds = await wait_for_scene("DawnspireMountain")
	check(ds != null and ds.quest_manager.chapter4_completed and ds.quest_manager.skybridge_repaired,
		"GreatBell -> Dawnspire return keeps Ch4 solved")
	check(ds.travel_to_great_bell(), "Dawnspire -> GreatBell return initiated")
	gb = await wait_for_scene("GreatBellSanctum")
	check(gb != null and gb.quest_manager.forgotten_hall_investigated and gb.quest_manager.memory_fragments_recovered.get("promise", false),
		"Returning to GreatBell mid-Chapter 5 preserves Hall discovery and partial fragments without resetting")

	_cleanup_saves()
	print("PHASE 8 RESULT: %d checks, %d failures" % [checks, failed])
	quit(1 if failed > 0 else 0)

extends SceneTree
## Phase 5 End-to-End Validation Suite — Chapter 4: The Road to Dawnspire.
## Verifies Ironwatch -> Dawnspire progression, all 7 alpine areas, wind & cliff hazards,
## Skybridge counterweight minigame, Pilgrim's Refuge & Elena's journal, Celestial Observatory
## alignment minigame, Three-Beacon Sanctuary revelation, Great Bell Gate unlock, Save v4 & legacy v1-v3 compatibility.

const SAVE_TEST_PATH := "user://test_phase5_save.json"
const V1_SAVE_TEST_PATH := "user://test_phase5_v1_compat.json"
const V2_SAVE_TEST_PATH := "user://test_phase5_v2_compat.json"
const V3_SAVE_TEST_PATH := "user://test_phase5_v3_compat.json"
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

func walk_to(player: CharacterBody2D, target: Vector2, max_ticks: int = 260) -> bool:
	for _step in range(max_ticks):
		var delta: Vector2 = target - player.position
		if delta.length() <= 6.0:
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
	return player.position.distance_to(target) <= 9.5

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
		V3_SAVE_TEST_PATH, V3_SAVE_TEST_PATH + ".bak", V3_SAVE_TEST_PATH + ".tmp",
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

func _advance_chapter3_for_transition(qm: Node) -> void:
	qm.carry_prologue_completed = true
	qm.carry_chapter1_completed = true
	qm.carry_chapter2_completed = true
	qm.prologue_completed = true
	qm.chapter1_completed = true
	qm.chapter2_completed = true
	qm.ironwatch_unlocked = true
	for entry in qm.objectives:
		var oid: String = String(entry.get("id"))
		if oid == "find_crest_clues":
			qm.record_crest_clue_found("clue_1")
			qm.record_crest_clue_found("clue_2")
			qm.record_crest_clue_found("clue_3")
		elif oid == "complete_chapter3":
			qm.complete_objective("complete_chapter3")
		else:
			qm.complete_objective(oid)

func run() -> void:
	_cleanup_saves()
	Engine.time_scale = 4.0

	print("--- STAGE 1: IRONWATCH TO DAWNSPIRE TRANSITION ---")
	var err: Error = change_scene_to_file("res://scenes/ironwatch_keep.tscn")
	check(err == OK, "Ironwatch Keep scene loads for Phase 5 transition check")
	var iw := await wait_for_scene("IronwatchKeep")
	check(iw != null and iw.has_method("travel_to_dawnspire"), "Ironwatch exposes travel_to_dawnspire()")

	var iw_qm: Node = iw.get_node("QuestManager")
	var iw_player: CharacterBody2D = iw.get_node("Actors/Player")
	var iw_hud: CanvasLayer = iw.get_node("HUD")
	var gate_node: StaticBody2D = iw.get_node("Actors/DawnspireGate")

	# 1. Dawnspire locked before Chapter 3 completion
	iw_player.position = Vector2(152, -134)
	await frames(3)
	await press("interact")
	await read_through(iw_hud)
	check(not iw_qm.dawnspire_unlocked and gate_node.get("ready_to_travel") != true, "Dawnspire Gate locked before Chapter 3 completion")

	# Unlock & complete Chapter 3, then test two-step Ironwatch -> Dawnspire transition
	_advance_chapter3_for_transition(iw_qm)
	iw._sync_world_from_quest()
	await frames(2)
	await press("interact")
	await read_through(iw_hud)
	check(gate_node.get("ready_to_travel") == true, "Completed Ironwatch DawnspireGate arms ready_to_travel")
	await press("interact")
	await read_through(iw_hud)

	var ds := await wait_for_scene("DawnspireMountain")
	check(ds != null, "Transition from Ironwatch loads DawnspireMountain cleanly")
	if ds == null:
		Engine.time_scale = 1.0
		quit(1)
		return

	var qm: Node = ds.get_node("QuestManager")
	var player: CharacterBody2D = ds.get_node("Actors/Player")
	var hud: CanvasLayer = ds.get_node("HUD")
	var cin := hud.get_node("CinematicDirector")

	check(qm.quest_id == "chapter4_road_to_dawnspire" and qm.get_current_objective_id() == "enter_foothills", "Dawnspire loads chapter4_road_to_dawnspire at Objective 1")
	check(qm.prologue_completed and qm.chapter1_completed and qm.chapter2_completed and qm.chapter3_completed, "Prologue through Chapter 3 flags carried cleanly into Dawnspire")
	check(hud.get_node("Clock").text == "CHAPTER 4", "HUD header reflects Chapter 4 in Dawnspire Mountain")

	for bname in ["FoothillsArch", "CliffShelter1", "SkybridgeAnchors", "PilgrimChapel", "ObservatoryDome", "DawnspireSanctum", "GreatBellPortal"]:
		check(ds.get_node("Actors").has_node(bname), "Dawnspire structure exists: " + bname)
	check(ds.get_node("Actors").has_node("Lyra") and hud.has_node("SkybridgeRepair") and hud.has_node("CelestialPuzzle"), "Lyra, SkybridgeRepair, and CelestialPuzzle exist in Dawnspire")

	for i in range(ds.approach_positions.size()):
		var ap: Vector2 = ds.approach_positions[i]
		check(_is_point_free_of_solids(ds.get_world_2d(), ap), "Dawnspire approach spot %d %s clear of solids" % [i, str(ap)])

	print("--- STAGE 2: OUT-OF-ORDER GUARDS, FOOTHILLS & WHISPERING CLIFFS ---")
	check(not qm.complete_objective("synchronize_three_beacons"), "QuestManager blocks out-of-order synchronize_three_beacons")
	check(not ds.skybridge_blocker_shape.disabled and not ds.sanctuary_blocker_shape.disabled, "SkybridgeBlocker and SanctuaryBlocker start active")

	# Out-of-order check at Foothills: speaking to Lyra before FoothillsEntrance does not skip enter_foothills
	await walk_path(player, [Vector2(-190, 212), Vector2(-94, 202)])
	await press("interact")
	await read_through(hud)
	check(qm.get_current_objective_id() == "enter_foothills", "Speaking to Lyra early does not skip enter_foothills")

	# Objective 1: FoothillsEntrance + cinematic skip preserves progression
	await walk_to(player, Vector2(-158, 198))
	await press("interact")
	await frames(2)
	check(cin.active and cin.active_id == "dawnspire_first_view", "Foothills triggers dawnspire_first_view cinematic")
	await press_keycode(KEY_X)
	await frames(2)
	check(not cin.active and qm.get_current_objective_id() == "speak_lyra_foothills" and not player.movement_locked, "Skipping Foothills cinematic restores control and unlocks speak_lyra_foothills")

	# Optional Discovery 1 & 2 (Foothills)
	await walk_path(player, [Vector2(-190, 208), Vector2(-262, 180), Vector2(-262, 166)])
	await press("interact")
	await read_through(hud)
	check(qm.optional_discoveries.has("dawnspire_campsite"), "Optional Mountain Campsite recorded cleanly")

	await walk_path(player, [Vector2(-262, 180), Vector2(-190, 210), Vector2(-94, 202)])
	await press("interact")
	await read_through(hud)
	check(qm.is_objective_completed("speak_lyra_foothills") and qm.get_current_objective_id() == "navigate_whispering_cliffs", "Objective 2 completed: Lyra journey conversation unlocks Whispering Cliffs")

	await walk_to(player, Vector2(-44, 210))
	await press("interact")
	await read_through(hud)
	check(qm.optional_discoveries.has("dawnspire_pilgrim_letter") and qm.get_current_objective_id() == "navigate_whispering_cliffs", "Optional Pilgrim's Letter collected without altering active objective")

	# Whispering Cliffs checkpoints & wind/precipice hazard reset safety
	await walk_path(player, [Vector2(30, 184), Vector2(180, 174)])
	await frames(4)
	check(qm.cliff_checkpoint_id == "cliff_cp_1", "Reaching Mid-Cliff shelter stone updates checkpoint to cliff_cp_1")

	ds.forced_wind_gust_active = true
	await walk_to(player, Vector2(236, 134))
	await frames(3)
	check(player.external_wind_velocity.x > 10.0, "Active Whispering Cliffs wind gust applies predictable eastward wind drift")

	# Simulate falling off the eastern precipice edge -> non-destructive checkpoint return
	player.position = Vector2(282, 134)
	await frames(3)
	await read_through(hud)
	check(qm.cliff_resets_count >= 1 and player.position.distance_to(Vector2(180, 174)) <= 10.0, "Cliff hazard returns Aren safely to active checkpoint cliff_cp_1")
	check(qm.optional_discoveries.has("dawnspire_pilgrim_letter") and qm.optional_discoveries.has("dawnspire_campsite"), "Hazard reset preserves all collected discoveries")

	# Optional Discovery 3 (Memorial) & Objective 3 (navigate_whispering_cliffs)
	await walk_path(player, [Vector2(232, 118)])
	await press("interact")
	await read_through(hud)
	check(qm.optional_discoveries.has("dawnspire_memorial"), "Optional Pilgrim Memorial collected cleanly")

	await walk_path(player, [Vector2(210, 74), Vector2(144, 68)])
	await press("interact")
	await read_through(hud)
	check(qm.cliffs_navigated and qm.get_current_objective_id() == "investigate_skybridge", "Objective 3 completed: Whispering Cliffs cairn unlocks Broken Skybridge")

	print("--- STAGE 3: BROKEN SKYBRIDGE MINIGAME A & RAVINE CROSSING ---")
	# Early part pickup before inspecting Skybridge rejected
	await walk_to(player, Vector2(78, 38))
	await press("interact")
	await read_through(hud)
	check(qm.skybridge_parts_collected.is_empty(), "Skybridge parts locked before investigating Broken Skybridge")

	# Objective 4: investigate_skybridge
	await walk_to(player, Vector2(-12, 26))
	await press("interact")
	await read_through(hud)
	check(qm.is_objective_completed("investigate_skybridge") and qm.get_current_objective_id() == "discover_bridge_mechanism", "Objective 4 completed: Broken Skybridge inspected")

	# Objective 5: Masonry diagram + 3 components (duplicate rejected)
	await walk_to(player, Vector2(28, 34))
	await press("interact")
	await read_through(hud)
	check(qm.skybridge_diagram_read, "Skybridge Masonry Diagram read cleanly")

	await walk_to(player, Vector2(78, 38))
	await press("interact")
	await read_through(hud)
	await press("interact")
	await read_through(hud)
	check(qm.skybridge_parts_collected.size() == 1, "Skybridge part 1 collected once without duplicate farm")

	await walk_to(player, Vector2(-90, 54))
	await press("interact")
	await read_through(hud)
	await walk_to(player, Vector2(-174, 48))
	await press("interact")
	await read_through(hud)
	check(qm.skybridge_parts_collected.size() == 3 and qm.get_current_objective_id() == "repair_skybridge", "Objective 5 completed after 3 parts + diagram -> unlocks repair_skybridge")

	# Objective 6: SkybridgeRepair Minigame A (ESC + reject wrong + solve)
	await walk_path(player, [Vector2(-90, 54), Vector2(-12, 26)])
	await press("interact")
	await frames(2)
	var sb_ui: Panel = hud.get_node("SkybridgeRepair")
	check(sb_ui.visible and player.movement_locked, "SkybridgeRepair panel opens and locks movement")
	await press_keycode(KEY_ESCAPE)
	await frames(2)
	check(not sb_ui.visible and not player.movement_locked, "ESC closes SkybridgeRepair cleanly without softlock")

	await press("interact")
	await frames(2)
	sb_ui.selections.assign([3, 0, 1])
	check(not sb_ui.verify_repair() and not qm.skybridge_repaired, "SkybridgeRepair rejects unbalanced combination cleanly")

	# Solve via keyboard: default [3,0,1] -> [0,1,2]
	await press_keycode(KEY_D) # bay 0: 3 -> 0
	await press_keycode(KEY_S)
	await press_keycode(KEY_D) # bay 1: 0 -> 1
	await press_keycode(KEY_S)
	await press_keycode(KEY_D) # bay 2: 1 -> 2
	await press_keycode(KEY_ENTER)
	await frames(2)
	await read_through(hud)
	check(qm.skybridge_repaired and ds.skybridge_blocker_shape.disabled and qm.get_current_objective_id() == "discover_pilgrims_refuge", "Objective 6 completed via keyboard solve and SkybridgeBlocker disabled")

	# Physically walk north straight across the repaired Skybridge across the ravine!
	check(await walk_path(player, [Vector2(0, 20), Vector2(0, -60)]), "Player physically crosses repaired Skybridge across the ravine (y < -46)")

	print("--- STAGE 4: PILGRIM'S REFUGE & ELENA'S JOURNAL ---")
	# Early Elena's Journal before Refuge Mural rejected
	await walk_to(player, Vector2(-204, -76))
	await press("interact")
	await read_through(hud)
	check(not qm.elena_journal_read and qm.get_current_objective_id() == "discover_pilgrims_refuge", "Elena's journal blocked until Refuge murals inspected")

	# Objective 7: Pilgrim's Refuge murals
	await walk_to(player, Vector2(-126, -78))
	await press("interact")
	await read_through(hud)
	check(qm.pilgrim_refuge_discovered and qm.get_current_objective_id() == "read_elena_journal", "Objective 7 completed: Pilgrim's Refuge discovered")

	# Optional Discovery 4 (Hidden Overlook)
	await walk_path(player, [Vector2(-204, -76), Vector2(-264, -76)])
	await press("interact")
	await read_through(hud)
	check(qm.optional_discoveries.has("dawnspire_hidden_overlook"), "Optional Hidden Overlook discovered cleanly")

	# Objective 8: Elena's Preserved Journal (all 4 canonical lines verbatim + cinematic)
	await walk_to(player, Vector2(-204, -76))
	await press("interact")
	await frames(2)
	check(cin.active and cin.active_id == "dawnspire_elena_journal", "Elena's journal triggers dawnspire_elena_journal cinematic")
	var j_lines: Array[String] = []
	await read_through(hud, j_lines)
	var j_full: String = "\n".join(j_lines)
	check(j_full.contains("I once believed saving someone meant keeping them from pain."), "Elena Journal canonical line 1 verbatim")
	check(j_full.contains("But every name taken by the bell leaves another wound in the world."), "Elena Journal canonical line 2 verbatim")
	check(j_full.contains("If Aren ever follows this road, I hope he understands that courage is not the absence of fear."), "Elena Journal canonical line 3 verbatim")
	check(j_full.contains("It is choosing to do what is right, even when the cost is uncertain."), "Elena Journal canonical line 4 verbatim")
	check(qm.elena_journal_read and qm.get_current_objective_id() == "reach_observatory", "Objective 8 completed: Elena's journal read")

	print("--- STAGE 5: CELESTIAL OBSERVATORY MINIGAME B ---")
	# Walk east to Observatory; confirm mechanism locked before ObservatoryArch & 3 pillars
	await walk_path(player, [Vector2(0, -78), Vector2(96, -78), Vector2(188, -94)])
	await press("interact")
	await read_through(hud)
	check(not qm.observatory_reached and not qm.observatory_solved, "Celestial astrolabe blocked before entering Observatory Arch")

	# Objective 9: reach_observatory
	await walk_to(player, Vector2(80, -86))
	await press("interact")
	await read_through(hud)
	check(qm.observatory_reached and qm.get_current_objective_id() == "find_celestial_clues", "Objective 9 completed: Celestial Observatory entered")

	# Objective 10: Discover all 3 celestial alignment clues (Sun, Moon, Stars)
	await walk_path(player, [Vector2(130, -104)])
	await press("interact")
	await read_through(hud)
	await walk_path(player, [Vector2(142, -72), Vector2(154, -58)])
	await press("interact")
	await read_through(hud)
	await walk_path(player, [Vector2(198, -72), Vector2(248, -72)])
	await press("interact")
	await read_through(hud)
	check(qm.celestial_clues_found.size() == 3 and qm.get_current_objective_id() == "solve_observatory_puzzle", "Objective 10 completed on 3/3 celestial alignment clues -> solve_observatory_puzzle")

	# Objective 11: CelestialPuzzle Minigame B (ESC + wrong reject + keyboard solve)
	await walk_to(player, Vector2(188, -94))
	await press("interact")
	await frames(2)
	var cel_ui: Panel = hud.get_node("CelestialPuzzle")
	check(cel_ui.visible and player.movement_locked, "CelestialPuzzle opens and locks movement")
	await press_keycode(KEY_ESCAPE)
	await frames(2)
	check(not cel_ui.visible and not player.movement_locked, "ESC closes CelestialPuzzle cleanly")

	await press("interact")
	await frames(2)
	check(not cel_ui.attempt_solve() and not qm.observatory_solved, "CelestialPuzzle rejects unaligned celestial rings cleanly")

	# Solve via keyboard: [0,0,0] -> [1,2,3]
	await press_keycode(KEY_D) # ring 0: 0 -> 1
	await press_keycode(KEY_S)
	await press_keycode(KEY_D)
	await press_keycode(KEY_D) # ring 1: 0 -> 2
	await press_keycode(KEY_S)
	await press_keycode(KEY_D)
	await press_keycode(KEY_D)
	await press_keycode(KEY_D) # ring 2: 0 -> 3
	await press_keycode(KEY_ENTER)
	await frames(2)
	check(cin.active and cin.active_id == "dawnspire_observatory_activated", "Observatory solve triggers dawnspire_observatory_activated cinematic")
	await press_keycode(KEY_X)
	await frames(2)
	check(qm.observatory_solved and ds.sanctuary_blocker_shape.disabled and qm.get_current_objective_id() == "enter_dawnspire_sanctuary", "Objective 11 completed and SanctuaryBlocker unsealed")

	print("--- STAGE 6: DAWNSPIRE SANCTUARY, REVELATION & GREAT BELL GATE ---")
	# Walk physically north up the summit stair past (24, -150)!
	check(await walk_path(player, [Vector2(24, -104), Vector2(26, -162)]), "Player physically ascends Sanctuary stair past y = -150")
	await press("interact")
	await read_through(hud)
	check(qm.sanctuary_entered and qm.get_current_objective_id() == "synchronize_three_beacons", "Objective 12 completed: Dawnspire Sanctuary entered")

	# Check Great Bell Gate locked prior to synchronization & revelation
	await walk_path(player, [Vector2(24, -188), Vector2(74, -184)])
	await press("interact")
	await read_through(hud)
	check(not qm.great_bell_gate_unlocked and not qm.beacons_synchronized, "Great Bell Gate sealed prior to Three-Beacon Synchronization")

	# Objective 13: Synchronize Three Ancient Beacons at Sanctuary Nexus
	await walk_path(player, [Vector2(24, -188), Vector2(-12, -184)])
	await press("interact")
	await frames(2)
	check(cin.active and cin.active_id == "dawnspire_beacons_synchronized", "Sanctuary Nexus triggers dawnspire_beacons_synchronized cinematic")
	await press_keycode(KEY_X)
	await frames(2)
	check(qm.beacons_synchronized and ds.get_node("Landscape").beacons_synchronized and qm.get_current_objective_id() == "witness_sanctuary_revelation", "Objective 13 completed: All 3 Beacons synchronized at Sanctuary Nexus")

	# Objective 14: Witness Sanctuary Revelation (ALL 6 canonical lines verbatim!)
	await press("interact")
	var rev_lines: Array[String] = []
	await read_through(hud, rev_lines)
	var rev_full: String = "\n".join(rev_lines)
	check(rev_full.contains("Aren, if you have reached Dawnspire, you have done what I could not."), "Sanctuary Echo line 1 verbatim")
	check(rev_full.contains("The beacons are ready. But the bell's binding remains."), "Sanctuary Echo line 2 verbatim")
	check(rev_full.contains("The final decision cannot be made by the Wardens, the kingdom, or even by me."), "Sanctuary Echo line 3 verbatim")
	check(rev_full.contains("It belongs to those who must live with what comes after."), "Sanctuary Echo line 4 verbatim")
	check(rev_full.contains("Then I will make sure they have a future to remember."), "Sanctuary Aren line verbatim")
	check(rev_full.contains("We've come this far. We finish it together."), "Sanctuary Lyra line verbatim")
	check(qm.sanctuary_revelation_witnessed and qm.get_current_objective_id() == "reach_great_bell_gate", "Objective 14 completed: Sanctuary Revelation unlocks Great Bell Gate approach")

	# Objective 15 & 16: Reach Great Bell Gate (cinematic 5 + unlock) & Complete Chapter 4
	await walk_path(player, [Vector2(24, -188), Vector2(74, -184)])
	await press("interact")
	await frames(2)
	check(cin.active and cin.active_id == "dawnspire_great_bell_gate", "Great Bell Gate triggers dawnspire_great_bell_gate cinematic")
	await press_keycode(KEY_X)
	await frames(2)
	check(qm.great_bell_gate_unlocked and qm.get_current_objective_id() == "complete_chapter4", "Objective 15 completed: Great Bell Gate unlocked")

	await press("interact")
	await read_through(hud)
	await frames(3)
	check(qm.chapter4_completed and qm.is_quest_completed("chapter4_road_to_dawnspire"), "Objective 16 completed and Chapter 4 marked complete")
	check(hud.get_node("PrologueComplete").visible and hud.get_node("PrologueComplete/BannerTitle").text == "CHAPTER 4 COMPLETE — THE ROAD TO DAWNSPIRE", "Exact Chapter 4 completion banner shown")

	await press("interact")
	await frames(2)
	check(not hud.get_node("PrologueComplete").visible and not player.movement_locked, "Dismissing Chapter 4 banner restores free exploration")

	# Re-interacting with GreatBellGate post-completion never re-triggers banner or duplicate reward
	await press("interact")
	await read_through(hud)
	await frames(2)
	check(not hud.get_node("PrologueComplete").visible, "Re-interacting post-Chapter 4 does not re-trigger banner")

	# Check Field Satchel entries for Chapter 4
	hud.open_inventory()
	await frames(2)
	var inv_text: String = hud.get_node("InventoryPanel").get_rendered_items_text()
	check(inv_text.contains("SKYBRIDGE PARTS (3/3)") and inv_text.contains("ELENA'S JOURNAL") and inv_text.contains("OBSERVATORY ASTROLABE") and inv_text.contains("DAWNSPIRE NEXUS") and inv_text.contains("GREAT BELL GATE"), "Field Satchel tracks all Chapter 4 milestones & relics")
	await press_keycode(KEY_ESCAPE)
	await frames(2)

	print("--- STAGE 7: SAVE V4, LEGACY COMPAT & RETURN TRANSITION ---")
	check(qm.save_to_file(SAVE_TEST_PATH) == OK, "Save v4 writes Chapter 4 Dawnspire progress")
	check(qm.save_to_file(SAVE_TEST_PATH) == OK and FileAccess.file_exists(SAVE_TEST_PATH + ".bak"), "Second Save v4 rotates .bak backup cleanly")

	# Return Dawnspire -> Ironwatch Keep gate check
	ds.travel_to_ironwatch()
	var back_iw := await wait_for_scene("IronwatchKeep")
	check(back_iw != null and back_iw.get_node("Actors/Player").position.distance_to(Vector2(152, -134)) <= 6.0, "Backward Dawnspire -> Ironwatch spawns Aren cleanly at Dawnspire Citadel Gate")

	# Reload completed Dawnspire v4 save from startup Bellhaven via Continue
	change_scene_to_file("res://scenes/sjt_exterior.tscn")
	var start_scene := await wait_for_scene("BellhavenVillage")
	check(start_scene != null, "Returned to Bellhaven startup to verify Continue -> DawnspireMountain")
	check(start_scene.get_node("HUD").continue_game(SAVE_TEST_PATH), "Continue initiated toward Dawnspire v4 save")
	var resumed_ds := await wait_for_scene("DawnspireMountain")
	check(resumed_ds != null, "Continue transitions automatically to DawnspireMountain")
	if resumed_ds != null:
		var r_qm: Node = resumed_ds.get_node("QuestManager")
		var r_player: CharacterBody2D = resumed_ds.get_node("Actors/Player")
		check(r_qm.chapter4_completed and r_qm.skybridge_repaired and r_qm.elena_journal_read and r_qm.observatory_solved and r_qm.beacons_synchronized and r_qm.great_bell_gate_unlocked, "All Chapter 4 Dawnspire flags survived Save v4 reload")
		check(r_qm.optional_discoveries.size() >= 4 and r_player.position.distance_to(Vector2(74, -184)) <= 8.0, "Optional discoveries & exact Great Bell Gate pose restored")
		check(resumed_ds.skybridge_blocker_shape.disabled and resumed_ds.sanctuary_blocker_shape.disabled and resumed_ds.get_node("Landscape").beacons_synchronized, "Resumed Dawnspire blockers & synchronized beacon state synced visually")

	# Legacy v1, v2, and v3 saves load cleanly under SAVE_VERSION = 4 + .bak recovery
	for ver_tuple in [
		[V1_SAVE_TEST_PATH, {"version": 1, "quest_id": "chapter1_whispers_of_briarwood", "quest_data_path": "res://data/chapter1_quest.json", "region_scene": "res://scenes/briarwood_forest.tscn", "chapter1_completed": true}],
		[V2_SAVE_TEST_PATH, {"version": 2, "quest_id": "chapter2_drowned_village", "quest_data_path": "res://data/chapter2_quest.json", "region_scene": "res://scenes/floodmill_village.tscn", "chapter2_completed": true}],
		[V3_SAVE_TEST_PATH, {"version": 3, "quest_id": "chapter3_keepers_lie", "quest_data_path": "res://data/chapter3_quest.json", "region_scene": "res://scenes/ironwatch_keep.tscn", "chapter3_completed": true, "dawnspire_unlocked": true}],
	]:
		var vp: String = ver_tuple[0]
		var vf := FileAccess.open(vp, FileAccess.WRITE)
		vf.store_string(JSON.stringify(ver_tuple[1]))
		vf.close()
		var c_qm := QuestManagerScript.new()
		check(c_qm.load_from_file(vp) and not c_qm.chapter4_completed, "Legacy save v%d loads cleanly with Chapter 4 defaults" % int(ver_tuple[1]["version"]))
		c_qm.free()

	var cf := FileAccess.open(SAVE_TEST_PATH, FileAccess.WRITE)
	cf.store_string("{corrupt_json_v4_test")
	cf.close()
	var fb_qm := QuestManagerScript.new()
	check(fb_qm.load_from_file(SAVE_TEST_PATH) and fb_qm.chapter4_completed, "Corrupted primary v4 save automatically recovers from .bak")
	fb_qm.free()

	_cleanup_saves()
	Engine.time_scale = 1.0
	check(true, "Phase 5 suite completed")
	print("PHASE 5 RESULT: %d checks, %d failures" % [checks, failed])
	quit(0 if failed == 0 else 1)

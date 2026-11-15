extends SceneTree

const SAVE_TEST_PATH := "user://test_phase3_save.json"
const V1_SAVE_TEST_PATH := "user://test_phase3_v1_compat.json"

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

func hold_move(action: String, tick_count: int) -> void:
	Input.action_press(action)
	await frames(tick_count)
	Input.action_release(action)
	await frames(2)

func _release_move_actions() -> void:
	for act in ["move_up", "move_down", "move_left", "move_right"]:
		if Input.is_action_pressed(act):
			Input.action_release(act)

func walk_to(player: CharacterBody2D, target: Vector2, max_ticks: int = 360) -> bool:
	for _step in range(max_ticks):
		var delta: Vector2 = target - player.position
		if delta.length() <= 5.0:
			_release_move_actions()
			await frames(2)
			return true
		_release_move_actions()
		if absf(delta.x) > 3.5:
			Input.action_press("move_right" if delta.x > 0.0 else "move_left")
		if absf(delta.y) > 3.5:
			Input.action_press("move_down" if delta.y > 0.0 else "move_up")
		await physics_frame
	_release_move_actions()
	await frames(2)
	return player.position.distance_to(target) <= 8.0

func walk_path(player: CharacterBody2D, waypoints: Array) -> bool:
	for pt: Vector2 in waypoints:
		if not await walk_to(player, pt):
			return false
	return true

func read_through(hud: CanvasLayer, captured_lines: Array[String] = []) -> void:
	var safety: int = 12
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
		"user://ashvale_save.json", "user://ashvale_save.json.bak", "user://ashvale_save.json.tmp"
	]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))

func prompt_count(world: Node2D) -> int:
	var visible_count: int = 0
	for obj in get_nodes_in_group("interactables"):
		if world.is_ancestor_of(obj) and obj.has_node("Indicator") and obj.get_node("Indicator").visible:
			visible_count += 1
	return visible_count

func run() -> void:
	_cleanup_saves()
	var ok: Variant = await exercise()
	_release_move_actions()
	_cleanup_saves()
	check(ok == true, "Phase 3 suite completed")
	print("PHASE 3 RESULT: %d checks, %d failures" % [checks, failed])
	quit(1 if failed else 0)

func exercise() -> bool:
	# 1. Requirement 1 & 2: Floodmill locked before Chapter 1 completion; transition works after Chapter 1
	change_scene_to_file("res://scenes/briarwood_forest.tscn")
	var briarwood := await wait_for_scene("BriarwoodForest") as Node2D
	check(briarwood != null and briarwood.has_method("travel_to_floodmill"), "Briarwood loaded and exposes travel_to_floodmill()")

	var b_qm: Node = briarwood.get_node("QuestManager")
	var b_hud: CanvasLayer = briarwood.get_node("HUD")
	var b_player: CharacterBody2D = briarwood.get_node("Actors/Player")
	var floodmill_gate: StaticBody2D = briarwood.get_node("Actors/FloodmillGate")

	b_player.position = Vector2(148, -196)
	await frames(3)
	await press("interact")
	check(not b_qm.floodmill_unlocked and "marsh mist blocks" in b_hud.get_node("Message/Text").text.to_lower(), "Floodmill Gate locked before Chapter 1 completion")
	await read_through(b_hud)

	# Complete Chapter 1 in Briarwood to test genuine gate transition
	for step_id in b_qm.objectives:
		b_qm.complete_objective(String(step_id.get("id")))
	await frames(2)
	check(b_qm.chapter1_completed and b_qm.floodmill_unlocked and floodmill_gate.unlocked, "Chapter 1 completion unlocks Briarwood Floodmill Gate")

	await press("interact")
	check("awaiting chapter 2" in b_hud.get_node("Message/Text").text.to_lower(), "First post-unlock gate interact informs Chapter 2 readiness")
	await read_through(b_hud)
	check(floodmill_gate.ready_to_travel, "Briarwood Floodmill Gate arms ready_to_travel on dismiss")
	await press("interact")
	await read_through(b_hud)

	var world := await wait_for_scene("FloodmillVillage") as Node2D
	check(world != null and world.scene_file_path == "res://scenes/floodmill_village.tscn", "Transition from Briarwood loads FloodmillVillage cleanly")

	var qm: Node = world.get_node("QuestManager")
	var hud: CanvasLayer = world.get_node("HUD")
	var player: CharacterBody2D = world.get_node("Actors/Player")
	var landscape: Node2D = world.get_node("Landscape")
	hud.save_path = SAVE_TEST_PATH

	check(qm.quest_id == "chapter2_drowned_village" and qm.get_current_objective_id() == "enter_floodmill", "Floodmill loads chapter2_drowned_village at Objective 1")
	check(qm.prologue_completed and qm.chapter1_completed, "Prologue and Chapter 1 completion flags carried cleanly into Floodmill")
	check(hud.get_node("Subtitle").text == "FLOODMILL - THE DROWNED VILLAGE" and hud.get_node("Clock").text == "CHAPTER 2", "HUD header reflects Chapter 2 in Floodmill")

	# Verify all Floodmill subareas, NPC, buildings, and UI panels exist
	check(world.get_node_or_null("Actors/MillerCottage") != null and world.get_node_or_null("Actors/RuinedHomestead") != null and world.get_node_or_null("Actors/CanalLockhouse") != null and world.get_node_or_null("Actors/OldWatermill") != null and world.get_node_or_null("Actors/ArchiveHall") != null, "All 5 Floodmill isometric buildings exist")
	var mill_bldg: StaticBody2D = world.get_node("Actors/OldWatermill")
	var lyra: StaticBody2D = world.get_node("Actors/Lyra")
	var broken_mill: StaticBody2D = world.get_node("Actors/BrokenWatermill")
	var sluice_console: StaticBody2D = world.get_node("Actors/SluiceConsole")
	var ledger_table: StaticBody2D = world.get_node("Actors/LedgerTable")
	var second_beacon: StaticBody2D = world.get_node("Actors/SecondBeacon")
	var ironwatch_gate: StaticBody2D = world.get_node("Actors/IronwatchGate")
	var homestead_relic: StaticBody2D = world.get_node("Actors/HomesteadRelic")
	var flood_blocker_shape: CollisionShape2D = world.get_node("ArchiveFloodBlocker/Shape")
	var mill_ui: Panel = hud.get_node("WatermillRepair")
	var sluice_ui: Panel = hud.get_node("SluicePuzzle")
	var ledger_ui: Panel = hud.get_node("LedgerPuzzle")
	var banner: Panel = hud.get_node("PrologueComplete")
	check(mill_ui != null and sluice_ui != null and ledger_ui != null, "WatermillRepair, SluicePuzzle, and LedgerPuzzle UI panels exist")

	# 2. Requirement 15: Verify every Floodmill interaction approach spot is collision-free
	var spots := [
		Vector2(-192, 204), # EntranceArch
		Vector2(-144, 184), # Lyra pos 1
		Vector2(-56, 110),  # VillageMonument
		Vector2(44, 108),   # HomesteadRelic
		Vector2(158, 72),   # BrokenWatermill
		Vector2(108, 58),   # MillDiagram
		Vector2(66, 84),    # MillPartGear
		Vector2(180, 96),   # MillPartPinion
		Vector2(24, 68),    # MillPartBelt
		Vector2(36, 20),    # SluiceConsole
		Vector2(-22, 24),   # CanalGauge
		Vector2(-86, -82),  # ArchiveEntrance
		Vector2(-158, -112),# ArchiveRecordCensus
		Vector2(-134, -122),# ArchiveRecordTribute
		Vector2(-106, -112),# ArchiveRecordTransfer
		Vector2(-134, -92), # LedgerTable
		Vector2(64, -184),  # SecondBeacon
		Vector2(168, -196), # IronwatchGate
	]
	for idx in range(spots.size()):
		check(not player.test_move(Transform2D(0.0, spots[idx]), Vector2.ZERO, null, 0.5), "Floodmill approach spot %d is free of solids" % idx)

	# 3. Requirement 3 & 4: Strict ordering & early-skip lockouts
	check(not qm.complete_objective("restore_watermill"), "QuestManager blocks out-of-order restore_watermill")
	check(not flood_blocker_shape.disabled, "ArchiveFloodBlocker starts active before sluice solved")
	player.position = Vector2(-64, -6)
	await frames(2)
	await hold_move("move_up", 30)
	check(player.position.y > -20.0, "Flooded Archive causeway physically blocks north canal crossing")

	# Early Lyra before entrance arch does not skip Objective 1
	player.position = Vector2(-144, 184)
	await frames(3)
	await press("interact")
	check(qm.get_current_objective_id() == "enter_floodmill", "Speaking to Lyra early does not skip enter_floodmill")
	await read_through(hud)

	# Early mill part blocked before inspecting watermill
	player.position = Vector2(24, 68)
	await frames(3)
	await press("interact")
	check("examine the broken watermill mechanism first" in hud.get_node("Message/Text").text.to_lower(), "Watermill part pickup locked until broken watermill inspected")
	await read_through(hud)

	# 4. Objective 1 & 2: Walk to EntranceArch (-192, 204) -> Lyra (-144, 184)
	player.position = Vector2(-180, 204)
	await frames(2)
	check(await walk_to(player, Vector2(-192, 204)), "Walked physically to Floodmill Entrance Arch")
	await press("interact")
	await read_through(hud)
	check(qm.get_current_objective_id() == "speak_lyra_arrival", "Objective 1 completed: enter_floodmill")

	check(await walk_to(player, Vector2(-144, 184)), "Walked physically to Lyra arrival spot")
	await press("interact")
	var lyra_arr_lines: Array[String] = []
	await read_through(hud, lyra_arr_lines)
	check("no storm drowned this basin" in " ".join(lyra_arr_lines).to_lower(), "Lyra delivers Floodmill arrival revelation")
	check(qm.get_current_objective_id() == "explore_ruined_village", "Objective 2 completed: speak_lyra_arrival")

	# 5. Objective 3: Explore Ruined Village & Census Stone (-56, 110) + Optional Locket
	check(await walk_path(player, [Vector2(-96, 150), Vector2(-56, 110)]), "Walked into Abandoned Village square")
	await press("interact")
	await read_through(hud)
	check(qm.get_current_objective_id() == "discover_watermill", "Objective 3 completed: explore_ruined_village")
	check(lyra.position.distance_to(Vector2(124, 118)) < 1.0, "Lyra advances to Old Watermill courtyard")

	# Optional Homestead Relic does not derail main progression
	check(await walk_path(player, [Vector2(0, 108), Vector2(44, 108)]), "Walked to Weaver Homestead Locket")
	await press("interact")
	await read_through(hud)
	check(qm.optional_discoveries.has("homestead_locket") and homestead_relic.collected, "Optional Weaver Homestead Locket collected")
	check(qm.get_current_objective_id() == "discover_watermill", "Optional homestead relic preserves active objective")

	# 6. Objective 4 & 5: Discover Watermill & collect 3 parts + diagram
	check(await walk_path(player, [Vector2(44, 76), Vector2(158, 72)]), "Walked to Broken Watermill")
	await press("interact")
	await read_through(hud)
	check(qm.get_current_objective_id() == "find_watermill_parts", "Objective 4 completed: discover_watermill")

	check(await walk_to(player, Vector2(108, 58)), "Walked to Millwright Diagram")
	await press("interact")
	var diag_lines: Array[String] = []
	await read_through(hud, diag_lines)
	check("IRON DRIVE GEAR" in " ".join(diag_lines) and "OAK COUPLING BELT" in " ".join(diag_lines), "Millwright diagram provides complete repair order")

	check(await walk_to(player, Vector2(66, 84)), "Walked to Iron Drive Gear")
	await press("interact")
	await read_through(hud)
	check(qm.mill_parts_collected.size() == 1 and "1/3" in hud.get_node("Objective").text, "Collected 1/3 mill parts (Iron Drive Gear)")
	# Anti-farm duplicate pickup test
	await press("interact")
	check("already recovered" in hud.get_node("Message/Text").text.to_lower() and qm.mill_parts_collected.size() == 1, "Duplicate mill part cannot be farmed")
	await read_through(hud)

	check(await walk_to(player, Vector2(180, 96)), "Walked to Bronze Pinion")
	await press("interact")
	await read_through(hud)
	check(qm.mill_parts_collected.size() == 2 and "2/3" in hud.get_node("Objective").text, "Collected 2/3 mill parts (Bronze Pinion)")

	check(await walk_to(player, Vector2(24, 68)), "Walked to Oak Coupling Belt")
	await press("interact")
	await read_through(hud)
	check(qm.mill_parts_collected.size() == 3 and qm.get_current_objective_id() == "restore_watermill", "Objective 5 completed on 3/3 mill parts")

	# Verify Sluice Console stays blocked until Watermill repaired
	check(await walk_to(player, Vector2(36, 20)), "Walked to Sluice Console early")
	await press("interact")
	check("repair the old watermill" in hud.get_node("Message/Text").text.to_lower(), "Sluice Console requires Watermill repair first")
	await read_through(hud)

	# 7. Objective 6: Minigame A — Watermill Repair
	check(await walk_path(player, [Vector2(158, 72)]), "Walked back to Old Watermill")
	await press("interact")
	check(mill_ui.visible and player.movement_locked, "WatermillRepair panel opens and locks movement")
	check(prompt_count(world) == 0, "World prompts hidden while WatermillRepair is open")
	await press("dismiss")
	await frames(2)
	check(not mill_ui.visible and not player.movement_locked, "ESC closes WatermillRepair without softlock")
	await press("interact")
	await frames(2)
	check(mill_ui.visible, "WatermillRepair reopens cleanly after ESC")

	mill_ui.set_slot_part(0, "WARPED COG")
	mill_ui.set_slot_part(1, "IRON DRIVE GEAR")
	mill_ui.set_slot_part(2, "BRONZE PINION")
	check(not mill_ui.verify_repair(), "Incorrect watermill gear sequence rejected")

	# Keyboard solve to [IRON DRIVE GEAR, BRONZE PINION, OAK COUPLING BELT]
	mill_ui.select_slot(0)
	mill_ui.set_slot_part(0, "WARPED COG")
	await press("move_right") # WARPED COG -> IRON DRIVE GEAR
	await press("move_down")
	mill_ui.set_slot_part(1, "IRON DRIVE GEAR")
	await press("move_right") # IRON DRIVE GEAR -> BRONZE PINION
	await press("move_down")
	mill_ui.set_slot_part(2, "BRONZE PINION")
	await press("move_right") # BRONZE PINION -> OAK COUPLING BELT
	await press("interact")
	await frames(2)

	check(not mill_ui.visible and mill_ui.repaired and mill_bldg.watermill_active, "WatermillRepair solves via keyboard and spins waterwheel")
	check(qm.watermill_repaired and broken_mill.repaired and landscape.watermill_repaired, "Objective 6 state synchronized across world and landscape")
	await read_through(hud)
	check(qm.get_current_objective_id() == "investigate_sluice_gates", "Objective 7 unlocked: investigate_sluice_gates")

	await press("interact")
	check(not mill_ui.visible and hud.get_node("Message").visible, "Repaired Watermill does not reopen minigame")
	await read_through(hud)

	# 8. Objective 7 & 8: Canal Sluice Console & Minigame B — Sluice Control
	check(await walk_path(player, [Vector2(86, 48), Vector2(36, 20)]), "Walked to Sluice Console")
	await press("interact")
	await read_through(hud)
	check(qm.get_current_objective_id() == "redirect_water_flow", "Objective 7 completed: investigate_sluice_gates")

	check(await walk_to(player, Vector2(-22, 24)), "Walked to Canal Depth Gauge")
	await press("interact")
	var gauge_lines: Array[String] = []
	await read_through(hud, gauge_lines)
	check("DIVERT - DRAIN - OPEN" in " ".join(gauge_lines), "Canal Depth Gauge reveals sluice protocol clue")

	check(await walk_to(player, Vector2(36, 20)), "Walked back to Sluice Console")
	await press("interact")
	check(sluice_ui.visible and player.movement_locked, "SluicePuzzle opens and locks movement")
	sluice_ui.set_gate_state(0, "OPEN")
	sluice_ui.set_gate_state(1, "CLOSED")
	sluice_ui.set_gate_state(2, "CLOSED")
	check(sluice_ui.get_archive_water_level() > 0 and not sluice_ui.verify_sluice(), "Incorrect sluice configuration leaves water deep and rejects")

	# Keyboard solve to [DIVERT, DRAIN, OPEN]
	sluice_ui.select_gate(0)
	sluice_ui.set_gate_state(0, "DRAIN")
	await press("move_right") # DRAIN -> DIVERT
	await press("move_down")
	sluice_ui.set_gate_state(1, "CLOSED")
	await press("move_right") # CLOSED -> DRAIN
	await press("move_down")
	sluice_ui.set_gate_state(2, "DIVERT")
	await press("move_right") # DIVERT -> OPEN
	await press("interact")
	await frames(2)

	check(not sluice_ui.visible and sluice_ui.solved and flood_blocker_shape.disabled and landscape.sluice_solved, "SluicePuzzle drains causeway and disables ArchiveFloodBlocker")
	check(lyra.position.distance_to(Vector2(-32, -82)) < 1.0, "Lyra crosses north to the Forgotten Archive courtyard")
	await read_through(hud)
	check(qm.get_current_objective_id() == "enter_forgotten_archive", "Objective 8 completed: redirect_water_flow")

	# Physical walk across drained Archive Causeway!
	check(await walk_path(player, [Vector2(36, 24), Vector2(-64, 24), Vector2(-64, -60)]), "Player physically walks north across drained Archive Causeway past y=-50")

	# 9. Objective 9 & 10: Enter Forgotten Archive, gather 3 records, Minigame C — Ledger Reconstruction
	check(await walk_to(player, Vector2(-86, -82)), "Walked to Archive Entrance threshold")
	await press("interact")
	await read_through(hud)
	check(qm.get_current_objective_id() == "reconstruct_village_ledger", "Objective 9 completed: enter_forgotten_archive")

	# Trying Ledger Table BEFORE gathering 3 clues must be rejected cleanly!
	check(await walk_path(player, [Vector2(-86, -94), Vector2(-134, -92)]), "Walked to Master Ledger Table early")
	await press("interact")
	check(not ledger_ui.visible and "inspect all three surviving archive records" in hud.get_node("Message/Text").text.to_lower(), "Ledger reconstruction blocked until all 3 Archive records discovered")
	await read_through(hud)
	ledger_ui.open_puzzle(false)
	ledger_ui.set_entry_choice(0, "THIRTY-SIX HEARTHS")
	ledger_ui.set_entry_choice(1, "MEMORY OFFERING")
	ledger_ui.set_entry_choice(2, "IRONWATCH SEAL")
	check(not ledger_ui.verify_ledger(), "LedgerPuzzle rejects binding if all_clues_discovered is false")
	ledger_ui.close_puzzle()

	# Gather all 3 damaged Archive records inside cutaway Archive hall
	check(await walk_path(player, [Vector2(-158, -92), Vector2(-158, -112)]), "Walked to Torn Parish Roll (Census)")
	await press("interact")
	await read_through(hud)
	check(qm.archive_clues_found.size() == 1 and "1/3" in hud.get_node("Objective").text, "Collected Archive Record 1/3")
	# Duplicate read must not inflate clue count
	await press("interact")
	await read_through(hud)
	check(qm.archive_clues_found.size() == 1, "Re-reading Parish Roll does not duplicate progress")

	check(await walk_to(player, Vector2(-134, -122)), "Walked to Ash-Stained Decree (Edict)")
	await press("interact")
	await read_through(hud)
	check(qm.archive_clues_found.size() == 2 and "2/3" in hud.get_node("Objective").text, "Collected Archive Record 2/3")

	check(await walk_to(player, Vector2(-106, -112)), "Walked to Lockbox Receipt (Vault)")
	await press("interact")
	await read_through(hud)
	check(qm.archive_clues_found.size() == 3 and "3/3" in hud.get_node("Objective").text, "Collected Archive Record 3/3")

	# Ensure Second Beacon still locked prior to Ledger & Truth
	check(await walk_path(player, [Vector2(-86, -94), Vector2(-64, -76), Vector2(-18, -104), Vector2(64, -184)]), "Walked north to sealed Second Beacon")
	await press("interact")
	check("learn the villagers' fate first" in hud.get_node("Message/Text").text.to_lower(), "Second Beacon requires Ledger reconstruction and truth discovery first")
	await read_through(hud)

	# Return to Ledger Table & solve Minigame C
	check(await walk_path(player, [Vector2(-18, -104), Vector2(-64, -76), Vector2(-86, -94), Vector2(-134, -92)]), "Walked back to Ledger Table")
	await press("interact")
	check(ledger_ui.visible and player.movement_locked, "LedgerPuzzle opens cleanly once all 3 records found")
	ledger_ui.set_entry_choice(0, "FLOOD DAMAGE CLAIM")
	ledger_ui.set_entry_choice(1, "THIRTY-SIX HEARTHS")
	ledger_ui.set_entry_choice(2, "MEMORY OFFERING")
	check(not ledger_ui.verify_ledger(), "Incorrect ledger pairing rejected")

	# Keyboard solve to [THIRTY-SIX HEARTHS, MEMORY OFFERING, IRONWATCH SEAL]
	ledger_ui.select_entry(0)
	ledger_ui.set_entry_choice(0, "FLOOD DAMAGE CLAIM")
	await press("move_right") # -> THIRTY-SIX HEARTHS
	await press("move_down")
	ledger_ui.set_entry_choice(1, "THIRTY-SIX HEARTHS")
	await press("move_right") # -> MEMORY OFFERING
	await press("move_down")
	ledger_ui.set_entry_choice(2, "MEMORY OFFERING")
	await press("move_right") # -> IRONWATCH SEAL
	await press("interact")
	await frames(2)

	check(not ledger_ui.visible and ledger_ui.solved and qm.ledger_reconstructed and landscape.ledger_solved, "LedgerPuzzle solves cleanly via keyboard")
	await read_through(hud)
	check(qm.get_current_objective_id() == "discover_villagers_truth", "Objective 10 completed: reconstruct_village_ledger")

	# 10. Objective 11: Examine restored ledger -> Discover Villagers' Truth
	await press("interact")
	var truth_lines: Array[String] = []
	await read_through(hud, truth_lines)
	check("erased in a single winter" in " ".join(truth_lines).to_lower(), "Restored ledger reveals deliberate memory erasure of Floodmill")
	check(qm.villagers_truth_discovered and qm.get_current_objective_id() == "restore_second_beacon", "Objective 11 completed and Lyra moves to Sanctuary")
	check(lyra.position.distance_to(Vector2(114, -196)) < 1.0, "Lyra awaits at Second Beacon Sanctuary")

	# 11. Objective 12, 13, 14: Second Beacon, Canonical Elena Message, Chapter 2 Completion & Ironwatch Unlock
	check(await walk_path(player, [Vector2(-64, -76), Vector2(-18, -104), Vector2(64, -184)]), "Walked to Second Beacon Sanctuary")
	await press("interact")
	await read_through(hud)
	check(qm.second_beacon_activated and second_beacon.activated and landscape.second_beacon_activated, "Objective 12 completed: Second Ancient Beacon restored")
	check(qm.get_current_objective_id() == "witness_elena_message", "Objective 13 unlocked: witness_elena_message")

	await press("interact")
	var elena2_lines: Array[String] = []
	await read_through(hud, elena2_lines)
	var j_elena := " - ".join(elena2_lines)
	check("They did not vanish because the world forgot them." in j_elena, "Canonical Elena line 1 delivered")
	check("They vanished because someone made the world forget." in j_elena, "Canonical Elena line 2 delivered")
	check("Then the bell isn't saving us." in j_elena, "Canonical Aren response delivered")
	check("It may be saving some of us. We need to know who paid the price." in j_elena, "Canonical Lyra response delivered")
	check(qm.chapter2_elena_echo_heard and qm.get_current_objective_id() == "complete_chapter2", "Objective 13 completed: witness_elena_message")

	check(await walk_to(player, Vector2(114, -174)), "Walked to Lyra at Second Beacon Sanctuary")
	await press("interact")
	await read_through(hud)
	await frames(2)
	check(qm.chapter2_completed and qm.ironwatch_unlocked and ironwatch_gate.unlocked, "Objective 14 completed and Ironwatch Keep unlocked")
	check(banner.visible and banner.get_node("BannerTitle").text == "CHAPTER 2 COMPLETE — THE DROWNED VILLAGE", "Exact Chapter 2 completion banner shown")
	await press("interact")
	await frames(2)
	check(not banner.visible and not player.movement_locked, "Dismissing Chapter 2 banner restores free exploration")

	# Re-talking to Lyra must not re-trigger banner
	await press("interact")
	await read_through(hud)
	check(not banner.visible, "Repeated Lyra interaction does not duplicate Chapter 2 completion")

	# Ironwatch Gate reflects Chapter 3 unlock without implementing Chapter 3
	check(await walk_to(player, Vector2(168, -196)), "Walked to Ironwatch Keep Gate")
	await press("interact")
	check("awaiting chapter 3" in hud.get_node("Message/Text").text.to_lower(), "Ironwatch Keep Gate displays unlocked Chapter 3 teaser cleanly")
	await read_through(hud)

	# Field Satchel displays Chapter 2 items and discoveries cleanly
	var inv_panel: Panel = hud.get_node("InventoryPanel")
	await press_keycode(KEY_I)
	await frames(2)
	var satchel_text: String = inv_panel.get_rendered_items_text()
	check("[FITTED IN MILL]" in satchel_text and "SLUICE PROTOCOL" in satchel_text and "ARCHIVE RECORDS (3/3)" in satchel_text and "SILVER LOCKET" in satchel_text and "IRONWATCH KEEP" in satchel_text, "Field Satchel tracks all Chapter 2 items, clues, relics, and echo")
	await press("dismiss")
	await frames(2)

	# 12. Requirement 10 & 11: Save/Load Cross-Region Resume + Phase 2 (v1) Save Migration + Corrupt Backup Fallback
	check(await walk_to(player, Vector2(150, -180)), "Walked to custom Floodmill save position")
	player.facing = 1
	var saved_pose: Vector2 = player.position
	check(hud.manual_save(), "Manual Save persists Chapter 2 state cleanly")
	check(hud.manual_save(), "Second Manual Save rotates .bak backup cleanly")

	# Fresh launch into Bellhaven startup scene, then Continue -> restores exact Floodmill pose & states
	change_scene_to_file("res://scenes/sjt_exterior.tscn")
	var rebooted_start := await wait_for_scene("BellhavenVillage") as Node2D
	var r_hud: CanvasLayer = rebooted_start.get_node("HUD")
	r_hud.save_path = SAVE_TEST_PATH
	check(r_hud.continue_game(), "Continue initiated from Bellhaven startup toward Floodmill")
	var resumed_fm := await wait_for_scene("FloodmillVillage") as Node2D
	check(resumed_fm != null, "Continue transitions automatically to FloodmillVillage")
	var rf_qm: Node = resumed_fm.get_node("QuestManager")
	var rf_player: CharacterBody2D = resumed_fm.get_node("Actors/Player")
	var rf_lyra: StaticBody2D = resumed_fm.get_node("Actors/Lyra")
	var rf_blocker: CollisionShape2D = resumed_fm.get_node("ArchiveFloodBlocker/Shape")
	var rf_ironwatch: StaticBody2D = resumed_fm.get_node("Actors/IronwatchGate")
	check(rf_player.position.is_equal_approx(saved_pose) and rf_player.facing == 1, "Resumed Floodmill player restores exact saved pose and facing")
	check(rf_qm.watermill_repaired and rf_qm.sluice_solved and rf_qm.ledger_reconstructed and rf_qm.villagers_truth_discovered and rf_qm.second_beacon_activated and rf_qm.chapter2_completed and rf_qm.ironwatch_unlocked, "All Chapter 2 quest flags survived reload")
	check(rf_blocker.disabled and rf_ironwatch.unlocked and resumed_fm.get_node("Actors/OldWatermill").watermill_active and resumed_fm.get_node("Landscape").sluice_solved and rf_lyra.position.distance_to(Vector2(114, -196)) < 1.0, "Floodmill mechanical wheel, drained causeway, gate, and Lyra state survived reload")

	# Phase 2 (version 1) save migration compatibility check
	var v1_payload := {
		"version": 1,
		"quest_id": "chapter1_whispers_of_briarwood",
		"quest_data_path": "res://data/chapter1_quest.json",
		"region_scene": "res://scenes/briarwood_forest.tscn",
		"has_player_pose": true,
		"player_x": 148.0,
		"player_y": -196.0,
		"player_facing": 0,
		"current_index": 10,
		"completed_objectives": {"enter_briarwood": true, "complete_chapter1": true},
		"prologue_completed": true,
		"briarwood_unlocked": true,
		"bridge_repaired": true,
		"mirror_puzzle_solved": true,
		"beacon_activated": true,
		"elena_echo_heard": true,
		"chapter1_completed": true,
		"floodmill_unlocked": true
	}
	var vf := FileAccess.open(V1_SAVE_TEST_PATH, FileAccess.WRITE)
	vf.store_string(JSON.stringify(v1_payload))
	vf.close()
	var compat_summary: Dictionary = rf_qm.peek_save_summary(V1_SAVE_TEST_PATH)
	check(bool(compat_summary.get("valid", false)) and rf_qm.load_from_file(V1_SAVE_TEST_PATH), "Phase 2 (v1) save remains 100% compatible without reset")
	check(rf_qm.chapter1_completed and rf_qm.floodmill_unlocked and not rf_qm.chapter2_completed, "Loaded v1 save preserves Chapter 1 completion and safely defaults Chapter 2 fields")

	# Corrupt primary save falls back cleanly to valid .bak
	var cf := FileAccess.open(SAVE_TEST_PATH, FileAccess.WRITE)
	cf.store_string("{corrupted_primary_data")
	cf.close()
	var bak_summary: Dictionary = rf_qm.peek_save_summary(SAVE_TEST_PATH)
	check(bool(bak_summary.get("valid", false)) and String(bak_summary.get("source_file", "")).ends_with(".bak") and rf_qm.load_from_file(SAVE_TEST_PATH) and rf_qm.chapter2_completed, "Corrupted primary save safely falls back to valid .bak backup")

	return true

extends SceneTree
## Comprehensive headless validation of Ashvale Phase 2 — Chapter 1: Whispers of Briarwood.

const SAVE_TEST_PATH := "user://test_phase2_save.json"

var checks: int = 0
var failed: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", description)
	else:
		failed += 1
		push_error("FAIL: " + description)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame

func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame

func hold_move(action: String, physics_steps: int) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	await frames(physics_steps)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame

func read_through_dialogue(hud: CanvasLayer, captured_lines: Array[String] = []) -> void:
	var safety: int = 12
	while hud.get_node("Message").visible and safety > 0:
		safety -= 1
		captured_lines.append(hud.get_node("Message/Text").text)
		await press("interact")
		await frames(1)

func prompt_count(world: Node) -> int:
	var count: int = 0
	for object: Node in get_nodes_in_group("interactables"):
		if world.is_ancestor_of(object) and object.get_node("Indicator").visible:
			count += 1
	return count

func run() -> void:
	var ok: Variant = await exercise()
	check(ok == true, "Phase 2 suite completed")
	print("PHASE 2 RESULT: %d checks, %d failures" % [checks, failed])
	quit(1 if failed else 0)

func _verify_bellhaven_transition() -> void:
	var packed_bellhaven := load("res://scenes/sjt_exterior.tscn") as PackedScene
	check(packed_bellhaven != null, "Bellhaven scene loads for transition test")
	var bellhaven := packed_bellhaven.instantiate() as Node2D
	root.add_child(bellhaven)
	await frames(4)

	var qm: Node = bellhaven.get_node("QuestManager")
	var hud: CanvasLayer = bellhaven.get_node("HUD")
	var player: CharacterBody2D = bellhaven.get_node("Actors/Player")
	var gate: StaticBody2D = bellhaven.get_node("Actors/BriarwoodGate")

	check(bellhaven.has_method("travel_to_briarwood"), "Bellhaven region exposes travel_to_briarwood()")
	check(ResourceLoader.exists("res://scenes/briarwood_forest.tscn"), "Briarwood Forest scene exists at canonical path")

	# Fast-forward prologue state in Bellhaven to test gate arming cleanly
	qm.complete_objective("investigate_bell")
	qm.record_npc_talked("caelen")
	qm.record_npc_talked("mira")
	qm.record_npc_talked("elara")
	qm.complete_objective("find_mothers_letter")
	qm.complete_objective("solve_rune_puzzle")
	qm.complete_objective("discover_briarwood_path")
	qm.complete_objective("trigger_prologue_completion")

	player.position = gate.position + Vector2(18, 12)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message").visible and "awaiting chapter 1" in hud.get_node("Message/Text").text.to_lower(), "Post-prologue Briarwood Gate shows transition message first")
	await read_through_dialogue(hud)
	await frames(2)
	check(gate.get("ready_to_travel") == true, "Closing post-prologue gate message arms ready_to_travel")
	check("ENTER BRIARWOOD FOREST" in gate.prompt_text, "Gate prompt updates to [E] ENTER BRIARWOOD FOREST")
	await press("interact")
	check(hud.get_node("Message").visible and "stepping through the awakened gate" in hud.get_node("Message/Text").text.to_lower(), "Second gate interact opens Briarwood departure message")

	bellhaven.queue_free()
	await process_frame

func exercise() -> bool:
	await _verify_bellhaven_transition()

	var packed := load("res://scenes/briarwood_forest.tscn") as PackedScene
	check(packed != null, "Briarwood Forest scene loads")
	var world := packed.instantiate() as Node2D
	root.add_child(world)
	await frames(4)

	var qm: Node = world.get_node("QuestManager")
	var hud: CanvasLayer = world.get_node("HUD")
	var player: CharacterBody2D = world.get_node("Actors/Player")
	var lyra: StaticBody2D = world.get_node("Actors/Lyra")
	var waystone: StaticBody2D = world.get_node("Actors/WaystoneEntrance")
	var sign: StaticBody2D = world.get_node("Actors/DirectionSign")
	var bridge: StaticBody2D = world.get_node("Actors/BrokenBridge")
	var ledger: StaticBody2D = world.get_node("Actors/WorksiteLedger")
	var plank1: StaticBody2D = world.get_node("Actors/MaterialPlank1")
	var plank2: StaticBody2D = world.get_node("Actors/MaterialPlank2")
	var rope: StaticBody2D = world.get_node("Actors/MaterialRope")
	var insc_w: StaticBody2D = world.get_node("Actors/InscriptionWest")
	var insc_c: StaticBody2D = world.get_node("Actors/InscriptionCenter")
	var insc_e: StaticBody2D = world.get_node("Actors/InscriptionEast")
	var mirror_dais: StaticBody2D = world.get_node("Actors/MirrorDais")
	var beacon: StaticBody2D = world.get_node("Actors/FirstBeacon")
	var hidden_relic: StaticBody2D = world.get_node("Actors/HiddenRelic")
	var floodmill_gate: StaticBody2D = world.get_node("Actors/FloodmillGate")
	var bridge_blocker_shape: CollisionShape2D = world.get_node("BridgeBlocker/Shape")
	var landscape: Node2D = world.get_node("Landscape")
	var bridge_ui: Panel = hud.get_node("BridgeRepair")
	var mirror_ui: Panel = hud.get_node("MirrorPuzzle")
	var banner: Panel = hud.get_node("PrologueComplete")

	check(qm != null and qm.quest_id == "chapter1_whispers_of_briarwood", "Briarwood QuestManager loads chapter1_whispers_of_briarwood")
	check(lyra != null and waystone != null and sign != null and bridge != null and ledger != null, "Forest Edge & Fork actors exist")
	check(plank1 != null and plank2 != null and rope != null and insc_w != null and insc_c != null and insc_e != null, "Worksite supplies and inscriptions exist")
	check(mirror_dais != null and beacon != null and hidden_relic != null and floodmill_gate != null, "Mirror Grove, Beacon, Ruined Camp & Floodmill Gate exist")
	check(bridge_ui != null and mirror_ui != null and banner != null, "Phase 2 minigame UI panels and banner exist")
	check(qm.get_current_objective_id() == "enter_briarwood", "Starts at Objective 1: enter_briarwood")
	check(hud.get_node("Objective").text == "Follow the lantern trail into Briarwood Forest.", "HUD displays Objective 1")
	check(hud.get_node("Subtitle").text == "BRIARWOOD FOREST" and hud.get_node("Clock").text == "CHAPTER 1", "HUD header reflects Chapter 1 in Briarwood Forest")

	# Verify all 15 interaction spots are collision-free
	var spots := [
		Vector2(-20, 204),  # WaystoneEntrance
		Vector2(28, 192),   # Lyra Pos 1
		Vector2(0, 102),    # DirectionSign
		Vector2(-90, 18),   # BrokenBridge
		Vector2(138, 72),   # WorksiteLedger
		Vector2(188, 58),   # MaterialPlank1
		Vector2(184, 106),  # MaterialPlank2
		Vector2(116, 106),  # MaterialRope
		Vector2(-156, -84), # InscriptionWest
		Vector2(8, -92),    # InscriptionCenter
		Vector2(106, -78),  # InscriptionEast
		Vector2(-132, -124),# MirrorDais
		Vector2(-32, -192), # FirstBeacon
		Vector2(174, -138), # HiddenRelic
		Vector2(148, -196), # FloodmillGate
	]
	for idx in range(spots.size()):
		var xf := player.global_transform
		xf.origin = spots[idx]
		check(not player.test_move(xf, Vector2(0, 0.1)), "Briarwood interaction spot %d is free of solids" % idx)

	# Anti-skip checks before completing enter_briarwood
	check(not qm.complete_objective("repair_bridge"), "QuestManager blocks out-of-order repair_bridge")
	check(not bridge_blocker_shape.disabled, "BridgeBlocker starts active before repair")
	player.position = Vector2(-90, 18)
	await frames(2)
	check(player.test_move(player.global_transform, Vector2(0, -40)), "Collapsed bridge physically blocks north river crossing")

	# Early Lyra before inspecting Waystone does NOT advance meet_lyra
	player.position = Vector2(28, 192)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message").visible and hud.get_node("Message/Source").text == "HISTORIAN LYRA", "Lyra can speak before threshold")
	await read_through_dialogue(hud)
	check(qm.get_current_objective_id() == "enter_briarwood", "Speaking with Lyra early does not skip enter_briarwood")

	# Early material pickup & bridge inspect & floodmill gate locked checks
	player.position = Vector2(188, 58)
	await frames(3)
	await press("interact")
	check("meet lyra and inspect the broken bridge first" in hud.get_node("Message/Text").text.to_lower(), "Material pickup locked until bridge inspected")
	await read_through_dialogue(hud)

	player.position = Vector2(-90, 18)
	await frames(3)
	await press("interact")
	check("meet lyra at the forest edge" in hud.get_node("Message/Text").text.to_lower(), "Broken bridge tells player to meet Lyra first")
	await read_through_dialogue(hud)

	# Objective 1: Inspect Trail Waystone (enter_briarwood)
	player.position = Vector2(-20, 204)
	await frames(3)
	check(waystone.selected and prompt_count(world) == 1, "Single prompt active at WaystoneEntrance")
	await press("interact")
	check(hud.get_node("Message").visible and hud.get_node("Message/Source").text == "BRIARWOOD TRAIL STONE", "Waystone dialogue opens")
	await read_through_dialogue(hud)
	check(qm.is_objective_completed("enter_briarwood"), "Objective 1 completed")
	check(qm.get_current_objective_id() == "meet_lyra", "Objective 2 unlocked: meet_lyra")

	# Objective 2: Meet Historian Lyra (canonical dialogue lines verified)
	player.position = Vector2(28, 192)
	await frames(3)
	await press("interact")
	var lyra_lines: Array[String] = []
	await read_through_dialogue(hud, lyra_lines)
	var joined_lyra: String = " | ".join(lyra_lines)
	check("You came from Bellhaven, didn't you?" in joined_lyra, "Lyra speaks canonical Bellhaven recognition line")
	check("Because the forest has been whispering that name since the thirteenth toll." in joined_lyra, "Lyra speaks canonical thirteenth toll line")
	check(qm.is_objective_completed("meet_lyra"), "Objective 2 completed")
	check(qm.get_current_objective_id() == "investigate_bridge", "Objective 3 unlocked: investigate_bridge")

	# Verify Direction Sign at Whispering Fork works cleanly
	player.position = Vector2(0, 102)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message/Source").text == "WHISPERING FORK SIGN", "Direction sign reads cleanly")
	await read_through_dialogue(hud)

	# Objective 3: Investigate Old Bridge
	player.position = Vector2(-90, 18)
	await frames(3)
	await press("interact")
	check(hud.get_node("Message/Source").text == "OLD BRIDGE", "Broken bridge inspection dialogue opens")
	await read_through_dialogue(hud)
	check(qm.is_objective_completed("investigate_bridge"), "Objective 3 completed")
	check(qm.get_current_objective_id() == "find_repair_materials", "Objective 4 unlocked: find_repair_materials")

	# Worksite ledger reveals repair sequence clue
	player.position = Vector2(138, 72)
	await frames(3)
	await press("interact")
	var ledger_lines: Array[String] = []
	await read_through_dialogue(hud, ledger_lines)
	var ledger_text: String = " ".join(ledger_lines)
	check("LEFT BEAM" in ledger_text and "RIGHT PLANK" in ledger_text and "ROPE LASHING" in ledger_text, "Carpenter's ledger gives complete bridge repair sequence clue")

	# Objective 4: Gather 2 Oak Planks + 1 Rope Coil (anti-farm check included)
	player.position = Vector2(188, 58)
	await frames(3)
	await press("interact")
	await read_through_dialogue(hud)
	check(qm.materials_collected.size() == 1 and "1/3" in hud.get_node("Objective").text, "Collected 1/3 repair materials (Left Beam)")
	# Anti-farm duplicate pickup test
	await press("interact")
	check("already gathered" in hud.get_node("Message/Text").text.to_lower(), "Already gathered material cannot be farmed again")
	await read_through_dialogue(hud)
	check(qm.materials_collected.size() == 1, "Duplicate pickup does not inflate material count")

	player.position = Vector2(184, 106)
	await frames(3)
	await press("interact")
	await read_through_dialogue(hud)
	check(qm.materials_collected.size() == 2 and "2/3" in hud.get_node("Objective").text, "Collected 2/3 repair materials (Right Plank)")

	player.position = Vector2(116, 106)
	await frames(3)
	await press("interact")
	await read_through_dialogue(hud)
	check(qm.materials_collected.size() == 3 and qm.is_objective_completed("find_repair_materials"), "Objective 4 completed on 3/3 materials")
	check(qm.get_current_objective_id() == "repair_bridge", "Objective 5 unlocked: repair_bridge")

	# Objective 5: Minigame A — Bridge Repair
	player.position = Vector2(-90, 18)
	await frames(3)
	await press("interact")
	check(bridge_ui.visible and player.movement_locked, "Bridge repair UI opens and locks movement")
	check(prompt_count(world) == 0, "World prompts hidden while Bridge Repair UI is open")
	await press("dismiss")
	await frames(2)
	check(not bridge_ui.visible and not player.movement_locked and qm.get_current_objective_id() == "repair_bridge", "ESC closes Bridge Repair without softlock")
	await press("interact")
	await frames(2)
	check(bridge_ui.visible and player.movement_locked, "Bridge Repair UI reopens cleanly after ESC")

	# Wrong combination test
	bridge_ui.set_step_material(0, "LOOSE TIMBER")
	bridge_ui.set_step_material(1, "LEFT BEAM")
	bridge_ui.set_step_material(2, "RIGHT PLANK")
	check(not bridge_ui.verify_repair(), "Incorrect bridge assembly sequence rejected")
	check(bridge_ui.visible and qm.get_current_objective_id() == "repair_bridge", "Incorrect repair does not advance quest")

	# Keyboard solve to [LEFT BEAM, RIGHT PLANK, ROPE LASHING]
	bridge_ui.select_step(0)
	bridge_ui.set_step_material(0, "RIGHT PLANK")
	await press("move_left")  # RIGHT PLANK -> LEFT BEAM
	await press("move_down")  # step 1
	bridge_ui.set_step_material(1, "LEFT BEAM")
	await press("move_right") # LEFT BEAM -> RIGHT PLANK
	await press("move_down")  # step 2
	bridge_ui.set_step_material(2, "RIGHT PLANK")
	await press("move_right") # RIGHT PLANK -> ROPE LASHING
	await press("interact")   # confirm
	await frames(2)

	check(not bridge_ui.visible and bridge_ui.repaired, "Bridge Repair minigame solves cleanly via keyboard")
	check(qm.is_objective_completed("repair_bridge") and qm.bridge_repaired, "Objective 5 completed")
	check(bridge_blocker_shape.disabled and bridge.repaired and landscape.bridge_repaired, "BridgeBlocker disabled and repaired bridge rendered")
	check(lyra.position.distance_to(Vector2(-40, -76)) < 1.0, "Lyra relocates to northern bank ruins after bridge repair")
	await read_through_dialogue(hud)
	check(qm.get_current_objective_id() == "discover_inscriptions", "Objective 6 unlocked: discover_inscriptions")

	# Verify solved bridge does not reopen minigame
	await press("interact")
	check(not bridge_ui.visible and hud.get_node("Message").visible, "Repaired bridge shows story text instead of reopening minigame")
	await read_through_dialogue(hud)

	# Physical bridge crossing walk test using move_up
	player.position = Vector2(-90, 18)
	await frames(2)
	await hold_move("move_up", 45)
	check(player.position.y < -40.0, "Player physically walks north across repaired Old Bridge past river (y=%.1f)" % player.position.y)

	# Verify optional Ruined Camp Hidden Relic does not break main progression
	player.position = Vector2(174, -138)
	await frames(3)
	await press("interact")
	await read_through_dialogue(hud)
	check(qm.optional_discoveries.has("ruined_camp_relic") and hidden_relic.collected, "Optional Ruined Camp survey chest discovery recorded")
	check(qm.get_current_objective_id() == "discover_inscriptions", "Optional discovery preserves active main objective")

	# Verify Floodmill Gate stays locked before beacon & completion
	player.position = Vector2(148, -196)
	await frames(3)
	await press("interact")
	check(not qm.floodmill_unlocked and "marsh mist blocks" in hud.get_node("Message/Text").text.to_lower(), "Floodmill Gate remains sealed prior to Chapter 1 completion")
	await read_through_dialogue(hud)

	# Objective 6: Discover 3 Ancient Inscriptions (DAWN, ZENITH, DUSK)
	player.position = Vector2(-156, -84)
	await frames(3)
	await press("interact")
	var iw_lines: Array[String] = []
	await read_through_dialogue(hud, iw_lines)
	check("DAWN" in " ".join(iw_lines) and qm.inscriptions_read.size() == 1, "West inscription reveals DAWN clue (1/3)")

	player.position = Vector2(8, -92)
	await frames(3)
	await press("interact")
	var ic_lines: Array[String] = []
	await read_through_dialogue(hud, ic_lines)
	check("ZENITH" in " ".join(ic_lines) and qm.inscriptions_read.size() == 2, "Center inscription reveals ZENITH clue (2/3)")

	player.position = Vector2(106, -78)
	await frames(3)
	await press("interact")
	var ie_lines: Array[String] = []
	await read_through_dialogue(hud, ie_lines)
	check("DUSK" in " ".join(ie_lines) and qm.inscriptions_read.size() == 3, "East inscription reveals DUSK clue (3/3)")
	check(qm.is_objective_completed("discover_inscriptions"), "Objective 6 completed after all 3 inscriptions")
	check(qm.get_current_objective_id() == "solve_mirror_puzzle", "Objective 7 unlocked: solve_mirror_puzzle")

	# Early Beacon blocked by mirror ward
	player.position = Vector2(-32, -192)
	await frames(3)
	await press("interact")
	check("mirror-ward seals off" in hud.get_node("Message/Text").text.to_lower(), "First Beacon stays sealed until Mirror Grove solved")
	await read_through_dialogue(hud)

	# Objective 7: Minigame B — Mirror Grove Light Puzzle
	player.position = Vector2(-132, -124)
	await frames(3)
	await press("interact")
	check(mirror_ui.visible and player.movement_locked, "Mirror Grove UI opens and locks movement")
	await press("dismiss")
	await frames(2)
	check(not mirror_ui.visible and not player.movement_locked, "ESC closes Mirror Grove UI without softlock")
	await press("interact")
	await frames(2)
	check(mirror_ui.visible, "Mirror Grove UI reopens cleanly")

	# Wrong combination test
	mirror_ui.set_mirror_angle(0, "HORIZON")
	mirror_ui.set_mirror_angle(1, "DAWN")
	mirror_ui.set_mirror_angle(2, "HORIZON")
	check(not mirror_ui.verify_mirrors(), "Incorrect mirror alignment rejected")
	check(mirror_ui.visible and qm.get_current_objective_id() == "solve_mirror_puzzle", "Incorrect mirror alignment does not complete quest")

	# Keyboard solve to [DAWN, ZENITH, DUSK]
	mirror_ui.select_mirror(0)
	mirror_ui.set_mirror_angle(0, "HORIZON")
	await press("move_right") # HORIZON -> DAWN
	await press("move_down")  # Center mirror
	mirror_ui.set_mirror_angle(1, "DAWN")
	await press("move_right") # DAWN -> ZENITH
	await press("move_down")  # East mirror
	mirror_ui.set_mirror_angle(2, "ZENITH")
	await press("move_right") # ZENITH -> DUSK
	await press("interact")   # confirm
	await frames(2)

	check(not mirror_ui.visible and mirror_ui.solved, "Mirror puzzle solves cleanly via keyboard")
	check(qm.is_objective_completed("solve_mirror_puzzle") and qm.mirror_puzzle_solved, "Objective 7 completed")
	check(mirror_dais.activated and landscape.mirror_solved, "Mirror Grove dais and sunbeams light up")
	check(lyra.position.distance_to(Vector2(28, -206)) < 1.0, "Lyra moves up to First Beacon Shrine")
	await read_through_dialogue(hud)
	check(qm.get_current_objective_id() == "activate_first_beacon", "Objective 8 unlocked: activate_first_beacon")

	# Post-solve dais check
	await press("interact")
	check(not mirror_ui.visible and hud.get_node("Message").visible, "Solved mirror dais shows post-solve lore instead of reopening puzzle")
	await read_through_dialogue(hud)

	# Objective 8 & 9: Activate First Beacon & Experience Elena's Memory Echo
	player.position = Vector2(-32, -192)
	await frames(3)
	await press("interact")
	await read_through_dialogue(hud)
	check(qm.is_objective_completed("activate_first_beacon") and qm.beacon_activated, "Objective 8 completed: First Ancient Beacon activated")
	check(beacon.activated and landscape.beacon_activated, "First Beacon glow active in world")
	check(qm.get_current_objective_id() == "experience_elena_recording", "Objective 9 unlocked: experience_elena_recording")

	await press("interact")
	var elena_lines: Array[String] = []
	await read_through_dialogue(hud, elena_lines)
	var joined_elena: String = " | ".join(elena_lines)
	check("If you found this, Aren, then the first beacon still remembers." in joined_elena, "Canonical Elena memory echo line 1 delivered")
	check("There are truths the bell was built to silence. Find the others." in joined_elena, "Canonical Elena memory echo line 2 delivered")
	check(qm.is_objective_completed("experience_elena_recording") and qm.elena_echo_heard, "Objective 9 completed: Elena recording heard")
	check(qm.get_current_objective_id() == "complete_chapter1", "Objective 10 unlocked: complete_chapter1")

	# Objective 10: Speak with Lyra at Beacon Shrine -> Chapter 1 Complete + Floodmill Unlocked
	player.position = Vector2(28, -186)
	await frames(3)
	await press("interact")
	await read_through_dialogue(hud)
	await frames(2)
	check(qm.is_objective_completed("complete_chapter1") and qm.chapter1_completed and qm.floodmill_unlocked, "Objective 10 completed and Floodmill Gate unlocked")
	check(floodmill_gate.unlocked, "Floodmill Gate node reflects unlocked state")
	check(banner.visible and banner.get_node("BannerTitle").text == "CHAPTER 1 COMPLETE — WHISPERS OF BRIARWOOD", "Exact Chapter 1 completion banner shown")

	await press("interact")
	await frames(2)
	check(not banner.visible and not player.movement_locked, "Dismissing Chapter 1 banner restores free exploration")
	check(hud.get_node("Objective").text == "Chapter 1 Complete - Floodmill Unlocked.", "HUD updates cleanly after Chapter 1 completion")

	# Unlocked Floodmill Gate note check
	player.position = Vector2(148, -196)
	await frames(3)
	await press("interact")
	check("awaiting chapter 2" in hud.get_node("Message/Text").text.to_lower(), "Floodmill Gate reflects unlocked Chapter 2 transition")
	await read_through_dialogue(hud)

	# Save/load persistence verification across fresh Briarwood scene instantiation
	var save_err: int = qm.save_to_file(SAVE_TEST_PATH)
	check(save_err == OK and FileAccess.file_exists(SAVE_TEST_PATH), "Atomic save writes Chapter 1 progress to JSON file")
	world.queue_free()
	await process_frame

	var world2 := packed.instantiate() as Node2D
	root.add_child(world2)
	await frames(4)
	var loaded_ok: bool = world2.apply_saved_state(SAVE_TEST_PATH)
	var qm2: Node = world2.get_node("QuestManager")
	var bridge_blocker_2: CollisionShape2D = world2.get_node("BridgeBlocker/Shape")
	var lyra2: StaticBody2D = world2.get_node("Actors/Lyra")
	check(loaded_ok and qm2.chapter1_completed and qm2.floodmill_unlocked and qm2.optional_discoveries.has("ruined_camp_relic"), "Fresh Briarwood scene restores full saved state")
	check(bridge_blocker_2.disabled and world2.get_node("Landscape").mirror_solved and world2.get_node("Landscape").beacon_activated, "Saved visual/physics world state synchronized cleanly")
	check(lyra2.position.distance_to(Vector2(28, -206)) < 1.0, "Saved Lyra story position restored accurately")

	# Cleanup temporary save artifacts
	for cleanup_path in [SAVE_TEST_PATH, SAVE_TEST_PATH + ".bak", SAVE_TEST_PATH + ".tmp"]:
		if FileAccess.file_exists(cleanup_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(cleanup_path))

	world2.queue_free()
	await process_frame
	return true

extends SceneTree
## Phase 6 End-to-End Validation Suite — Chapter 5: The Last Bell & Post-Game Epilogue.
## Verifies Dawnspire -> Great Bell Sanctum transition, all 4 sanctum areas, 14 chronological
## objectives, sequence gating, canonical Elena & Epilogue dialogue, Last Bell climax cinematic,
## EndingCredits UI & post-game actions, Sunrise Bellhaven state, Save v5, v1-v4 migration,
## and post-game Continue behavior without ending-loop trapping.

const SAVE_TEST_PATH := "user://test_phase6_save.json"
const POSTGAME_SAVE_PATH := "user://test_phase6_postgame.json"
const V1_SAVE_TEST_PATH := "user://test_phase6_v1.json"
const V2_SAVE_TEST_PATH := "user://test_phase6_v2.json"
const V3_SAVE_TEST_PATH := "user://test_phase6_v3.json"
const V4_SAVE_TEST_PATH := "user://test_phase6_v4.json"
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

func walk_to(player: CharacterBody2D, target: Vector2, max_ticks: int = 280) -> bool:
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
	var safety: int = 20
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
		POSTGAME_SAVE_PATH, POSTGAME_SAVE_PATH + ".bak", POSTGAME_SAVE_PATH + ".tmp",
		V1_SAVE_TEST_PATH, V2_SAVE_TEST_PATH, V3_SAVE_TEST_PATH, V4_SAVE_TEST_PATH,
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

func _complete_chapter4_prerequisites(qm: Node) -> void:
	qm.start_chapter4()
	qm.record_optional_discovery("ruined_camp_relic")
	qm.record_optional_discovery("homestead_locket")
	qm.record_optional_discovery("wardens_locket")
	qm.record_optional_discovery("dawnspire_memorial")
	for obj in [
		"enter_foothills", "speak_lyra_foothills", "navigate_whispering_cliffs",
		"investigate_skybridge", "discover_bridge_mechanism", "repair_skybridge",
		"discover_pilgrims_refuge", "read_elena_journal", "reach_observatory",
		"find_celestial_clues", "solve_observatory_puzzle", "enter_dawnspire_sanctuary",
		"synchronize_three_beacons", "witness_sanctuary_revelation", "reach_great_bell_gate",
		"complete_chapter4"
	]:
		qm.complete_objective(obj)

func run() -> void:
	_cleanup_saves()
	Engine.time_scale = 8.0

	print("--- STAGE 1: DAWNSPIRE -> GREAT BELL GATE GATING & TRANSITION ---")
	change_scene_to_file("res://scenes/dawnspire_mountain.tscn")
	var ds := await wait_for_scene("DawnspireMountain")
	check(ds != null, "DawnspireMountain scene boots cleanly for Phase 6 transition check")
	if ds == null:
		quit(1)
		return
	var ds_qm: Node = ds.get_node("QuestManager")
	check(not ds.travel_to_great_bell(), "Great Bell Sanctum travel locked before Chapter 4 completion")

	_complete_chapter4_prerequisites(ds_qm)
	ds._sync_world_from_quest()
	check(ds.travel_to_great_bell(), "Great Bell Sanctum travel succeeds once Chapter 4 & Gate are unlocked")
	var gb := await wait_for_scene("GreatBellSanctum")
	check(gb != null and gb.name == "GreatBellSanctum", "Transitioned cleanly into GreatBellSanctum scene")
	if gb == null:
		quit(1)
		return

	var qm: Node = gb.get_node("QuestManager")
	var hud: CanvasLayer = gb.get_node("HUD")
	var player: CharacterBody2D = gb.get_node("Actors/Player")
	var cin: Control = hud.get_node("CinematicDirector")
	hud._region_fade_alpha = 0.0
	if hud.region_banner != null:
		hud.region_banner.visible = false

	check(qm.quest_id == "chapter5_the_last_bell" and qm.chapter5_active, "Chapter 5 quest_id active upon entering Great Bell Sanctum")
	check(qm.get_current_objective_id() == "enter_great_bell_chamber", "Initial Chapter 5 objective is enter_great_bell_chamber")
	check(qm.optional_discoveries.has("ruined_camp_relic") and qm.optional_discoveries.has("homestead_locket"), "Carry-over optional discoveries preserved into Chapter 5")

	# Verify all approach positions in GreatBellSanctum are free of solid overlap
	var w2d: World2D = gb.get_world_2d()
	var blocked_spots: int = 0
	for ap: Vector2 in gb.approach_positions:
		if not _is_point_free_of_solids(w2d, ap):
			blocked_spots += 1
			print("FAIL DETAIL: Approach spot blocked by solid collider at ", ap)
	check(blocked_spots == 0, "All GreatBellSanctum approach coordinates sit outside solid colliders")

	print("--- STAGE 2: BELL ANTECHAMBER & HALL OF FORGOTTEN NAMES ---")
	# Check early gating on Forgotten Hall & Memory Fragments
	await walk_to(player, Vector2(-152, 206))
	check(not qm.investigate_forgotten_hall(), "Hall of Forgotten Names blocked before entering Bell Chamber & speaking with Lyra")
	await press("interact")
	await read_through(hud)
	check(qm.great_bell_chamber_entered and qm.get_current_objective_id() == "speak_lyra_antechamber", "Objective 1 completed: Antechamber entered")

	# Objective 2: Speak with Lyra in Antechamber
	await walk_to(player, Vector2(-112, 202))
	await press("interact")
	await read_through(hud)
	check(qm.lyra_antechamber_spoken and qm.get_current_objective_id() == "investigate_forgotten_hall", "Objective 2 completed: Spoke with Lyra in Antechamber")

	# Walk physically through AntechamberArch into Area B: Hall of Forgotten Names
	await walk_path(player, [Vector2(-176, 150), Vector2(-176, 108)])
	await press("interact")
	await read_through(hud)
	check(qm.forgotten_hall_investigated and qm.get_current_objective_id() == "recover_memory_fragments", "Objective 3 completed: Hall of Forgotten Names investigated")

	# Verify gating on Warden Record before 3/3 fragments
	check(not qm.reveal_warden_complete_record(), "Bell Wardens' Complete Record blocked prior to 3/3 memory fragments")

	# Objective 4: Recover all 3 Memory Fragments physically
	await walk_to(player, Vector2(-226, 64))
	await press("interact")
	await read_through(hud)
	check(qm.get_recovered_memory_fragment_count() == 1, "Memory Fragment I (Home) recovered (1/3)")

	await walk_to(player, Vector2(-176, 54))
	await press("interact")
	await read_through(hud)
	check(qm.get_recovered_memory_fragment_count() == 2, "Memory Fragment II (Promise) recovered (2/3)")

	await walk_to(player, Vector2(-86, 68))
	await press("interact")
	await read_through(hud)
	check(qm.get_recovered_memory_fragment_count() == 3 and qm.get_current_objective_id() == "reveal_warden_record", "Objective 4 completed: All 3 essential memory fragments recovered")

	# Objective 5: Reveal Bell Wardens' Complete Record
	await walk_to(player, Vector2(-24, 76))
	check(not qm.discover_elena_final_message(), "Elena's final message gated behind Bell Wardens' Complete Record")
	await press("interact")
	await read_through(hud)
	check(qm.warden_record_revealed and qm.get_current_objective_id() == "discover_elena_final_message", "Objective 5 completed: Complete Warden record revealed")

	# HeartChamberBlocker must remain solid before Elena's final message
	check(not gb.heart_blocker_shape.disabled, "HeartChamberBlocker remains sealed before discovering Elena's final message")

	# Objective 6: Discover Elena's Final Message (canonical dialogue verbatim!)
	await walk_to(player, Vector2(44, 74))
	await press("interact")
	var elena_lines: Array[String] = []
	await read_through(hud, elena_lines)
	var elena_full: String = "\n".join(elena_lines)
	check(elena_full.contains("If you reached the bell, then you never stopped looking."), "Elena Final Message canonical line 1 verified")
	check(elena_full.contains("They told us the bell needed a voice."), "Elena Final Message canonical line 4 verified")
	check(elena_full.contains("What it really took was everything that made us who we were."), "Elena Final Message canonical line 5 verified")
	check(elena_full.contains("You already did, Aren. You remembered me."), "Elena Final Message canonical line 7 verified")
	check(elena_full.contains("Let the thirteen tolls end here."), "Elena Final Message canonical final line verified")
	check(qm.elena_final_message_heard and gb.heart_blocker_shape.disabled and qm.get_current_objective_id() == "examine_memory_binding", "Objective 6 completed: Elena's final message heard and HeartChamberBlocker unsealed")

	print("--- STAGE 3: HEART OF THE BELL, CONDUITS & LAST BELL CLIMAX ---")
	# Walk physically north through unsealed Heart Arch into Area C
	check(await walk_path(player, [Vector2(30, 30), Vector2(30, -50)]), "Player physically enters the Heart of the Bell")

	# Gating before examining binding
	check(not qm.activate_beacon_conduit("conduit_briarwood"), "Beacon Conduits locked before examining memory binding")

	# Objective 7: Examine memory-consuming binding
	await press("interact")
	await read_through(hud)
	check(qm.memory_binding_examined and qm.get_current_objective_id() == "activate_beacon_conduits", "Objective 7 completed: Memory binding examined")

	# Objective 8: Activate all 3 Beacon Conduits around dais
	await walk_path(player, [Vector2(-32, -50), Vector2(-68, -84)])
	await press("interact")
	await read_through(hud)
	check(qm.beacon_conduits_activated.has("conduit_briarwood") and not qm.can_stabilize_protective_network(), "Briarwood Conduit active (1/3); network cannot stabilize early")

	await walk_path(player, [Vector2(-68, -132), Vector2(30, -130)])
	await press("interact")
	await read_through(hud)
	check(qm.beacon_conduits_activated.has("conduit_floodmill") and not qm.can_stabilize_protective_network(), "Floodmill Conduit active (2/3); network still awaits 3rd conduit")

	await walk_path(player, [Vector2(96, -132), Vector2(124, -84)])
	await press("interact")
	await read_through(hud)
	check(qm.get_activated_beacon_conduit_count() == 3 and qm.get_current_objective_id() == "stabilize_protective_network", "Objective 8 completed: All 3 Beacon Conduits activated")

	# Mid-Chapter 5 Save v5 check before ritual completion
	check(qm.save_to_file(SAVE_TEST_PATH) == OK, "Mid-Chapter 5 Save v5 succeeds cleanly")

	# Objective 9: Stabilize protective network at GreatBellBinding
	await walk_path(player, [Vector2(96, -46), Vector2(30, -50)])
	await press("interact")
	await read_through(hud)
	check(qm.protective_network_stabilized and qm.get_current_objective_id() == "sever_memory_binding", "Objective 9 completed: Replacement protective network stabilized")

	# Objective 10 & 11: Sever binding -> Last Bell Climax Cinematic + [X] Skip
	check(not gb.terrace_blocker_shape.disabled, "DawnTerraceBlocker sealed before Last Bell climax cinematic")
	await press("interact")
	var safety_sev: int = 12
	while is_instance_valid(hud) and hud.is_inside_tree() and hud.get_node("Message").visible and hud.get_node("Message/Source").text == "THE LAST RITUAL - SEVERING THE BINDING" and safety_sev > 0:
		safety_sev -= 1
		await press("interact")
		await frames(1)
	await frames(2)
	check(cin.active and cin.active_id == "last_bell_climax", "Severing binding triggers last_bell_climax cinematic")
	check(qm.binding_severed and qm.storm_resolved, "Binding severed and Veilstorm resolved cleanly")
	# Read through or skip with KEY_X; verify KEY_X skips & completes witness_last_bell_cinematic
	await press_keycode(KEY_X)
	await frames(2)
	check(not cin.active and not player.movement_locked and qm.last_bell_cinematic_seen, "Skipping Last Bell cinematic via [X] restores control and marks objective 11")
	check(gb.terrace_blocker_shape.disabled and qm.get_current_objective_id() == "return_to_dawn_terrace", "DawnTerraceBlocker unsealed toward Dawn Terrace")
	check(gb.get_node("Landscape").storm_resolved and gb.get_node("Landscape").binding_severed, "Landscape renders resolved storm and shattered chains")

	print("--- STAGE 4: DAWN TERRACE EPILOGUE, CREDITS & SUNRISE BELLHAVEN ---")
	# Walk physically east (clearing ConduitIronwatch at (150, -84)) onto Dawn Terrace
	check(await walk_path(player, [Vector2(150, -50), Vector2(178, -74), Vector2(236, -86)]), "Player physically walks onto The Dawn Terrace")
	await press("interact")
	await read_through(hud)
	check(qm.dawn_terrace_returned and qm.get_current_objective_id() == "complete_final_epilogue", "Objective 12 completed: Returned to Dawn Terrace")

	# Objective 13: Final Epilogue Dialogue & Elena's Journal at Memorial
	await walk_to(player, Vector2(270, -84))
	await press("interact")
	var epi_lines: Array[String] = []
	await read_through(hud, epi_lines)
	var epi_full: String = "\n".join(epi_lines)
	check(epi_full.contains("Will you keep drawing maps?"), "Canonical Epilogue line 1 verbatim")
	check(epi_full.contains("Someone has to."), "Canonical Epilogue line 2 verbatim")
	check(epi_full.contains("Of places?"), "Canonical Epilogue line 3 verbatim")
	check(epi_full.contains("Of places. And of the people we almost forgot."), "Canonical Epilogue line 4 verbatim")
	check(epi_full.contains("Briarwood Survey Compass") and epi_full.contains("Floodmill silver locket"), "Personalized memorial lines reflect optional discoveries")
	check(qm.epilogue_completed and qm.elena_journal_placed and qm.get_current_objective_id() == "display_ending_credits", "Objective 13 completed: Epilogue complete & Elena's journal placed")

	# Objective 14: EndingCredits modal appears automatically
	var credits: Panel = hud.get_node("EndingCredits")
	check(credits.visible and player.movement_locked, "EndingCredits displays cleanly with movement locked")
	check(credits.get_node("CreditsGameTitle").text.contains("ASHVALE: THE THIRTEENTH BELL") and credits.get_node("CreditsTheEnd").text.contains("THE END"), "EndingCredits displays game title and THE END")
	credits.trigger_action("close")
	await frames(2)
	check(not credits.visible and not player.movement_locked and qm.chapter5_completed and qm.credits_viewed, "Closing EndingCredits completes Chapter 5 and restores free exploration")

	# Re-interacting with DawnMemorial post-game must NOT trap player in ending loop
	await press("interact")
	await read_through(hud)
	check(not credits.visible, "Re-interacting with DawnMemorial post-game does not re-trigger ending loop")

	# Field Satchel verification for Chapter 5
	hud.open_inventory()
	await frames(2)
	var inv_text: String = hud.get_node("InventoryPanel").get_rendered_items_text()
	check(inv_text.contains("RECOVERED MEMORY RECORDS (3/3)") and inv_text.contains("COMPLETE WARDEN TESTIMONY") and inv_text.contains("ELENA'S FINAL TESTIMONY") and inv_text.contains("HARMONIC CROWN SEAL") and inv_text.contains("ASHVALE MEMORIAL CHRONICLE"), "Field Satchel tracks all Chapter 5 & Epilogue records")
	await press_keycode(KEY_ESCAPE)
	await frames(2)

	# Save post-game state at Dawn Terrace for Continue non-loop check
	check(qm.save_to_file(POSTGAME_SAVE_PATH) == OK, "Post-game Save v5 writes cleanly")

	# Transition Dawn Terrace -> Sunrise Bellhaven
	await walk_to(player, Vector2(296, -32))
	await press("interact")
	await read_through(hud)
	var bh_sunrise := await wait_for_scene("BellhavenVillage")
	check(bh_sunrise != null, "Transitioned from Dawn Terrace into Bellhaven at Sunrise")
	if bh_sunrise != null:
		var bh_qm: Node = bh_sunrise.get_node("QuestManager")
		var bh_hud: CanvasLayer = bh_sunrise.get_node("HUD")
		check(bh_qm.storm_resolved and bh_qm.chapter5_completed and bh_sunrise.get_node("Landscape").sunrise_epilogue, "Bellhaven Sunrise state active with warm morning lighting")
		check(bh_sunrise.village_memorial != null and bh_sunrise.lyra_bellhaven != null and bh_sunrise.dawn_terrace_arch != null, "Sunrise Bellhaven spawns Memorial, Historian Lyra, and Dawn Terrace Arch")
		var caelen_lines: Array[String] = bh_qm.get_npc_dialogue("caelen")
		var mira_lines: Array[String] = bh_qm.get_npc_dialogue("mira")
		var elara_lines: Array[String] = bh_qm.get_npc_dialogue("elara")
		var lyra_bh_lines: Array[String] = bh_qm.get_npc_dialogue("lyra_bellhaven")
		check(not caelen_lines.is_empty() and caelen_lines[0].contains("morning actually came cleanly"), "Master Caelen reflects resolved curse in Sunrise Bellhaven")
		check(not mira_lines.is_empty() and mira_lines[0].contains("pure bronze ringing to rest"), "Mira reflects lifted curse in Sunrise Bellhaven")
		check(not elara_lines.is_empty() and elara_lines[0].contains("harvesting a single song"), "Sister Elara reflects truthful chronicle in Sunrise Bellhaven")
		check(not lyra_bh_lines.is_empty() and lyra_bh_lines[1].contains("nothing was left forgotten"), "Lyra delivers Bellhaven Sunrise closure")

		# Verify round-trip back to Dawn Terrace
		bh_sunrise.travel_to_great_bell_terrace()
		var back_terrace := await wait_for_scene("GreatBellSanctum")
		check(back_terrace != null and back_terrace.get_node("QuestManager").chapter5_completed, "Round-trip Sunrise Bellhaven -> Dawn Terrace preserves completed post-game state")

	print("--- STAGE 5: SAVE V5 PERSISTENCE, LEGACY V1-V4 MIGRATION & POST-GAME CONTINUE ---")
	change_scene_to_file("res://scenes/sjt_exterior.tscn")
	var start_menu := await wait_for_scene("BellhavenVillage")
	check(start_menu != null, "Returned to Bellhaven startup to test post-game Continue")
	check(start_menu.get_node("HUD").continue_game(POSTGAME_SAVE_PATH), "Continue initiated on completed Save v5")
	var resumed_post := await wait_for_scene("GreatBellSanctum")
	check(resumed_post != null, "Continue loads directly into Dawn Terrace post-game")
	if resumed_post != null:
		var rp_qm: Node = resumed_post.get_node("QuestManager")
		var rp_credits: Panel = resumed_post.get_node("HUD/EndingCredits")
		check(rp_qm.chapter5_completed and rp_qm.storm_resolved and rp_qm.binding_severed and rp_qm.elena_journal_placed, "All Chapter 5 & Epilogue flags restored on Continue")
		check(not rp_credits.visible and not resumed_post.get_node("Actors/Player").movement_locked, "Post-game Continue does NOT trap player inside EndingCredits loop")

	# Legacy v1, v2, v3, v4 saves load cleanly under SAVE_VERSION = 5
	for ver_tuple in [
		[V1_SAVE_TEST_PATH, {"version": 1, "quest_id": "chapter1_whispers_of_briarwood", "quest_data_path": "res://data/chapter1_quest.json", "region_scene": "res://scenes/briarwood_forest.tscn", "chapter1_completed": true}],
		[V2_SAVE_TEST_PATH, {"version": 2, "quest_id": "chapter2_drowned_village", "quest_data_path": "res://data/chapter2_quest.json", "region_scene": "res://scenes/floodmill_village.tscn", "chapter2_completed": true}],
		[V3_SAVE_TEST_PATH, {"version": 3, "quest_id": "chapter3_keepers_lie", "quest_data_path": "res://data/chapter3_quest.json", "region_scene": "res://scenes/ironwatch_keep.tscn", "chapter3_completed": true}],
		[V4_SAVE_TEST_PATH, {"version": 4, "quest_id": "chapter4_road_to_dawnspire", "quest_data_path": "res://data/chapter4_quest.json", "region_scene": "res://scenes/dawnspire_mountain.tscn", "chapter4_completed": true, "great_bell_gate_unlocked": true}],
	]:
		var vp: String = ver_tuple[0]
		var vf := FileAccess.open(vp, FileAccess.WRITE)
		vf.store_string(JSON.stringify(ver_tuple[1]))
		vf.close()
		var leg_qm := QuestManagerScript.new()
		check(leg_qm.load_from_file(vp) and not leg_qm.chapter5_completed, "Legacy save v%d loads cleanly with Chapter 5 defaults under SAVE_VERSION=5" % int(ver_tuple[1]["version"]))
		leg_qm.free()

	# Corrupt Save resilience on primary Save v5 -> recovers cleanly from .bak
	var dummy_qm := QuestManagerScript.new()
	dummy_qm.load_from_file(POSTGAME_SAVE_PATH)
	dummy_qm.save_to_file(POSTGAME_SAVE_PATH) # creates .bak
	dummy_qm.free()
	var cf := FileAccess.open(POSTGAME_SAVE_PATH, FileAccess.WRITE)
	cf.store_string("{corrupt_v5_save")
	cf.close()
	var bak_qm := QuestManagerScript.new()
	check(bak_qm.load_from_file(POSTGAME_SAVE_PATH) and bak_qm.chapter5_completed and bak_qm.storm_resolved, "Corrupt primary Save v5 recovers cleanly from .bak backup")
	bak_qm.free()

	_cleanup_saves()
	Engine.time_scale = 1.0
	check(true, "Phase 6 validation suite completed")
	print("PHASE 6 RESULT: %d checks, %d failures" % [checks, failed])
	quit(0 if failed == 0 else 1)

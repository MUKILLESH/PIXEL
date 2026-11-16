extends SceneTree
## Generates 6 visual verification screenshots covering all 7 Dawnspire Mountain areas
## and both Chapter 4 minigames (`SkybridgeRepair` & `CelestialPuzzle`).
## Usage:
##   Godot_v4.7.2-stable_win64_console.exe --quit-after 300 -s res://tests/capture_dawnspire.gd

const AudioManagerScript = preload("res://scripts/systems/audio_manager.gd")

func _init() -> void:
	call_deferred("capture")

func frames(count: int = 5) -> void:
	for _i in range(count):
		await physics_frame

func _wait_scene(expected: String) -> Node2D:
	for _i in range(40):
		await process_frame
		if current_scene != null and current_scene.name == expected:
			await frames(5)
			return current_scene as Node2D
	return null

func _snap_and_save(cam: Camera2D, out_png: String) -> void:
	if cam != null and cam.has_method("snap_to_target"):
		cam.snap_to_target()
	await frames(6)
	root.get_texture().get_image().save_png(out_png)
	print("SAVED: " + out_png)

func capture() -> void:
	change_scene_to_file("res://scenes/dawnspire_mountain.tscn")
	var ds := await _wait_scene("DawnspireMountain")
	if ds == null:
		push_error("Failed to load DawnspireMountain")
		quit(1)
		return

	var qm: Node = ds.get_node("QuestManager")
	var hud: CanvasLayer = ds.get_node("HUD")
	var player: CharacterBody2D = ds.get_node("Actors/Player")
	var cam: Camera2D = ds.get_node("Actors/Player/Camera2D")

	# 1. Mountain Foothills arrival with Historian Lyra & storm-clouds horizon
	player.position = Vector2(-132, 198)
	player.facing = 0
	hud._region_fade_alpha = 0.0
	if hud.region_banner != null:
		hud.region_banner.visible = false
	await _snap_and_save(cam, "res://tests/verify_dawnspire_foothills.png")

	# 2. Whispering Cliffs wind shelter & active gale gusts beside Broken Skybridge
	ds.forced_wind_gust_active = true
	ds.get_node("Landscape").wind_gust_active = true
	player.position = Vector2(180, 174)
	player.facing = 7
	await _snap_and_save(cam, "res://tests/verify_dawnspire_cliffs_skybridge.png")
	ds.forced_wind_gust_active = false

	# 3. Minigame A: SkybridgeRepair counterweight puzzle modal
	qm.complete_objective("enter_foothills")
	qm.complete_objective("speak_lyra_foothills")
	qm.complete_objective("navigate_whispering_cliffs")
	qm.complete_objective("investigate_skybridge")
	qm.record_skybridge_diagram_read()
	qm.record_skybridge_part_collected("granite_counterweight")
	qm.record_skybridge_part_collected("bronze_pinion")
	qm.record_skybridge_part_collected("tension_chain")
	player.position = Vector2(-12, 26)
	player.facing = 6
	ds._sync_world_from_quest()
	hud.open_skybridge_repair(ds.skybridge_console)
	await _snap_and_save(cam, "res://tests/verify_dawnspire_skybridge_puzzle.png")
	hud.get_node("SkybridgeRepair").close_puzzle()

	# 4. Pilgrim's Refuge cutaway chapel, crimson frost trees & Elena's journal
	qm.complete_objective("repair_skybridge")
	ds._sync_world_from_quest()
	player.position = Vector2(-180, -76)
	player.facing = 5
	await _snap_and_save(cam, "res://tests/verify_dawnspire_pilgrims_refuge.png")

	# 5. Minigame B: Celestial Observatory astrolabe alignment puzzle modal
	qm.complete_objective("discover_pilgrims_refuge")
	qm.complete_objective("read_elena_journal")
	qm.complete_objective("reach_observatory")
	qm.record_celestial_clue_found("sun")
	qm.record_celestial_clue_found("moon")
	qm.record_celestial_clue_found("stars")
	player.position = Vector2(188, -94)
	player.facing = 0
	ds._sync_world_from_quest()
	hud.open_celestial_puzzle(ds.celestial_mechanism)
	hud.get_node("CelestialPuzzle").selections.assign([1, 2, 3])
	hud.get_node("CelestialPuzzle")._refresh()
	await _snap_and_save(cam, "res://tests/verify_dawnspire_observatory_puzzle.png")
	hud.get_node("CelestialPuzzle").close_puzzle()

	# 6. Dawnspire Sanctuary: Three Beacons synchronized + Great Bell Gate unlocked
	qm.complete_objective("solve_observatory_puzzle")
	qm.complete_objective("enter_dawnspire_sanctuary")
	qm.complete_objective("synchronize_three_beacons")
	qm.complete_objective("witness_sanctuary_revelation")
	qm.complete_objective("reach_great_bell_gate")
	ds._sync_world_from_quest()
	player.position = Vector2(24, -184)
	player.facing = 6
	await _snap_and_save(cam, "res://tests/verify_dawnspire_sanctuary_gate.png")

	var audio := AudioManagerScript.ensure(self)
	if audio != null and audio.has_method("stop_all"):
		audio.stop_all()
	print("CAPTURE DAWNSPIRE COMPLETE")
	quit(0)

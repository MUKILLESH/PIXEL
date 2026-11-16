extends SceneTree
## Generates comparable Before/After visual comparison PNGs across all 4 regions
## plus cinematic showcase frames for Phase 4.5 (The Living World).
## Usage:
##   Godot_v4.7.2-stable_win64_console.exe --quit-after 240 --script tests/capture_phase4_5.gd -- --before
##   Godot_v4.7.2-stable_win64_console.exe --quit-after 240 --script tests/capture_phase4_5.gd -- --after

func _init() -> void:
	call_deferred("capture")

func frames(count: int = 4) -> void:
	for _i in range(count):
		await physics_frame

func _is_after_mode() -> bool:
	return OS.get_cmdline_user_args().has("--after") or OS.get_cmdline_args().has("--after")

func _wait_scene(expected: String) -> Node2D:
	for _i in range(30):
		await process_frame
		if current_scene != null and current_scene.name == expected:
			await frames(5)
			return current_scene as Node2D
	return null

func _capture_region(scene_path: String, expected_name: String, pos: Vector2, facing_dir: int, out_png: String) -> void:
	change_scene_to_file(scene_path)
	var world := await _wait_scene(expected_name)
	if world == null:
		push_error("Failed to load scene for capture: " + scene_path)
		return
	var player := world.get_node("Actors/Player") as CharacterBody2D
	var cam := world.get_node("Actors/Player/Camera2D") as Camera2D
	player.position = pos
	player.facing = facing_dir
	if cam.has_method("snap_to_target"):
		cam.snap_to_target()
	await frames(6)
	root.get_texture().get_image().save_png(out_png)
	print("SAVED: " + out_png)

func capture() -> void:
	var after_mode: bool = _is_after_mode()
	var prefix := "after_" if after_mode else "before_"

	await _capture_region("res://scenes/sjt_exterior.tscn", "BellhavenVillage", Vector2(10, 44), 2, "res://tests/" + prefix + "bellhaven.png")
	await _capture_region("res://scenes/briarwood_forest.tscn", "BriarwoodForest", Vector2(18, 168), 2, "res://tests/" + prefix + "briarwood.png")
	await _capture_region("res://scenes/floodmill_village.tscn", "FloodmillVillage", Vector2(-56, 114), 2, "res://tests/" + prefix + "floodmill.png")
	await _capture_region("res://scenes/ironwatch_keep.tscn", "IronwatchKeep", Vector2(96, 178), 0, "res://tests/" + prefix + "ironwatch.png")

	if after_mode:
		# Cinematic showcase 1: Prologue Thirteenth Bell toll at Rune Pedestal
		change_scene_to_file("res://scenes/sjt_exterior.tscn")
		var bh := await _wait_scene("BellhavenVillage")
		if bh != null:
			var hud := bh.get_node("HUD")
			var term := bh.get_node("Actors/Terminal") as StaticBody2D
			var player := bh.get_node("Actors/Player") as CharacterBody2D
			player.position = Vector2(96, 56)
			player.facing = 6
			var bell_lines: Array[String] = [
				"STONE RUNE PEDESTAL: Across Bellhaven Square, the Great Bell's thirteenth toll trembles in dusk violet resonance."
			]
			if hud.has_method("start_story_cinematic"):
				hud.start_story_cinematic("prologue_thirteenth_bell", term.global_position, Color(0.55, 0.42, 0.92), "bell_toll")
			hud.show_dialogue("STONE RUNE PEDESTAL", bell_lines, term)
			await frames(8)
			root.get_texture().get_image().save_png("res://tests/cinematic_bellhaven_toll.png")
			print("SAVED: res://tests/cinematic_bellhaven_toll.png")
			hud._close_dialogue(false)

		# Cinematic showcase 2: Ironwatch Third Beacon & Triad Alignment
		change_scene_to_file("res://scenes/ironwatch_keep.tscn")
		var iw := await _wait_scene("IronwatchKeep")
		if iw != null:
			var hud := iw.get_node("HUD")
			var qm := iw.get_node("QuestManager")
			for entry in qm.objectives:
				var oid: String = String(entry.get("id"))
				if oid == "restore_third_beacon":
					break
				if oid == "find_crest_clues":
					qm.record_crest_clue_found("clue_1")
					qm.record_crest_clue_found("clue_2")
					qm.record_crest_clue_found("clue_3")
				else:
					qm.complete_objective(oid)
			qm.complete_objective("restore_third_beacon")
			var beacon := iw.get_node("Actors/ThirdBeacon") as StaticBody2D
			var player := iw.get_node("Actors/Player") as CharacterBody2D
			player.position = Vector2(70, -124)
			player.facing = 4
			var triad_lines: Array[String] = [
				"Sapphire and golden light roars skyward as Briarwood, Floodmill, and Ironwatch lock into one shimmering triad across Ashvale!"
			]
			if hud.has_method("start_story_cinematic"):
				hud.start_story_cinematic("ironwatch_beacon_awakens", beacon.global_position, Color(0.45, 0.90, 1.0), "beacon_activate")
			hud.show_dialogue("THIRD ANCIENT BEACON", triad_lines, beacon)
			await frames(8)
			root.get_texture().get_image().save_png("res://tests/cinematic_ironwatch_triad.png")
			print("SAVED: res://tests/cinematic_ironwatch_triad.png")
			hud._close_dialogue(false)

	print("CAPTURE_PHASE4_5 DONE")
	quit(0)

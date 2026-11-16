extends SceneTree
## Generates 6 visual PNG captures across Ironwatch Keep (Chapter 3: The Keeper's Lie)
## for visual QA inspection of fortress architecture, cutaway Archives, Hall of Crests UI,
## Shadowed Passage stealth lane, Warden confrontation, and the Three-Beacon Vault.

func _init() -> void:
	call_deferred("capture")

func frames(count: int = 3) -> void:
	for _i in range(count):
		await physics_frame

func _complete_through(qm: Node, stop_before_id: String) -> void:
	for entry in qm.objectives:
		var oid: String = String(entry.get("id"))
		if oid == stop_before_id:
			break
		if oid == "find_crest_clues":
			qm.record_crest_clue_found("clue_1")
			qm.record_crest_clue_found("clue_2")
			qm.record_crest_clue_found("clue_3")
		else:
			qm.complete_objective(oid)

func capture() -> void:
	change_scene_to_file("res://scenes/ironwatch_keep.tscn")
	for _i in range(24):
		await process_frame
		if current_scene != null and current_scene.name == "IronwatchKeep":
			break
	await frames(6)

	var world := current_scene as Node2D
	var qm: Node = world.get_node("QuestManager")
	var hud: CanvasLayer = world.get_node("HUD")
	var player: CharacterBody2D = world.get_node("Actors/Player")
	var cam: Camera2D = world.get_node("Actors/Player/Camera2D")

	# 1. Courtyard & Gatehouse arrival shot
	print("CAPTURE: 1/6 courtyard")
	player.position = Vector2(96, 178)
	player.facing = 0
	cam.snap_to_target()
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/verify_ironwatch_courtyard.png")

	# 2. Cutaway Fortress Archives interior with Gothic lancet windows & chandelier
	print("CAPTURE: 2/6 archives")
	_complete_through(qm, "discover_warden_records")
	player.position = Vector2(185, 58)
	player.facing = 4
	cam.snap_to_target()
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/verify_ironwatch_archives.png")

	# 3. Hall of Crests UI open in Center Plaza
	print("CAPTURE: 3/6 crest puzzle")
	_complete_through(qm, "solve_crest_puzzle")
	player.position = Vector2(-18, 34)
	player.facing = 4
	cam.snap_to_target()
	hud.open_crest_puzzle(world.get_node("Actors/CrestAltar"))
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/verify_ironwatch_crest_puzzle.png")
	hud.get_node("CrestPuzzle").close_puzzle()
	await frames(2)

	# 4. Shadowed Passage Stealth corridor with Ward Alcoves & Sentinels
	print("CAPTURE: 4/6 stealth")
	qm.complete_objective("solve_crest_puzzle")
	qm.set_stealth_checkpoint("checkpoint_1", Vector2(-160, -110))
	world.get_node("Landscape").active_checkpoint_id = "checkpoint_1"
	world.get_node("Actors/ShadowSentinel1").set_patrol_phase(0.25)
	world.get_node("Actors/ShadowSentinel2").set_patrol_phase(2.8)
	player.position = Vector2(-160, -110)
	player.facing = 4
	cam.snap_to_target()
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/verify_ironwatch_stealth.png")

	# 5. Warden's Chamber confrontation view
	print("CAPTURE: 5/6 warden vault")
	_complete_through(qm, "confront_last_warden")
	player.position = Vector2(-12, -138)
	player.facing = 6
	cam.snap_to_target()
	var warden_line: Array[String] = [
		"WARDEN: \"We chose to forget thirty-six lives so that ten thousand could live.\""
	]
	hud.show_dialogue("LAST BELL WARDEN", warden_line, world.get_node("Actors/LastWarden"))
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/verify_ironwatch_warden_vault.png")
	hud._close_dialogue(false)
	await frames(2)

	# 6. Third Ancient Beacon lit & all three harmonic beams converging toward Dawnspire
	print("CAPTURE: 6/6 beacon lit")
	_complete_through(qm, "complete_chapter3")
	hud._finish_chapter3()
	player.position = Vector2(70, -124)
	player.facing = 4
	cam.snap_to_target()
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/verify_ironwatch_beacon_lit.png")
	print("CAPTURE: DONE")

	quit(0)

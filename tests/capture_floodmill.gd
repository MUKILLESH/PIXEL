extends SceneTree
## Generates clean windowed visual PNG screenshots across Floodmill: The Drowned Village
## (Village + Rotating Waterwheel, WatermillRepair UI, SluicePuzzle UI, LedgerPuzzle UI,
## Second Beacon Finale, and full region overview) for visual QA inspection.

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

func capture() -> void:
	change_scene_to_file("res://scenes/floodmill_village.tscn")
	for _i in range(20):
		await process_frame
		if current_scene != null and current_scene.name == "FloodmillVillage":
			break
	await frames(6)

	var world := current_scene as Node2D
	var qm: Node = world.get_node("QuestManager")
	var hud: CanvasLayer = world.get_node("HUD")
	var player: CharacterBody2D = world.get_node("Actors/Player")
	var cam: Camera2D = world.get_node("Actors/Player/Camera2D")

	# 1. Arrival & Abandoned Village + Sluice overview shot
	player.position = Vector2(-56, 114)
	player.facing = 2
	cam.snap_to_target()
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/floodmill_arrival_village.png")

	# 2. Old Watermill Mechanical Repair minigame open in front of millhouse
	_complete_through(qm, "restore_watermill")
	player.position = Vector2(158, 72)
	player.facing = 6
	cam.snap_to_target()
	hud.open_watermill_repair(world.get_node("Actors/BrokenWatermill"))
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/floodmill_watermill_repair.png")
	hud.get_node("WatermillRepair").close_puzzle()
	await frames(2)

	# 3. Sluice Gate Control minigame open beside Canal
	qm.complete_objective("restore_watermill")
	qm.complete_objective("investigate_sluice_gates")
	player.position = Vector2(36, 20)
	player.facing = 6
	cam.snap_to_target()
	hud.open_sluice_puzzle(world.get_node("Actors/SluiceConsole"))
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/floodmill_sluice_puzzle.png")
	hud.get_node("SluicePuzzle").close_puzzle()
	await frames(2)

	# 4. Forgotten Archive Ledger Reconstruction minigame inside Cutaway Library
	qm.sluice_gate_states.assign([2, 1, 3])
	qm.complete_objective("redirect_water_flow")
	qm.complete_objective("enter_forgotten_archive")
	qm.record_archive_clue_found("record_census")
	qm.record_archive_clue_found("record_tribute")
	qm.record_archive_clue_found("record_transfer")
	player.position = Vector2(-134, -92)
	player.facing = 6
	cam.snap_to_target()
	hud.open_ledger_puzzle(world.get_node("Actors/LedgerTable"))
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/floodmill_ledger_puzzle.png")
	hud.get_node("LedgerPuzzle").close_puzzle()
	await frames(2)

	# 5. Second Ancient Beacon lit & Chapter 2 finale
	qm.complete_objective("reconstruct_village_ledger")
	qm.complete_objective("discover_villagers_truth")
	qm.complete_objective("restore_second_beacon")
	qm.complete_objective("witness_elena_message")
	hud._finish_chapter2()
	player.position = Vector2(92, -180)
	player.facing = 5
	cam.snap_to_target()
	await frames(4)
	root.get_texture().get_image().save_png("res://tests/floodmill_second_beacon.png")
	hud.get_node("PrologueComplete").hide()

	# 6. Wide Overview showing entire Floodmill layout
	hud.hide()
	cam.zoom = Vector2(0.55, 0.55)
	player.position = Vector2(0, 0)
	cam.framing = Vector2.ZERO
	cam.snap_to_target()
	await frames(6)
	root.get_texture().get_image().save_png("res://tests/floodmill_overview.png")

	print("FLOODMILL CAPTURES SAVED SUCCESSFULLY")
	quit(0)

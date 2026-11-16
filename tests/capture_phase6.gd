extends SceneTree
## Generates 6 visual verification screenshots covering Chapter 5 (The Last Bell):
## Bell Antechamber, Hall of Forgotten Names, Heart of the Bell Conduit Ritual,
## Last Bell Climax Cinematic, Dawn Terrace Epilogue, and Ending Credits.

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
	change_scene_to_file("res://scenes/great_bell_sanctum.tscn")
	var gb := await _wait_scene("GreatBellSanctum")
	if gb == null:
		push_error("Failed to load GreatBellSanctum")
		quit(1)
		return

	var qm: Node = gb.get_node("QuestManager")
	var hud: CanvasLayer = gb.get_node("HUD")
	var player: CharacterBody2D = gb.get_node("Actors/Player")
	var cam: Camera2D = gb.get_node("Actors/Player/Camera2D")
	hud._region_fade_alpha = 0.0
	if hud.region_banner != null:
		hud.region_banner.visible = false

	# 1. Bell Antechamber arrival with Historian Lyra
	player.position = Vector2(-152, 206)
	player.facing = 0
	await _snap_and_save(cam, "res://tests/verify_phase6_antechamber.png")

	# 2. Hall of Forgotten Names with memory crystals & Elena Echo plinth
	qm.enter_great_bell_chamber()
	qm.speak_lyra_antechamber()
	qm.investigate_forgotten_hall()
	qm.recover_memory_fragment("frag_home")
	gb._sync_world_from_quest()
	player.position = Vector2(-132, 74)
	player.facing = 7
	await _snap_and_save(cam, "res://tests/verify_phase6_forgotten_hall.png")

	# 3. Heart of the Bell with all 3 Beacon Conduit beams active & network stabilized
	qm.recover_memory_fragment("frag_promise")
	qm.recover_memory_fragment("frag_sacrifice")
	qm.reveal_warden_complete_record()
	qm.discover_elena_final_message()
	qm.examine_memory_binding()
	qm.activate_beacon_conduit("conduit_briarwood")
	qm.activate_beacon_conduit("conduit_floodmill")
	qm.activate_beacon_conduit("conduit_ironwatch")
	qm.stabilize_protective_network()
	gb._sync_world_from_quest()
	player.position = Vector2(30, -50)
	player.facing = 6
	await _snap_and_save(cam, "res://tests/verify_phase6_heart_ritual.png")

	# 4. Last Bell Climax Cinematic (shattering chains, radiant beams, storm resolved)
	qm.sever_memory_binding()
	gb._sync_world_from_quest()
	hud.start_story_cinematic("last_bell_climax", Vector2(30, -96), Color(1.0, 0.88, 0.48), "")
	hud.show_dialogue("THE LAST BELL - BREAKING THE CHAINS", qm.get_story_lines("last_bell_climax_dialogue"), gb.great_bell_binding)
	await _snap_and_save(cam, "res://tests/verify_phase6_climax_cinematic.png")
	hud._close_dialogue(false)
	hud.get_node("CinematicDirector").finish_story_cinematic(false)

	# 5. Dawn Terrace Epilogue with Lyra, sunrise light & Memorial + Elena's journal
	qm.complete_last_bell_cinematic()
	qm.return_to_dawn_terrace()
	qm.complete_final_epilogue()
	gb._sync_world_from_quest()
	player.position = Vector2(270, -84)
	player.facing = 0
	await _snap_and_save(cam, "res://tests/verify_phase6_dawn_epilogue.png")

	# 6. Interactive Ending Credits Screen
	hud.open_ending_credits(gb.dawn_memorial)
	await _snap_and_save(cam, "res://tests/verify_phase6_ending_credits.png")
	quit(0)

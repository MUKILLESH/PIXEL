extends SceneTree
## GFX-6 matching BEFORE/AFTER captures of the Great Bell Sanctum.
## Usage: godot --path . -s res://tests/capture_gfx6.gd -- --before|--after [--measure]
## Uses a temporary save path; the player's real save files are never touched.

const TMP_SAVE := "user://capture_gfx6_tmp.json"

func _init() -> void:
	call_deferred("capture")

func frames(count: int = 5) -> void:
	for _i in range(count):
		await process_frame

func _wait_scene(expected: String) -> Node2D:
	for _i in range(60):
		await process_frame
		if current_scene != null and current_scene.name == expected:
			await frames(5)
			return current_scene as Node2D
	return null

func capture() -> void:
	var args := OS.get_cmdline_user_args()
	var suffix := "before" if "--before" in args else "after"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/gfx6"))
	change_scene_to_file("res://scenes/great_bell_sanctum.tscn")
	var gb := await _wait_scene("GreatBellSanctum")
	if gb == null:
		push_error("Failed to load GreatBellSanctum")
		quit(1)
		return
	var qm: Node = gb.get_node("QuestManager")
	var hud: CanvasLayer = gb.get_node("HUD")
	hud.save_path = TMP_SAVE
	var player: CharacterBody2D = gb.get_node("Actors/Player")
	player.set_physics_process(false)
	var cam: Camera2D = player.get_node("Camera2D")
	await create_timer(1.5).timeout
	hud._region_fade_alpha = 0.0
	if hud.region_banner != null:
		hud.region_banner.visible = false

	var shots := [
		["antechamber", Vector2(-152, 214), 0],
		["forgotten_hall", Vector2(-120, 100), 1],
		["heart_dormant", Vector2(50, -56), 2],
		["heart_conduits", Vector2(50, -56), 3],
		["binding_break", Vector2(50, -56), 4],
		["dawn_terrace", Vector2(270, -84), 5],
	]
	var stage := 0
	for shot: Array in shots:
		var want: int = shot[2]
		while stage < want:
			stage += 1
			match stage:
				1:
					qm.enter_great_bell_chamber()
					qm.speak_lyra_antechamber()
					qm.investigate_forgotten_hall()
					qm.recover_memory_fragment("frag_home")
				2:
					qm.recover_memory_fragment("frag_promise")
					qm.recover_memory_fragment("frag_sacrifice")
					qm.reveal_warden_complete_record()
					qm.discover_elena_final_message()
					qm.examine_memory_binding()
				3:
					qm.activate_beacon_conduit("conduit_briarwood")
					qm.activate_beacon_conduit("conduit_floodmill")
					qm.activate_beacon_conduit("conduit_ironwatch")
					qm.stabilize_protective_network()
				4:
					qm.sever_memory_binding()
				5:
					hud.get_node("CinematicDirector").finish_story_cinematic(false)
					qm.complete_last_bell_cinematic()
					qm.return_to_dawn_terrace()
					qm.complete_final_epilogue()
			gb._sync_world_from_quest()
		if stage == 4 and shot[0] == "binding_break":
			hud.start_story_cinematic("last_bell_climax", Vector2(30, -96), Color(1.0, 0.88, 0.48), "")
		player.position = shot[1]
		player.facing = 0
		cam.snap_to_target()
		await create_timer(0.6).timeout
		await RenderingServer.frame_post_draw
		var out: String = "res://docs/gfx6/" + suffix + "_" + shot[0] + ".png"
		var err := root.get_texture().get_image().save_png(out)
		if err != OK:
			push_error("Capture failed: " + out)
			quit(1)
			return
		print("SAVED: ", out)

	if "--measure" in args:
		for spot: Array in [["antechamber", Vector2(-152, 214)], ["forgotten_hall", Vector2(-120, 100)], ["heart", Vector2(50, -56)], ["dawn_terrace", Vector2(270, -84)]]:
			player.position = spot[1]
			cam.snap_to_target()
			await create_timer(1.0).timeout
			var samples: Array[float] = []
			var last := Time.get_ticks_usec()
			for i in range(240):
				await process_frame
				var now := Time.get_ticks_usec()
				samples.append((now - last) / 1000.0)
				last = now
			var total: float = 0.0
			for s in samples:
				total += s
			samples.sort()
			print("GFX6 %s: mean_ms=%.2f p95_ms=%.2f max_ms=%.2f fps=%.1f frames=240 nodes=%d" % [spot[0], total / 240.0, samples[228], samples[239], Engine.get_frames_per_second(), Performance.get_monitor(Performance.OBJECT_NODE_COUNT)])
	for p in [TMP_SAVE, TMP_SAVE + ".bak", TMP_SAVE + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
	print("GFX6 CAPTURES COMPLETE: ", suffix)
	quit(0)

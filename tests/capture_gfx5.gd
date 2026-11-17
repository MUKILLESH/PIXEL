extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var world := load("res://scenes/dawnspire_mountain.tscn").instantiate() as Node2D
	root.add_child(world)
	world.set_physics_process(false)
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.set_physics_process(false)
	var cam: Camera2D = player.get_node("Camera2D")
	var qm: Node = world.get_node("QuestManager")
	await create_timer(4).timeout
	var suffix := "before" if "--before" in OS.get_cmdline_user_args() else "after"
	var shots := [["foothills",Vector2(-158,198),0],["cliffs",Vector2(210,174),0],["bridge_broken",Vector2(-12,26),0],["bridge_repaired",Vector2(-12,26),1],["refuge",Vector2(-204,-76),1],["observatory",Vector2(188,-94),1],["sanctuary_inactive",Vector2(-12,-184),2],["sanctuary_active",Vector2(-12,-184),3],["gate",Vector2(74,-184),3],["overview",Vector2(0,15),3]]
	for shot: Array in shots:
		qm.skybridge_repaired = shot[2] >= 1
		qm.observatory_solved = shot[2] >= 2
		qm.beacons_synchronized = shot[2] >= 3
		qm.great_bell_gate_unlocked = shot[2] >= 3
		world._sync_world_from_quest()
		world.get_node("Landscape").wind_warning_active = shot[0] == "cliffs"
		player.position = shot[1]
		if shot[0] == "overview":
			root.content_scale_size = Vector2i(960,720)
			root.size = Vector2i(960,720)
		cam.snap_to_target()
		await create_timer(0.3).timeout
		world.get_node("Landscape").set_process(false)
		world.get_node("Landscape")._anim_phase = 1.0
		world.get_node("Landscape").queue_redraw()
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png("res://docs/gfx5/"+suffix+"_"+shot[0]+".png")
		if result != OK:
			quit(1)
			return
	if "--measure" in OS.get_cmdline_user_args():
		root.content_scale_size = Vector2i(640,360)
		root.size = Vector2i(1280,720)
		world.get_node("Landscape").set_process(true)
		# Uncapped sample reveals rendering headroom; paced sample represents normal play.
		for uncapped: bool in [false,true]:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED if uncapped else DisplayServer.VSYNC_ENABLED)
			Engine.max_fps = 0 if uncapped else 60
			for spot: Array in [["cliffs",Vector2(210,174)],["observatory",Vector2(188,-94)],["sanctuary",Vector2(-12,-184)]]:
				player.position = spot[1]
				world.get_node("Landscape").wind_gust_active = spot[0] == "cliffs"
				cam.snap_to_target()
				await create_timer(1).timeout
				var samples: Array[float] = []
				var last := Time.get_ticks_usec()
				for i in range(240):
					await process_frame
					var now := Time.get_ticks_usec()
					samples.append((now-last)/1000.0)
					last = now
				var total: float = 0
				for sample in samples: total += sample
				samples.sort()
				print("GFX5 ",suffix," ",spot[0]," uncapped=",uncapped," mean=%.2f p95=%.2f max=%.2f ms n=240" % [total/240,samples[228],samples[239]])
	print("GFX5 CAPTURES COMPLETE: ",suffix," 10/10")
	var audio := root.get_node_or_null("AshvaleAudio")
	if audio != null: audio.stop_all()
	await create_timer(0.15).timeout
	world.queue_free()
	await process_frame
	quit()

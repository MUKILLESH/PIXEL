extends SceneTree
## Matched positions/state/framing. Captures never access player saves.
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var world := load("res://scenes/ironwatch_keep.tscn").instantiate() as Node2D
	root.add_child(world)
	world.set_physics_process(false) # Freeze stealth recovery for deterministic review only.
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.set_physics_process(false)
	var cam: Camera2D = player.get_node("Camera2D")
	var qm: Node = world.get_node("QuestManager")
	await create_timer(4).timeout
	var suffix := "before" if "--before" in OS.get_cmdline_user_args() else "after"
	var shots := [["courtyard",Vector2(96,178),0],["archives",Vector2(185,58),0],["crests",Vector2(-18,34),0],["passage",Vector2(-160,-110),1],["warden",Vector2(-12,-138),2],["vault_dormant",Vector2(70,-124),2],["vault_restored",Vector2(70,-124),3],["overview",Vector2(0,10),3]]
	for shot: Array in shots:
		qm.crest_puzzle_solved = shot[2] >= 1
		qm.shadow_passage_cleared = shot[2] >= 2
		qm.third_beacon_activated = shot[2] >= 3
		world._sync_world_from_quest()
		world.get_node("Landscape").active_checkpoint_id = "checkpoint_1"
		for i in range(2):
			var sentinel: Node2D = world.get_node("Actors/ShadowSentinel"+str(i+1))
			sentinel.set_process(false)
			sentinel.set_patrol_phase(0.25 if i == 0 else 2.8)
		player.position = shot[1]
		if shot[0] == "overview":
			root.content_scale_size = Vector2i(960,540)
			root.size = Vector2i(960,540)
		cam.snap_to_target()
		await create_timer(0.25).timeout
		await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png("res://docs/gfx4/"+suffix+"_"+shot[0]+".png") != OK:
			quit(1)
			return
	if "--measure" in OS.get_cmdline_user_args():
		root.content_scale_size = Vector2i(640,360)
		root.size = Vector2i(1280,720)
		for spot: Array in [["courtyard",Vector2(96,178)],["passage",Vector2(-160,-110)],["vault",Vector2(70,-124)]]:
			qm.shadow_passage_cleared = spot[0] != "passage"
			world._sync_world_from_quest()
			for sentinel: Node2D in world.sentinels: sentinel.set_process(true)
			player.position = spot[1]
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
			print("GFX4 ",spot[0],": mean_ms=%.2f p95_ms=%.2f max_ms=%.2f frames=240 native=640x360 window=1280x720" % [total/240,samples[228],samples[239]])
	print("GFX4 CAPTURES COMPLETE: ",suffix)
	var audio := root.get_node_or_null("AshvaleAudio")
	if audio != null:
		audio.stop_all()
		await create_timer(0.15).timeout # Let the audio mixer release active playbacks.
	world.queue_free()
	await process_frame
	await process_frame
	preload("res://scripts/world/ironwatch_art.gd").textures.clear()
	quit()

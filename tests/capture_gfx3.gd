extends SceneTree
## Matching fixed-state comparisons; no player save files are accessed.
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var world := load("res://scenes/floodmill_village.tscn").instantiate() as Node2D
	root.add_child(world)
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.set_physics_process(false)
	var cam: Camera2D = player.get_node("Camera2D")
	var qm: Node = world.get_node("QuestManager")
	await create_timer(4).timeout
	var suffix := "before" if "--before" in OS.get_cmdline_user_args() else "after"
	var shots := [["square",Vector2(-56,114),0],["mill_broken",Vector2(158,72),0],["mill_running",Vector2(158,72),1],["canal_flooded",Vector2(36,20),1],["canal_drained",Vector2(36,20),2],["archive",Vector2(-134,-92),2],["beacon_dormant",Vector2(92,-180),2],["beacon_restored",Vector2(92,-180),3],["overview",Vector2(0,0),3]]
	for shot: Array in shots:
		qm.watermill_repaired = shot[2] >= 1
		qm.sluice_solved = shot[2] >= 2
		qm.sluice_gate_states.assign([2,1,3] if shot[2] >= 2 else [0,0,0])
		qm.ledger_reconstructed = shot[2] >= 3
		qm.second_beacon_activated = shot[2] >= 3
		world._sync_world_from_quest()
		player.position = shot[1]
		if shot[0] == "overview":
			root.content_scale_size = Vector2i(960,540)
			root.size = Vector2i(960,540)
		cam.snap_to_target()
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png("res://docs/gfx3/"+suffix+"_"+shot[0]+".png")
		if error != OK:
			push_error("Capture failed")
			quit(1)
			return
	if "--measure" in OS.get_cmdline_user_args():
		root.content_scale_size = Vector2i(640,360)
		root.size = Vector2i(1280,720)
		for spot: Array in [["mill",Vector2(158,72)],["archive",Vector2(-134,-92)],["beacon",Vector2(92,-180)]]:
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
			print("GFX3 ",spot[0],": mean_ms=%.2f p95_ms=%.2f max_ms=%.2f frames=240 native=640x360 window=1280x720" % [total/240,samples[228],samples[239]])
	print("GFX3 CAPTURES COMPLETE: ",suffix)
	quit()

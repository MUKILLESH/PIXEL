extends SceneTree
## Matching captures without reading or writing user saves. --before selects baseline.
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var world := load("res://scenes/briarwood_forest.tscn").instantiate() as Node2D
	root.add_child(world)
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.set_physics_process(false)
	var cam: Camera2D = player.get_node("Camera2D")
	var qm: Node = world.get_node("QuestManager")
	await create_timer(4).timeout
	var suffix := "before" if "--before" in OS.get_cmdline_user_args() else "after"
	var shots := [["edge",Vector2(0,218)], ["fork",Vector2(0,88)], ["bridge_broken",Vector2(-90,18)], ["bridge_repaired",Vector2(-90,18)], ["grove",Vector2(-132,-124)], ["beacon_dormant",Vector2(-16,-190)], ["beacon_active",Vector2(-16,-190)], ["overview",Vector2(-44,-20)]]
	for i in range(shots.size()):
		qm.bridge_repaired = i >= 3
		qm.mirror_puzzle_solved = i >= 6
		qm.beacon_activated = i >= 6
		world._sync_world_from_quest()
		player.position = shots[i][1]
		if i == 7:
			root.content_scale_size = Vector2i(960,540)
			root.size = Vector2i(960,540)
		cam.snap_to_target()
		await create_timer(0.3).timeout
		world.get_node("Landscape").set("_anim_time",2.0)
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png("res://docs/gfx2/"+suffix+"_"+shots[i][0]+".png")
		assert(error == OK)
	if "--measure" in OS.get_cmdline_user_args():
		root.content_scale_size = Vector2i(640,360)
		root.size = Vector2i(1280,720)
		cam.snap_to_target()
		await create_timer(2.0).timeout
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
		print("GFX2 FRAME SAMPLE: mean_ms=%.2f p95_ms=%.2f max_ms=%.2f frames=240 viewport=640x360 window=1280x720" % [total/240.0,samples[228],samples[239]])
	quit()

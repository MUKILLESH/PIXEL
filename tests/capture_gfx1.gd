extends SceneTree
## Repeatable fresh-prologue comparison. Does not read/write player saves.
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var world := load("res://scenes/sjt_exterior.tscn").instantiate() as Node2D
	root.add_child(world)
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.position = Vector2(10,70)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(4.0).timeout
	if "--measure" in OS.get_cmdline_user_args():
		var samples: Array[float] = []
		var last: int = Time.get_ticks_usec()
		for i in range(240):
			await process_frame
			var now: int = Time.get_ticks_usec()
			samples.append((now-last)/1000.0)
			last = now
		var total: float = 0
		for sample in samples: total += sample
		samples.sort()
		print("GFX1 FRAME SAMPLE: mean_ms=%.2f p95_ms=%.2f max_ms=%.2f frames=240 viewport=640x360" % [total/240.0,samples[228],samples[239]])
	await RenderingServer.frame_post_draw
	var suffix: String = "before" if "--before" in OS.get_cmdline_user_args() else "after"
	DirAccess.make_dir_recursive_absolute("res://docs/gfx1")
	root.get_texture().get_image().save_png("res://docs/gfx1/"+suffix+".png")
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(960,540)
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/gfx1/"+suffix+"_overview.png")
	quit()

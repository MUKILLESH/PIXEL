extends SceneTree
## Optional graphical screenshot; do not run with --headless.
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var world := load("res://scenes/campus_prototype.tscn").instantiate() as Node2D
	root.add_child(world)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/courtyard_preview.png")
	var player := world.get_node("Actors/Player") as CharacterBody2D
	player.position = Vector2(45,30)
	player.get_node("Camera2D").snap_to_target()
	await physics_frame
	await physics_frame
	world.get_node("HUD").show_message("The bell has rung thirteen times. Something beneath the village is awakening.")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/terminal_preview.png")
	for window_size: Vector2i in [Vector2i(960,720),Vector2i(1440,810)]:
		root.size = window_size
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/ui_%dx%d.png" % [window_size.x,window_size.y])
	root.size = Vector2i(1280,720)
	await create_timer(0.3).timeout
	world.get_node("HUD/Message").hide()
	for i in range(4):
		player.position = [Vector2(0,-306),Vector2(650,16),Vector2(0,338),Vector2(-650,16)][i]
		player.get_node("Camera2D").snap_to_target()
		await physics_frame
		await physics_frame
		await physics_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/edge_%d.png" % i)
	world.queue_free()
	await process_frame
	# Contact sheet: eight directions across, four walking poses down.
	var sheet := Node2D.new()
	root.add_child(sheet)
	for direction in range(8):
		for frame in range(4):
			var actor := load("res://scenes/characters/player.tscn").instantiate() as CharacterBody2D
			actor.get_node("Camera2D").free()
			actor.position = Vector2(40+direction*80,75+frame*80)
			actor.facing = direction
			actor.walk_frame = frame
			sheet.add_child(actor)
			actor.set_physics_process(false)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/player_poses.png")
	quit()

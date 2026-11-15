extends SceneTree
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var world := load("res://scenes/sjt_exterior.tscn").instantiate() as Node2D
	root.add_child(world)
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/sjt_preview.png")
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.position = Vector2(20,20)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/sjt_entrance.png")
	player.position = Vector2(150,85)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/sjt_single_prompt.png")
	# Wider native-resolution review image; gameplay stays at 640x360.
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(960,540)
	player.position = Vector2(10,95)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/sjt_overview.png")
	quit()

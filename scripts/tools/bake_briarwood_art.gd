extends SceneTree
## Offline rasterization of original GDScript art; no external input or dependencies.
func _initialize() -> void:
	call_deferred("bake")
func bake() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/forest")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(128,144)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	for kind in range(9):
		for variant in range(3 if kind < 2 else 1):
			var prop := StaticBody2D.new()
			prop.set_script(load("res://scripts/world/briarwood_prop.gd"))
			prop.kind = kind
			# Its local position selects a deterministic crown variant.
			var holder := Node2D.new()
			holder.position = Vector2(64-variant,128)
			viewport.add_child(holder)
			prop.position = Vector2(variant,0)
			holder.add_child(prop)
			await process_frame
			await RenderingServer.frame_post_draw
			assert(viewport.get_texture().get_image().save_png("res://assets/forest/prop_%d_%d.png" % [kind,variant]) == OK)
			holder.queue_free()
			await process_frame
	viewport.queue_free()
	# Bake ground separately from stateful bridge, light, actors and HUD.
	var world := load("res://scenes/briarwood_forest.tscn").instantiate() as Node2D
	root.add_child(world)
	await process_frame
	var ground: Node2D = world.get_node("Landscape").get_child(0)
	var ground_view := SubViewport.new()
	ground_view.size = Vector2i(2048,1024)
	ground_view.transparent_bg = true
	ground_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	root.add_child(ground_view)
	ground_view.canvas_transform = Transform2D(0,Vector2(1024,512))
	var fake_world := Node2D.new()
	ground_view.add_child(fake_world)
	var actors := Node2D.new()
	actors.name = "Actors"
	fake_world.add_child(actors)
	for original: Node2D in world.get_node("Actors").get_children():
		if original.get("kind") is int and original.kind in [0,1]:
			var copy := Node2D.new()
			copy.set_script(load("res://scripts/world/briarwood_dressing.gd"))
			copy.kind = original.kind
			copy.position = original.position
			copy.visible = false
			actors.add_child(copy)
	var landscape := Node2D.new()
	fake_world.add_child(landscape)
	ground.reparent(landscape)
	ground.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(ground_view.get_texture().get_image().save_png("res://assets/forest/ground.png") == OK)
	print("Baked 13 prop textures and static ground, original local artwork.")
	quit()

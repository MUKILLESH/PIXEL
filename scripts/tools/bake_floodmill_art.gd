extends SceneTree
## Regenerate original cached Floodmill art with -- --bake-floodmill.
func _initialize() -> void:
	call_deferred("bake")
func save_view(view: SubViewport, path: String) -> bool:
	await process_frame
	await RenderingServer.frame_post_draw
	var error := view.get_texture().get_image().save_png(path)
	if error != OK:
		push_error("Failed to bake "+path)
		quit(1)
		return false
	return true
func bake() -> void:
	if not "--bake-floodmill" in OS.get_cmdline_user_args():
		push_error("Pass -- --bake-floodmill to render procedural source.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://assets/floodmill")
	var view := SubViewport.new()
	view.size = Vector2i(192,192)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	for kind in range(4):
		for state in range(2 if kind == 3 else 1):
			var building := StaticBody2D.new()
			building.set_script(load("res://scripts/world/floodmill_building.gd"))
			building.kind = kind
			building.watermill_active = state == 1
			building.position = Vector2(96,160)
			view.add_child(building)
			if not await save_view(view,"res://assets/floodmill/building_%d_%d.png" % [kind,state]): return
			building.queue_free()
			await process_frame
	view.size = Vector2i(128,128)
	for kind in range(7):
		var prop := StaticBody2D.new()
		prop.set_script(load("res://scripts/world/floodmill_prop.gd"))
		prop.kind = kind
		prop.position = Vector2(64,112)
		view.add_child(prop)
		if not await save_view(view,"res://assets/floodmill/prop_%d.png" % kind): return
		prop.queue_free()
		await process_frame
	view.size = Vector2i(2048,1024)
	var floor_node := Node2D.new()
	floor_node.set_script(load("res://scripts/world/floodmill_ground.gd"))
	floor_node.position = Vector2(1024,512)
	view.add_child(floor_node)
	if not await save_view(view,"res://assets/floodmill/ground.png"): return
	print("GFX3 BAKE COMPLETE: 5 building states, 7 props, static ground.")
	quit()

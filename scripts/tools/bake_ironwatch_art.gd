extends SceneTree
## Offline source rasterization. Use -- --bake-ironwatch; never executed by gameplay.
class ArchivePainter extends Node2D:
	func _draw() -> void:
		preload("res://scripts/world/ironwatch_art.gd").archive(self)
func _initialize() -> void:
	call_deferred("bake")
func save_view(view: SubViewport, path: String) -> bool:
	await process_frame
	await RenderingServer.frame_post_draw
	if view.get_texture().get_image().save_png(path) != OK:
		push_error("Bake failed: "+path)
		quit(1)
		return false
	return true
func bake() -> void:
	if not "--bake-ironwatch" in OS.get_cmdline_user_args():
		push_error("Pass -- --bake-ironwatch")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://assets/ironwatch")
	var view := SubViewport.new()
	view.size = Vector2i(256,320)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	for kind: String in ["gatehouse_bastion","ruined_barracks","cutaway_archives","hall_of_crests","shadow_colonnade","beacon_vault_sanctum"]:
		for state in range(2 if kind == "beacon_vault_sanctum" else 1):
			var building := StaticBody2D.new()
			building.set_script(load("res://scripts/world/ironwatch_building.gd"))
			building.kind = kind
			building.third_beacon_lit = state == 1
			building.position = Vector2(128,224)
			view.add_child(building)
			if building.interior_visual != null: building.interior_visual.hide()
			if not await save_view(view,"res://assets/ironwatch/"+kind+"_"+str(state)+".png"): return
			building.queue_free()
			await process_frame
	var interior := ArchivePainter.new()
	interior.position = Vector2(128,224)
	view.add_child(interior)
	if not await save_view(view,"res://assets/ironwatch/archives_interior.png"): return
	interior.queue_free()
	await process_frame
	for kind: String in ["curtain","retaining","low_wall","tower","throne","armor"]:
		var decor := Node2D.new()
		decor.set_script(load("res://scripts/world/ironwatch_dressing.gd"))
		decor.kind = kind
		decor.position = Vector2(128,224)
		view.add_child(decor)
		if not await save_view(view,"res://assets/ironwatch/decor_"+kind+".png"): return
		decor.queue_free()
		await process_frame
	view.size = Vector2i(2048,1024)
	var floor_node := Node2D.new()
	floor_node.set_script(load("res://scripts/world/ironwatch_ground.gd"))
	floor_node.position = Vector2(1024,512)
	view.add_child(floor_node)
	if not await save_view(view,"res://assets/ironwatch/ground.png"): return
	print("GFX4 BAKE COMPLETE: 7 building states, archive interior, 6 decorations, ground.")
	quit()

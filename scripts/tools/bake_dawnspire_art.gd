extends SceneTree
const Art = preload("res://scripts/world/dawnspire_art.gd")
class Painter extends Node2D:
	var kind: String
	var active: bool
	func _draw() -> void:
		if kind == "chapel_interior": Art.chapel(self)
		else: Art.building(self,kind,active)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/dawnspire")
	var view := SubViewport.new()
	view.size = Vector2i(256,320)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	for kind: String in ["foothills_arch","cliff_shelter","skybridge_anchors","pilgrim_chapel","observatory_dome","dawnspire_sanctum","great_bell_portal","chapel_interior"]:
		for state in range(2 if kind in ["dawnspire_sanctum","great_bell_portal"] else 1):
			var p := Painter.new()
			p.kind = kind
			p.active = state == 1
			p.position = Vector2(128,224)
			view.add_child(p)
			await process_frame
			await RenderingServer.frame_post_draw
			var path: String = kind if kind == "chapel_interior" else kind+"_"+str(state)
			if view.get_texture().get_image().save_png("res://assets/dawnspire/"+path+".png") != OK:
				quit(1)
				return
			p.queue_free()
			await process_frame
	view.size = Vector2i(2048,1280)
	var ground := Node2D.new()
	ground.set_script(load("res://scripts/world/dawnspire_ground.gd"))
	ground.position = Vector2(1024,640)
	view.add_child(ground)
	await process_frame
	await RenderingServer.frame_post_draw
	if view.get_texture().get_image().save_png("res://assets/dawnspire/ground.png") != OK:
		quit(1)
		return
	print("GFX5 BAKE COMPLETE: 9 architecture states, chapel interior, ground")
	quit()

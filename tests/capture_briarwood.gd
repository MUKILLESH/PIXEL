extends SceneTree
## Generates Phase 2 visual review PNG captures across Briarwood Forest scenes, minigames, and completion UI.

func _initialize() -> void:
	call_deferred("capture")

func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame

func read_through(hud: CanvasLayer) -> void:
	var safety: int = 12
	while hud.get_node("Message").visible and safety > 0:
		safety -= 1
		await press("interact")
		await process_frame

func capture() -> void:
	var world := load("res://scenes/briarwood_forest.tscn").instantiate() as Node2D
	root.add_child(world)
	var player: CharacterBody2D = world.get_node("Actors/Player")
	var hud: CanvasLayer = world.get_node("HUD")
	var qm: Node = world.get_node("QuestManager")
	var cam: Camera2D = player.get_node("Camera2D")

	await create_timer(0.2).timeout

	# 1. Forest Edge + Historian Lyra conversation
	qm.complete_objective("enter_briarwood")
	player.position = Vector2(28, 192)
	cam.snap_to_target()
	await create_timer(0.15).timeout
	await press("interact")
	await create_timer(0.12).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/briarwood_edge_lyra.png")
	await read_through(hud)

	# 2. Old Bridge + Bridge Repair Minigame open
	qm.complete_objective("investigate_bridge")
	qm.record_material_collected("plank_1")
	qm.record_material_collected("plank_2")
	qm.record_material_collected("rope_coil")
	player.position = Vector2(-90, 18)
	cam.snap_to_target()
	await create_timer(0.15).timeout
	await press("interact")
	await create_timer(0.20).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/briarwood_bridge_repair.png")

	var bridge_ui: Panel = hud.get_node("BridgeRepair")
	bridge_ui.set_step_material(0, "LEFT BEAM")
	bridge_ui.set_step_material(1, "RIGHT PLANK")
	bridge_ui.set_step_material(2, "ROPE LASHING")
	bridge_ui.verify_repair()
	await create_timer(0.1).timeout
	await read_through(hud)

	# 3. Mirror Grove + Light Puzzle open
	qm.record_inscription_read("west")
	qm.record_inscription_read("center")
	qm.record_inscription_read("east")
	player.position = Vector2(-132, -124)
	cam.snap_to_target()
	await create_timer(0.15).timeout
	await press("interact")
	await create_timer(0.20).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/briarwood_mirror_puzzle.png")

	var mirror_ui: Panel = hud.get_node("MirrorPuzzle")
	mirror_ui.set_mirror_angle(0, "DAWN")
	mirror_ui.set_mirror_angle(1, "ZENITH")
	mirror_ui.set_mirror_angle(2, "DUSK")
	mirror_ui.verify_mirrors()
	await create_timer(0.1).timeout
	await read_through(hud)

	# 4. First Beacon Shrine activated & Chapter 1 completion banner
	qm.complete_objective("activate_first_beacon")
	qm.complete_objective("experience_elena_recording")
	player.position = Vector2(-16, -190)
	cam.snap_to_target()
	await create_timer(0.2).timeout
	player.position = Vector2(28, -186)
	cam.snap_to_target()
	await create_timer(0.15).timeout
	await press("interact")
	await read_through(hud)
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/briarwood_beacon_complete.png")
	await press("interact")
	await create_timer(0.1).timeout

	# 4b. Field Satchel Inventory & Title/System Menu captures at 640x360 native scale
	qm.record_optional_discovery("ruined_camp_relic")
	hud.open_inventory()
	await create_timer(0.12).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/phase2_5_satchel.png")
	hud.get_node("InventoryPanel").close_inventory()
	await create_timer(0.08).timeout
	hud.open_title_menu("CHRONICLE SAVE READY - CONTINUE OR SAVE ANYTIME")
	await create_timer(0.12).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/phase2_5_menu.png")
	hud.get_node("TitleMenu").close_menu()
	await create_timer(0.08).timeout

	# 5. Wider high-res overview showing Bridge, Mirror Grove beams, First Beacon glow, and Shrine
	root.content_scale_size = Vector2i(960, 540)
	root.size = Vector2i(960, 540)
	player.position = Vector2(-44, -66)
	cam.snap_to_target()
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/briarwood_overview.png")
	quit()

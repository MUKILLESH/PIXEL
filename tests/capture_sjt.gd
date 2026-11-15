extends SceneTree
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

func capture() -> void:
	var world := load("res://scenes/sjt_exterior.tscn").instantiate() as Node2D
	root.add_child(world)
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/sjt_preview.png")

	var player: CharacterBody2D = world.get_node("Actors/Player")
	var hud: CanvasLayer = world.get_node("HUD")
	var qm: Node = world.get_node("QuestManager")
	var caelen: StaticBody2D = world.get_node("Actors/MasterCaelen")

	player.position = Vector2(20, 20)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/sjt_entrance.png")

	player.position = Vector2(150, 85)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/sjt_single_prompt.png")

	# Phase 1 capture: speaking with Master Caelen after inspecting pedestal
	qm.complete_objective("investigate_bell")
	player.position = caelen.position + Vector2(0, 20)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.15).timeout
	await press("interact")
	await create_timer(0.10).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/phase1_dialogue.png")
	await press("dismiss")

	# Phase 1 capture: Rune-Alignment Minigame open
	qm.record_npc_talked("caelen")
	qm.record_npc_talked("mira")
	qm.record_npc_talked("elara")
	qm.complete_objective("find_mothers_letter")
	player.position = Vector2(120, 79)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.15).timeout
	await press("interact")
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/phase1_rune_puzzle.png")

	# Solve puzzle, awaken pedestal & Briarwood ray, capture completion screen
	var puzzle: Panel = hud.get_node("RunePuzzle")
	puzzle.set_disc_symbol(0, "MOON")
	puzzle.set_disc_symbol(1, "SUN")
	puzzle.set_disc_symbol(2, "STAR")
	puzzle.verify_alignment()
	await create_timer(0.10).timeout
	while hud.get_node("Message").visible:
		await press("interact")
	player.position = world.get_node("Actors/BriarwoodGate").position + Vector2(18, 12)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.15).timeout
	await press("interact")
	while hud.get_node("Message").visible:
		await press("interact")
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/phase1_complete.png")
	await press("interact")

	# Wider native-resolution review image with awakened Bellhaven Village
	root.content_scale_size = Vector2i(960, 540)
	root.size = Vector2i(960, 540)
	player.position = Vector2(10, 95)
	player.get_node("Camera2D").snap_to_target()
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/sjt_overview.png")
	quit()

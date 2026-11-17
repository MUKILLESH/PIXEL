extends SceneTree
## Generates 6 visual verification screenshots for Phase 8 fixes under docs/phase8/.

const QuestManagerScript = preload("res://scripts/systems/quest_manager.gd")

func _init() -> void:
	call_deferred("capture")

func frames(count: int = 5) -> void:
	for _i in range(count):
		await physics_frame

func _wait_scene(expected: String) -> Node2D:
	for _i in range(50):
		await process_frame
		if current_scene != null and current_scene.name == expected:
			await frames(5)
			return current_scene as Node2D
	return null

func _snap_and_save(world: Node2D, player_pos: Vector2, facing: int, out_png: String) -> void:
	var player := world.get_node("Actors/Player") as CharacterBody2D
	var cam := world.get_node("Actors/Player/Camera2D") as Camera2D
	player.position = player_pos
	player.facing = facing
	player.queue_redraw()
	if cam != null and cam.has_method("snap_to_target"):
		cam.snap_to_target()
	await frames(6)
	root.get_texture().get_image().save_png(out_png)
	print("SAVED: " + out_png)

func capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/phase8"))
	QuestManagerScript.reset_session_state()

	# 1. Bellhaven clear paths & clamped NW/SW view
	change_scene_to_file("res://scenes/sjt_exterior.tscn")
	var bh := await _wait_scene("BellhavenVillage")
	if bh == null:
		quit(1)
		return
	await _snap_and_save(bh, Vector2(20, 152), 2, "res://docs/phase8/bellhaven_clear_paths.png")

	# 2. Bellhaven Sunrise revisited after Great Bell + Briarwood round-trip
	QuestManagerScript.carry_prologue_completed = true
	QuestManagerScript.carry_chapter1_completed = true
	QuestManagerScript.carry_chapter2_completed = true
	QuestManagerScript.carry_chapter3_completed = true
	QuestManagerScript.carry_chapter4_completed = true
	QuestManagerScript.carry_storm_resolved = true
	bh.quest_manager.prologue_completed = true
	bh.quest_manager.briarwood_unlocked = true
	bh.quest_manager.chapter1_completed = true
	bh.quest_manager.chapter5_completed = true
	bh.quest_manager.storm_resolved = true
	bh.quest_manager.credits_viewed = true
	bh.quest_manager.current_index = bh.quest_manager.objectives.size()
	bh.travel_to_briarwood()
	var bw := await _wait_scene("BriarwoodForest")
	if bw == null:
		quit(1)
		return
	bw.travel_to_bellhaven()
	var bh_sun := await _wait_scene("BellhavenVillage")
	if bh_sun == null:
		quit(1)
		return
	await _snap_and_save(bh_sun, Vector2(0, 128), 0, "res://docs/phase8/bellhaven_sunrise_revisited.png")

	# 3 & 4. Briarwood river boundary before & after bridge repair
	QuestManagerScript.reset_session_state()
	change_scene_to_file("res://scenes/briarwood_forest.tscn")
	bw = await _wait_scene("BriarwoodForest")
	if bw == null:
		quit(1)
		return
	await _snap_and_save(bw, Vector2(220, 2), 0, "res://docs/phase8/briarwood_river_blocked.png")
	bw.quest_manager.materials_collected = {"plank_1": true, "plank_2": true, "rope_coil": true}
	bw.quest_manager.bridge_repaired = true
	bw._sync_world_from_quest()
	await frames(3)
	await _snap_and_save(bw, Vector2(-90, -18), 0, "res://docs/phase8/briarwood_bridge_open.png")

	# 5. Floodmill canal & millpond + clamped SE camera
	change_scene_to_file("res://scenes/floodmill_village.tscn")
	var fm := await _wait_scene("FloodmillVillage")
	if fm == null:
		quit(1)
		return
	await _snap_and_save(fm, Vector2(198, 48), 2, "res://docs/phase8/floodmill_canal_millpond.png")

	# 6. Dawnspire Summit Plateau cliff boundary & camera clamp
	change_scene_to_file("res://scenes/dawnspire_mountain.tscn")
	var ds := await _wait_scene("DawnspireMountain")
	if ds == null:
		quit(1)
		return
	await _snap_and_save(ds, Vector2(-128, -195), 6, "res://docs/phase8/dawnspire_summit_clamped.png")

	print("PHASE 8 SCREENSHOT CAPTURE COMPLETE")
	quit(0)

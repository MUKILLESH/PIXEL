extends SceneTree
var failures: int = 0
var checks: int = 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame

func key(action: String) -> void:
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

func run() -> void:
	var result: Variant = await exercise()
	check(result == true,"Test suite reached its end")
	if "--force-failure" in OS.get_cmdline_user_args():
		check(false,"Deliberate failure verifies exit code")
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func exercise() -> bool:
	var packed := load("res://scenes/campus_prototype.tscn") as PackedScene
	check(packed != null,"Startup scene loads")
	var world := packed.instantiate()
	root.add_child(world)
	await frames(3)
	var player := world.get_node("Actors/Player") as CharacterBody2D
	var ground := world.get_node("Ground") as TileMapLayer
	var terminal := world.get_node("Actors/Terminal") as StaticBody2D
	var hud := world.get_node("HUD")
	check(ground.get_used_cells().size() == 2401,"2401 cells cover courtyard and scenery apron")
	check(ground.tile_set.tile_size == Vector2i(64,32),"64 x 32 tiles")
	var dx: Vector2 = ground.map_to_local(Vector2i(1,0)) - ground.map_to_local(Vector2i.ZERO)
	check(absf(dx.x) == 32 and absf(dx.y) == 16,"2:1 diamond coordinate mapping")
	check(world.get_node("Actors").y_sort_enabled,"World actors Y sorted")
	check(player.position.is_equal_approx(Vector2(0,65)),"Spawn is stable without input")
	check(not player.test_move(player.global_transform,Vector2(0,0.1)),"Spawn has no collision overlap")
	check(player.get_node("Camera2D").is_current(),"Player camera active")
	var camera := player.get_node("Camera2D") as Camera2D
	check(camera.global_position == camera.global_position.round(),"Camera renders at whole pixels")
	# Check viewport coverage at each extreme of the playable diamond.
	for tip: Vector2 in [Vector2(0,-320),Vector2(672,16),Vector2(0,352),Vector2(-672,16)]:
		for corner: Vector2 in [Vector2(-320,-180),Vector2(320,-180),Vector2(320,180),Vector2(-320,180)]:
			var cell: Vector2i = ground.local_to_map(tip + camera.framing + corner)
			check(ground.get_cell_source_id(cell) != -1,"Ground covers camera edge %s / %s" % [tip,corner])
	await key("interact")
	check(not hud.get_node("Message").visible,"Out-of-range E does not open message")
	var previous_camera: Vector2 = camera.global_position
	Input.action_press("move_down")
	var camera_monotonic: bool = true
	var camera_snapped: bool = true
	for tick in range(30):
		await frames(1)
		camera_monotonic = camera_monotonic and camera.global_position.y >= previous_camera.y
		camera_snapped = camera_snapped and camera.global_position == camera.global_position.round()
		previous_camera = camera.global_position
	Input.action_release("move_down")
	check(camera_monotonic and camera_snapped,"Moving camera advances without backward jitter or fractional scroll")
	check(camera.global_position.y < player.position.y + camera.framing.y,"Camera eases behind movement")
	var straight: float = player.position.distance_to(Vector2(0,65))
	check(straight > 45 and straight < 55,"WASD action moves at configured speed")
	player.position = Vector2(0,65)
	Input.action_press("move_right")
	Input.action_press("move_down")
	await frames(30)
	Input.action_release("move_right")
	Input.action_release("move_down")
	check(absf(player.position.distance_to(Vector2(0,65))-straight) < 3,"Diagonal speed normalized")
	check(player.get("facing") == 1,"Diagonal facing tracked")
	await frames(2)
	var stopped: Vector2 = player.position
	await frames(5)
	check(player.position.is_equal_approx(stopped),"No drift after release")
	# Real physics motion against the south tip of a building and tree trunk.
	for point: Vector2 in [Vector2(-190,-30),Vector2(-195,100),Vector2(45,0)]:
		player.position = point + Vector2(0,30)
		Input.action_press("move_up")
		await frames(30)
		Input.action_release("move_up")
		check(player.position.y > point.y,"Solid blocks movement at %s" % point)
	player.position = terminal.position + Vector2(0,30)
	await frames(3)
	check(terminal.get_node("Indicator").visible,"Nearby interaction indicator visible")
	await key("interact")
	check(hud.get_node("Message").visible,"E opens terminal message")
	check(not terminal.get_node("Indicator").visible and not hud.get_node("Prompt").visible,"Prompts hidden during dialogue")
	var repeat_key := InputEventKey.new()
	repeat_key.physical_keycode = KEY_E
	repeat_key.pressed = true
	repeat_key.echo = true
	Input.parse_input_event(repeat_key)
	await frames(3)
	check(hud.get_node("Message").visible,"Keyboard repeat does not dismiss or retrigger")
	check(hud.get_node("Message/Text").text == "The bell has rung thirteen times. Something beneath the village is awakening.","Exact introductory message")
	Input.action_press("move_down")
	stopped = player.position
	await frames(8)
	Input.action_release("move_down")
	check(player.position.is_equal_approx(stopped),"Message locks movement")
	await key("interact")
	check(not hud.get_node("Message").visible,"E dismisses without reopening")
	await key("interact")
	await key("dismiss")
	check(not hud.get_node("Message").visible,"Escape dismisses")
	check(terminal.get_node("Indicator").visible,"Prompt restored after dismissal")
	# Every direction has a stable facing; animation advances during free movement.
	var directions: Array[Vector2] = [Vector2.RIGHT,Vector2(1,1),Vector2.DOWN,Vector2(-1,1),Vector2.LEFT,Vector2(-1,-1),Vector2.UP,Vector2(1,-1)]
	for i in range(8):
		player.position = Vector2.ZERO
		var d: Vector2 = directions[i]
		for action: String in ["move_left","move_right","move_up","move_down"]:
			Input.action_release(action)
		if d.x != 0: Input.action_press("move_right" if d.x > 0 else "move_left")
		if d.y != 0: Input.action_press("move_down" if d.y > 0 else "move_up")
		await frames(9)
		check(player.get("facing") == i,"Facing direction %d" % i)
		check(player.get("walk_frame") != 0,"Walking pose advances for direction %d" % i)
		for action: String in ["move_left","move_right","move_up","move_down"]:
			Input.action_release(action)
		await frames(2)
	await frames(60)
	check(camera.global_position.distance_to(player.position + camera.framing) < 1.5,"Smoothed camera settles on target")
	player.position = Vector2(0,340)
	Input.action_press("move_down")
	await frames(20)
	Input.action_release("move_down")
	check(player.position.y < 352,"Map boundary blocks exit")
	world.queue_free()
	await process_frame
	return true

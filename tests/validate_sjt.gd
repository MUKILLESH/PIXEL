extends SceneTree
var failed: int = 0
var checked: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, description: String) -> void:
	checked += 1
	if value:
		print("PASS: ",description)
	else:
		failed += 1
		push_error("FAIL: " + description)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
	await process_frame

func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventAction.new()
	event.action = action
	Input.parse_input_event(event)
	await process_frame

func run() -> void:
	var result: Variant = await exercise()
	check(result == true,"Suite completed")
	print("SJT RESULT: %d checks, %d failures" % [checked,failed])
	quit(1 if failed else 0)

func exercise() -> bool:
	var world := load("res://scenes/sjt_exterior.tscn").instantiate() as Node2D
	root.add_child(world)
	await frames(3)
	var player: CharacterBody2D = world.get_node("Actors/Player")
	var building: StaticBody2D = world.get_node("Actors/SJT")
	var camera: Camera2D = player.get_node("Camera2D")
	var ground: TileMapLayer = world.get_node("Ground")
	var hud: CanvasLayer = world.get_node("HUD")
	check(player.position == Vector2(10,44),"SJT spawn stable")
	check(not player.test_move(player.global_transform,Vector2(0,0.1)),"Spawn outside solids")
	check(building.get_node("Footprint").polygon.size() == 4,"Solid projected footprint")
	check(building.y_sort_enabled and world.get_node("Actors").y_sort_enabled,"Nested facade depth sorting")
	check(building.get_node("CanopyRoof") != null,"Canopy is separate from building footprint")
	# Walk through the open forecourt under the canopy up to the solid entrance.
	player.position = Vector2(34,30)
	Input.action_press("move_up")
	await frames(22)
	Input.action_release("move_up")
	check(player.position.y < 0,"Entrance route beneath canopy is walkable")
	Input.action_press("move_up")
	await frames(45)
	Input.action_release("move_up")
	# move_and_slide legitimately travels along the diagonal facade. Test its
	# signed distance and actual contact, not an axis-aligned stopping coordinate.
	var facade_distance: float = player.position.y + player.position.x * 0.5 + 16
	check(facade_distance > 5 and facade_distance < 10 and player.get_slide_collision_count() > 0,"Entrance wall blocks penetration while allowing sliding")
	for u in [76,148]:
		var column: StaticBody2D = building.get_node("CanopyColumn%d" % u)
		player.global_position = column.global_position + Vector2(0,16)
		check(player.test_move(player.global_transform,Vector2(0,-20)),"Canopy column %d is solid" % u)
	for landmark_name: String in ["Basin","Monument"]:
		var object: StaticBody2D = world.get_node("Actors/" + landmark_name)
		player.position = object.position + Vector2(0,25)
		check(player.test_move(player.global_transform,Vector2(0,-32)),landmark_name + " footprint blocks walking")
	# Walk from forecourt to terminal without teleporting through a solid.
	player.position = Vector2(34,30)
	Input.action_press("move_right")
	await frames(50)
	Input.action_release("move_right")
	check(player.position.x > 110,"Forecourt route to terminal remains open")
	await frames(3)
	check(world.get_node("Actors/Terminal/Indicator").visible,"Terminal proximity works in SJT region")
	await press("interact")
	check(hud.get_node("Message").visible,"Preserved terminal message opens")
	check(player.movement_locked,"Reading locks movement")
	await press("dismiss")
	check(not hud.get_node("Message").visible and not player.movement_locked,"Dismiss restores exploration")
	for tip: Vector2 in [Vector2(0,-320),Vector2(672,16),Vector2(0,352),Vector2(-672,16)]:
		for corner: Vector2 in [Vector2(-320,-180),Vector2(320,-180),Vector2(320,180),Vector2(-320,180)]:
			check(ground.get_cell_source_id(ground.local_to_map(tip+camera.framing+corner)) != -1,"Scenery covers edge %s / %s" % [tip,corner])
	check(FileAccess.file_exists("res://docs/references/.gdignore"),"Third-party reference folder excluded from resource scan")
	world.queue_free()
	await process_frame
	return true

extends SceneTree
## Bounded physics-space flood fill proves visual dressing has not sealed any approach.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world := load("res://scenes/ironwatch_keep.tscn").instantiate() as Node2D
	root.add_child(world)
	world.set_physics_process(false)
	world.get_node("QuestManager").crest_puzzle_solved = true
	world.get_node("QuestManager").shadow_passage_cleared = true
	world._sync_world_from_quest()
	await physics_frame
	await physics_frame
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.set_physics_process(false)
	var targets: Array[String] = ["CourtyardArch","FloodmillReturnGate","CourtyardMonument","WardenRecords","BarracksLog","BarracksKeepsake","CrestClue1","CrestClue2","CrestClue3","CrestAltar","ShadowWardSwitch","ElenaResearch","ThirdBeacon","DawnspireGate","LastWarden","Lyra"]
	var reached: Dictionary = {}
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [Vector2i(17,25)]
	visited[queue[0]] = true
	var cursor: int = 0
	var shape := CircleShape2D.new()
	shape.radius = 6
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1
	var space := world.get_world_2d().direct_space_state
	while cursor < queue.size() and cursor < 10000 and reached.size() < targets.size():
		var cell: Vector2i = queue[cursor]
		cursor += 1
		var point := Vector2(cell)*8
		for name: String in targets:
			var target: Node2D = world.get_node("Actors/"+name)
			if point.distance_to(target.position) <= 28:
				reached[name] = true
		for direction: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+direction
			if visited.has(next) or absi(next.x)>60 or next.y < -38 or next.y>36: continue
			visited[next] = true
			query.transform = Transform2D(0,Vector2(next)*8)
			if space.intersect_shape(query,1).is_empty(): queue.append(next)
	var failures: int = 0
	for name: String in targets:
		if not reached.has(name):
			failures += 1
			push_error("UNREACHABLE: "+name)
		else: print("PASS reachable: ",name)
	print("GFX4 REACHABILITY: %d/16, %d cells visited; %d failures" % [reached.size(),cursor,failures])
	var contracts: Array = [["ground.png",Vector2i(2048,1024)],["archives_interior.png",Vector2i(256,320)]]
	for kind: String in ["gatehouse_bastion","ruined_barracks","cutaway_archives","hall_of_crests","shadow_colonnade","beacon_vault_sanctum"]:
		for state in range(2 if kind == "beacon_vault_sanctum" else 1):
			contracts.append([kind+"_"+str(state)+".png",Vector2i(256,320)])
	for kind: String in ["curtain","retaining","low_wall","tower","throne","armor"]:
		contracts.append(["decor_"+kind+".png",Vector2i(256,320)])
	for contract: Array in contracts:
		var path: String = "res://assets/ironwatch/"+contract[0]
		var raster := Image.load_from_file(ProjectSettings.globalize_path(path))
		if raster == null or raster.get_size() != contract[1] or raster.get_pixel(0,0).a != 0:
			failures += 1
			push_error("Invalid raster: "+path)
	print("GFX4 RASTER CONTRACT: 15 files checked; total failures=",failures)
	var decor_count: int = 0
	for child: Node in world.get_node("Actors").get_children():
		if child.get_script() == preload("res://scripts/world/ironwatch_dressing.gd"):
			decor_count += 1
			if child is CollisionObject2D:
				failures += 1
				push_error("Dressing must not have collision")
	if decor_count != 32:
		failures += 1
		push_error("Expected 32 non-blocking visual pieces, found "+str(decor_count))
	print("GFX4 DECOR: ",decor_count," pieces; total failures=",failures)
	world.queue_free()
	await process_frame
	quit(1 if failures else 0)

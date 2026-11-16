extends SceneTree
## Bounded physics-space flood fill proves visual dressing has not sealed any approach.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world := load("res://scenes/floodmill_village.tscn").instantiate() as Node2D
	root.add_child(world)
	world.get_node("QuestManager").sluice_solved = true
	world._sync_world_from_quest()
	await physics_frame
	await physics_frame
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.set_physics_process(false)
	var targets: Array[String] = ["FloodmillEntranceArch","VillageMonument","HomesteadRelic","BrokenWatermill","MillDiagram","MillPartGear","MillPartPinion","MillPartBelt","SluiceConsole","CanalGauge","ArchiveEntrance","ArchiveRecordCensus","ArchiveRecordTribute","ArchiveRecordTransfer","LedgerTable","SecondBeacon","IronwatchGate","Lyra"]
	var reached: Dictionary = {}
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [Vector2i(-22,25)]
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
	print("GFX3 REACHABILITY: %d/18, %d cells visited; %d failures" % [reached.size(),cursor,failures])
	var contracts: Array = [["ground.png",Vector2i(2048,1024)]]
	for kind in range(4):
		for state in range(2 if kind == 3 else 1):
			contracts.append(["building_%d_%d.png" % [kind,state],Vector2i(192,192)])
	for kind in range(7): contracts.append(["prop_%d.png" % kind,Vector2i(128,128)])
	for contract: Array in contracts:
		var path: String = "res://assets/floodmill/"+contract[0]
		var raster := Image.load_from_file(ProjectSettings.globalize_path(path))
		if raster == null or raster.get_size() != contract[1] or raster.get_pixel(0,0).a != 0:
			failures += 1
			push_error("Invalid raster: "+path)
	print("GFX3 RASTER CONTRACT: 13 files checked; total failures=",failures)
	world.queue_free()
	await process_frame
	quit(1 if failures else 0)

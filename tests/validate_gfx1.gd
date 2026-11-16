extends SceneTree
## Bounded physics-space flood fill proves visual dressing has not sealed any approach.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world := load("res://scenes/sjt_exterior.tscn").instantiate() as Node2D
	root.add_child(world)
	await physics_frame
	await physics_frame
	var player: CharacterBody2D = world.get_node("Actors/Player")
	player.set_physics_process(false)
	var targets: Array[String] = ["Terminal","NoticeBoard","MasterCaelen","Mira","SisterElara","MothersLetter","BriarwoodGate"]
	var reached: Dictionary = {}
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [Vector2i(1,6)]
	visited[queue[0]] = true
	var cursor: int = 0
	var shape := CircleShape2D.new()
	shape.radius = 6
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1
	var space := world.get_world_2d().direct_space_state
	while cursor < queue.size() and cursor < 6000 and reached.size() < targets.size():
		var cell: Vector2i = queue[cursor]
		cursor += 1
		var point := Vector2(cell)*8
		for name: String in targets:
			var target: Node2D = world.get_node("Actors/"+name)
			if point.distance_to(target.position) <= 28:
				reached[name] = true
		for direction: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+direction
			if visited.has(next) or absi(next.x)>43 or next.y < -25 or next.y>35: continue
			visited[next] = true
			query.transform = Transform2D(0,Vector2(next)*8)
			if space.intersect_shape(query,1).is_empty(): queue.append(next)
	var failures: int = 0
	for name: String in targets:
		if not reached.has(name):
			failures += 1
			push_error("UNREACHABLE: "+name)
		else: print("PASS reachable: ",name)
	print("GFX1 REACHABILITY: %d/7, %d cells visited; %d failures" % [reached.size(),cursor,failures])
	world.queue_free()
	await process_frame
	quit(1 if failures else 0)

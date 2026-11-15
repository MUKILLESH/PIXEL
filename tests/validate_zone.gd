extends "res://tests/validate_sjt.gd"
## Extends the existing SJT collision/route suite with overlapping-object regressions.
func exercise() -> bool:
	if await super.exercise() != true:
		return false
	var world := load("res://scenes/sjt_exterior.tscn").instantiate() as Node2D
	root.add_child(world)
	await frames(3)
	var player: CharacterBody2D = world.get_node("Actors/Player")
	var hud: CanvasLayer = world.get_node("HUD")
	var terminal: StaticBody2D = world.get_node("Actors/Terminal")
	var board: StaticBody2D = world.get_node("Actors/NoticeBoard")
	player.position = Vector2(150,85)
	await frames(4)
	check(terminal.nearby_player != null and board.nearby_player != null,"Overlapping interaction ranges exercised")
	check(terminal.selected and not board.selected,"Priority beats distance")
	check(prompt_count(world) == 1 and not hud.get_node("Prompt").visible,"Only one world prompt, no duplicate HUD prompt")
	board.interaction_priority = terminal.interaction_priority
	await frames(2)
	check(board.selected and not terminal.selected,"Equal priorities choose nearest")
	player.position = Vector2(140,60)
	await frames(3)
	check(board.selected,"Equal distance uses stable node-path tie break")
	board.interaction_priority = 1
	player.position = Vector2(190,80)
	await frames(4)
	check(board.selected and prompt_count(world) == 1,"Leaving highest-priority range hands off prompt")
	var objective: String = hud.get_node("Objective").text
	await press("interact")
	await frames(2)
	check(hud.get_node("Message/Text").text == board.message,"Only selected object's message opens")
	check(prompt_count(world) == 0,"All nearby prompts suppressed while reading")
	check(hud.get_node("Objective").text == objective,"Decorative notice does not advance mystery objective")
	await press("dismiss")
	await frames(2)
	check(prompt_count(world) == 1 and board.selected,"Dismiss restores selected prompt only")
	player.position = Vector2(-40,70)
	await frames(4)
	check(prompt_count(world) == 0,"Leaving all ranges clears prompts")
	check(player.scale == Vector2.ONE and player.get_node("Feet").shape.radius == 6,"Player scale and foot collision preserved")
	var furnishings: int = 0
	for actor: Node in world.get_node("Actors").get_children():
		if actor.get_script() == preload("res://scripts/world/campus_furniture.gd"):
			furnishings += 1
			check(actor.get_child(0) is CollisionPolygon2D,"Furniture has ground collision")
	check(furnishings == 12,"Twelve local decorative furnishings")
	var loop := PackedVector2Array([Vector2(-155,160),Vector2(-80,198),Vector2(25,221),Vector2(145,165),Vector2(225,125),Vector2(145,85),Vector2(170,85)])
	for i in range(loop.size()-1):
		var pose: Transform2D = player.global_transform
		pose.origin = loop[i]
		check(not player.test_move(pose,loop[i+1]-loop[i]),"Seating loop segment %d clear of furniture" % i)
	check(hud.get_node("Footer").size.y <= 20,"Persistent objective panel under 20 pixels tall")
	world.queue_free()
	await process_frame
	return true

func prompt_count(world: Node) -> int:
	var count: int = 0
	for object: Node in get_nodes_in_group("interactables"):
		if world.is_ancestor_of(object) and object.get_node("Indicator").visible:
			count += 1
	return count


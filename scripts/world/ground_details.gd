extends Node2D
## Shadows belong below ALL actors, so a canopy's shadow never paints over a person.
func _draw() -> void:
	for actor: Node2D in get_parent().get_node("Actors").get_children():
		if actor.get_script() == preload("res://scripts/world/prop.gd"):
			var p: Vector2 = actor.position
			if actor.get("kind") == 1:
				polygon([p+Vector2(-80,-40),p+Vector2(0,0),p+Vector2(80,-40),p+Vector2(115,-16),p+Vector2(35,24)],Color(0.03,0.07,0.1,0.35))
			else:
				polygon([p+Vector2(-23,-4),p+Vector2(-7,-13),p+Vector2(35,-1),p+Vector2(41,7),p+Vector2(15,14)],Color(0.03,0.07,0.1,0.3))
	# Low stone edging explains the collision boundary without blocking the view.
	var corners := PackedVector2Array([Vector2(0,-320),Vector2(672,16),Vector2(0,352),Vector2(-672,16),Vector2(0,-320)])
	draw_polyline(corners,Color("213935"),9)
	draw_polyline(corners,Color("83938a"),3)
	for i in range(4):
		for j in range(1,21):
			var p: Vector2 = corners[i].lerp(corners[i+1],j/21.0).round()
			draw_rect(Rect2(p-Vector2(2,3),Vector2(4,6)),Color("405b51"))

func polygon(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points),color)

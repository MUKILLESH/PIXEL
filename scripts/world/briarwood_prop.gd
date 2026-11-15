extends StaticBody2D
## Original medieval woodland pixel-art props and ruins for Briarwood Forest.

@export_enum("LargeOakTree", "PineSapling", "MossyBoulder", "FallenLog", "RuinedPillar", "CampfireTent", "MirrorStand", "MushroomCluster", "WildflowerPatch") var kind: int = 0

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	if kind in [7, 8]:
		# Decorative mushrooms and wildflowers do not block movement
		z_index = -1
		return
	var shape_node := CollisionShape2D.new()
	match kind:
		0: # LargeOakTree
			var c := CircleShape2D.new()
			c.radius = 9.0
			shape_node.shape = c
			shape_node.position = Vector2(0, -4)
		1, 4, 6: # PineSapling, RuinedPillar, MirrorStand
			var c := CircleShape2D.new()
			c.radius = 6.0
			shape_node.shape = c
			shape_node.position = Vector2(0, -3)
		2: # MossyBoulder
			var r := RectangleShape2D.new()
			r.size = Vector2(20, 10)
			shape_node.shape = r
			shape_node.position = Vector2(0, -3)
		3: # FallenLog
			var r := RectangleShape2D.new()
			r.size = Vector2(28, 8)
			shape_node.shape = r
			shape_node.position = Vector2(0, -3)
		5: # CampfireTent
			var r := RectangleShape2D.new()
			r.size = Vector2(24, 14)
			shape_node.shape = r
			shape_node.position = Vector2(0, -5)
	add_child(shape_node)

func _draw() -> void:
	match kind:
		0: # LargeOakTree
			draw_colored_polygon(PackedVector2Array([Vector2(-22, -2), Vector2(0, -12), Vector2(22, -2), Vector2(0, 8)]), Color(0.02, 0.04, 0.03, 0.38))
			draw_rect(Rect2(-5, -24, 10, 24), Color("543823"))
			draw_rect(Rect2(1, -24, 4, 24), Color("382416"))
			draw_rect(Rect2(-12, -4, 7, 4), Color("452e1c"))
			draw_rect(Rect2(5, -3, 6, 3), Color("452e1c"))
			draw_circle(Vector2(-10, -34), 15.0, Color("20472b"))
			draw_circle(Vector2(10, -34), 14.0, Color("244f30"))
			draw_circle(Vector2(0, -44), 16.0, Color("2e663d"))
			draw_circle(Vector2(-4, -48), 9.0, Color("3c7d4d"))
		1: # PineSapling
			draw_colored_polygon(PackedVector2Array([Vector2(-11, -1), Vector2(0, -6), Vector2(11, -1), Vector2(0, 4)]), Color(0.02, 0.04, 0.03, 0.32))
			draw_rect(Rect2(-2, -14, 4, 14), Color("4f3520"))
			draw_colored_polygon(PackedVector2Array([Vector2(-12, -10), Vector2(0, -24), Vector2(12, -10)]), Color("224a30"))
			draw_colored_polygon(PackedVector2Array([Vector2(-9, -18), Vector2(0, -30), Vector2(9, -18)]), Color("316944"))
		2: # MossyBoulder
			draw_colored_polygon(PackedVector2Array([Vector2(-14, -1), Vector2(0, -7), Vector2(14, -1), Vector2(0, 5)]), Color(0.02, 0.04, 0.03, 0.34))
			draw_colored_polygon(PackedVector2Array([Vector2(-11, 0), Vector2(-9, -11), Vector2(2, -14), Vector2(11, -8), Vector2(10, 0)]), Color("525c56"))
			draw_colored_polygon(PackedVector2Array([Vector2(-8, -11), Vector2(2, -14), Vector2(8, -9), Vector2(-3, -7)]), Color("437045"))
		3: # FallenLog
			draw_rect(Rect2(-16, -7, 32, 8), Color("5e3e24"))
			draw_rect(Rect2(-16, -7, 32, 3), Color("7a5332"))
			draw_rect(Rect2(-10, -8, 9, 3), Color("3c6e41"))
			draw_circle(Vector2(16, -3), 4.0, Color("b08a5a"))
		4: # RuinedPillar
			draw_colored_polygon(PackedVector2Array([Vector2(-10, -1), Vector2(0, -6), Vector2(10, -1), Vector2(0, 4)]), Color(0.02, 0.04, 0.03, 0.34))
			draw_rect(Rect2(-6, -24, 12, 24), Color("5b635e"))
			draw_rect(Rect2(2, -24, 4, 24), Color("3e4541"))
			draw_colored_polygon(PackedVector2Array([Vector2(-6, -24), Vector2(1, -29), Vector2(6, -24)]), Color("6e7872"))
			draw_rect(Rect2(-6, -15, 5, 5), Color("3c6e44"))
		5: # CampfireTent
			draw_colored_polygon(PackedVector2Array([Vector2(-15, 2), Vector2(0, -18), Vector2(16, 2)]), Color("6b563c"))
			draw_colored_polygon(PackedVector2Array([Vector2(-6, 2), Vector2(0, -10), Vector2(6, 2)]), Color("29231d"))
			draw_line(Vector2(-14, 2), Vector2(0, -18), Color("8a704e"), 1.5)
		6: # MirrorStand
			draw_rect(Rect2(-7, -14, 14, 14), Color("555e58"))
			draw_circle(Vector2(0, -20), 6.0, Color("3c6375"))
			draw_circle(Vector2(0, -20), 6.0, Color("d9b366"), false, 1.5)
			draw_line(Vector2(-3, -22), Vector2(3, -18), Color("b8f6fc"), 1.5)
		7: # MushroomCluster
			for offset in [Vector2(-5, 0), Vector2(3, 2), Vector2(0, -3)]:
				draw_rect(Rect2(offset.x - 1, offset.y - 3, 2, 4), Color("dfd4bc"))
				var cap := Color("4ec4d4") if offset.y < 0 else Color("cc5a3b")
				draw_rect(Rect2(offset.x - 3, offset.y - 6, 6, 3), cap)
				draw_rect(Rect2(offset.x - 1, offset.y - 5, 1, 1), Color("fff6e0"))
		8: # WildflowerPatch
			draw_rect(Rect2(-5, -2, 10, 4), Color("285231"))
			draw_rect(Rect2(-4, -3, 2, 2), Color("f2cb57"))
			draw_rect(Rect2(2, -1, 2, 2), Color("67d4e6"))
			draw_rect(Rect2(0, -4, 2, 2), Color("f28b57"))

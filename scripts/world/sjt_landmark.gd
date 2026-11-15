extends StaticBody2D
@export_enum("Basin", "Monument") var kind: int = 0

func _ready() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(64,22) if kind == 0 else Vector2(16,10)
	collision.shape = shape
	collision.position.y = -5
	add_child(collision)

func _draw() -> void:
	if kind == 0:
		# Original curved silhouette inspired by the photographed shallow feature.
		var rim := PackedVector2Array([Vector2(-34,-4),Vector2(-28,-12),Vector2(-12,-16),Vector2(2,-10),Vector2(16,-12),Vector2(32,-5),Vector2(34,1),Vector2(21,5),Vector2(4,0),Vector2(-10,5),Vector2(-27,3)])
		draw_colored_polygon(rim,Color("c0bda2"))
		var water := rim.duplicate()
		for i in range(water.size()):
			water[i] = (water[i] * Vector2(0.85,0.65)).round() + Vector2(0,-2)
		draw_colored_polygon(water,Color("4b7b80"))
		draw_line(Vector2(-23,-6),Vector2(-10,-9),Color("91b2ab"),1)
		draw_line(Vector2(15,-5),Vector2(24,-2),Color("91b2ab"),1)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(-11,-4),Vector2(0,-10),Vector2(12,-4),Vector2(0,2)]),Color("a39f82"))
		# Abstract twin upward plates: inscription and exact sculpture are unresolved.
		draw_colored_polygon(PackedVector2Array([Vector2(-6,-5),Vector2(-3,-32),Vector2(4,-29),Vector2(1,-4)]),Color("b5a578"))
		draw_colored_polygon(PackedVector2Array([Vector2(1,-4),Vector2(7,-28),Vector2(11,-24),Vector2(7,-2)]),Color("d0ba86"))

extends StaticBody2D
## Ground footprint ends at local y=0; artwork rises above that sorting anchor.
@export_enum("Tree", "Building") var kind: int = 0
@export var building_label: String = "SCIENCE ANNEX"

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	var shape := CollisionPolygon2D.new()
	if kind == 1:
		shape.polygon = PackedVector2Array([Vector2(0,0),Vector2(-80,-40),Vector2(0,-80),Vector2(80,-40)])
	else:
		shape.polygon = PackedVector2Array([Vector2(-8,-4),Vector2(0,-9),Vector2(8,-4),Vector2(0,1)])
	add_child(shape)
	queue_redraw()

func _draw() -> void:
	if kind == 0:
		draw_rect(Rect2(-4,-32,8,31),Color("655344"))
		draw_rect(Rect2(1,-32,3,30),Color("433e39"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,-70),Vector2(-24,-43),Vector2(-19,-22),Vector2(0,-14),Vector2(23,-28),Vector2(22,-48)]),Color("254d4b"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,-70),Vector2(-24,-43),Vector2(-9,-32),Vector2(11,-47)]),Color("3d6b57"))
		draw_line(Vector2(-17,-44),Vector2(-3,-58),Color("63836a"),2)
		# Overlapping stepped leaf clusters, lit from upper left.
		for leaf: Vector3 in [Vector3(-15,-43,13),Vector3(5,-51,16),Vector3(16,-35,12),Vector3(-6,-29,14),Vector3(-8,-60,11)]:
			var p := Vector2(leaf.x,leaf.y)
			var r: float = leaf.z
			var outline := PackedVector2Array([p+Vector2(-r,-4),p+Vector2(-r+4,-r+3),p+Vector2(0,-r),p+Vector2(r-3,-r+4),p+Vector2(r,5),p+Vector2(5,r-2),p+Vector2(-r+3,r-4)])
			draw_colored_polygon(outline,Color("3a6252") if leaf.x < 6 else Color("2c5049"))
			draw_line(p+Vector2(-r+5,-6),p+Vector2(-3,-r+5),Color("628367"),2)
			draw_rect(Rect2(p+Vector2(1,-5),Vector2(3,2)),Color("50745a"))
		draw_line(Vector2(-1,-22),Vector2(-1,-3),Color("947253"),2)
	else:
		var roof := PackedVector2Array([Vector2(0,-144),Vector2(80,-104),Vector2(0,-64),Vector2(-80,-104)])
		draw_colored_polygon(PackedVector2Array([Vector2(-80,-104),Vector2(0,-64),Vector2(0,0),Vector2(-80,-40)]),Color("7b7e88"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,-64),Vector2(80,-104),Vector2(80,-40),Vector2(0,0)]),Color("515e74"))
		draw_colored_polygon(roof,Color("acada6"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,-135),Vector2(62,-104),Vector2(0,-73),Vector2(-62,-104)]),Color("8b9897"))
		draw_polyline(PackedVector2Array([Vector2(-80,-99),Vector2(0,-59),Vector2(80,-99)]),Color("384c61"),2)
		draw_polyline(PackedVector2Array([Vector2(-80,-43),Vector2(0,-3),Vector2(80,-43)]),Color("a4a79c"),3)
		draw_polyline(PackedVector2Array([Vector2(-80,-104),Vector2(0,-64),Vector2(80,-104)]),Color("d4cbb2"),3)
		for i in range(3):
			var x: float = 13.0 + i * 22.0
			var y: float = -57.0 - x * 0.5
			draw_colored_polygon(PackedVector2Array([Vector2(x,y),Vector2(x+13,y-6.5),Vector2(x+13,y+13.5),Vector2(x,y+20)]),Color("b9c9ab") if i == 1 else Color("293e54"))
			draw_line(Vector2(x+6,y-3),Vector2(x+6,y+17),Color("445767"),2)
			draw_line(Vector2(x,y+10),Vector2(x+13,y+3.5),Color("445767"),2)
			draw_line(Vector2(x,y+21),Vector2(x+14,y+14),Color("b9b9ab"),2)
		# Door frame, glass, handle and a shallow step on the left facade.
		draw_colored_polygon(PackedVector2Array([Vector2(-55,-27),Vector2(-29,-14),Vector2(-29,-49),Vector2(-55,-62)]),Color("c7bea7"))
		draw_colored_polygon(PackedVector2Array([Vector2(-51,-26),Vector2(-32,-16),Vector2(-32,-46),Vector2(-51,-56)]),Color("24364b"))
		draw_line(Vector2(-42,-51),Vector2(-42,-22),Color("677a80"),2)
		draw_rect(Rect2(-38,-32,2,4),Color("e3bd78"))
		draw_colored_polygon(PackedVector2Array([Vector2(-58,-26),Vector2(-30,-12),Vector2(-37,-8),Vector2(-65,-22)]),Color("9ba59f"))
		draw_rect(Rect2(-5,-107,22,9),Color("697d80"))
		draw_rect(Rect2(-5,-110,22,3),Color("c3c7b6"))

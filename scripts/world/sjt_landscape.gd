extends Node2D
const FONT = preload("res://assets/fonts/after_hours.tres")

func _draw() -> void:
	# Compressed roads and red pedestrian surfaces inspired by the front views.
	var approach := PackedVector2Array([Vector2(-290,230),Vector2(-155,160),Vector2(-75,105),Vector2(-10,25),Vector2(25,0),Vector2(75,28),Vector2(170,85),Vector2(320,150)])
	draw_polyline(approach,Color("b7b49a"),60)
	draw_polyline(approach,Color("765e53"),56)
	draw_polyline(approach,Color("4f6067"),36)
	# Decorative seating loop and paved pockets; not a claimed surveyed layout.
	var loop := PackedVector2Array([Vector2(-155,160),Vector2(-80,198),Vector2(25,221),Vector2(145,165),Vector2(225,125),Vector2(145,85),Vector2(170,85)])
	draw_polyline(loop,Color("b5b399"),22)
	draw_polyline(loop,Color("927667"),18)
	for p: Vector2 in [Vector2(-80,155),Vector2(205,180),Vector2(-235,55)]:
		poly([p+Vector2(-36,-12),p+Vector2(-12,-24),p+Vector2(36,0),p+Vector2(12,12)],Color("858a82"))
	for i in range(7):
		var p := Vector2(100+i*5,39+i*3)
		draw_line(p,p+Vector2(-13,7),Color("aab3a6"),2)
	# Entrance apron aligned with the facade; no speculative stairs or ramps.
	poly([Vector2(-40,4),Vector2(40,-36),Vector2(96,-8),Vector2(16,32)],Color("866454"))
	poly([Vector2(-55,25),Vector2(25,-15),Vector2(90,18),Vector2(10,58)],Color("94745f"))
	# SJT Ground lies below SJT in the supplied map; reserve open space here.
	poly([Vector2(-100,230),Vector2(45,160),Vector2(210,242),Vector2(60,317)],Color("3f5d46"))
	draw_string(FONT,Vector2(-10,270),"SJT GROUND",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("acb89b"))
	draw_string(FONT,Vector2(-218,208),"TO VIT LAKE",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("c7cbb5"))
	draw_string(FONT,Vector2(230,130),"TO PRP",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("c7cbb5"))
	# Cast shadow derives from the actual footprint and one consistent light direction.
	var projected := PackedVector2Array()
	for point: Vector2 in preload("res://scripts/world/sjt_building.gd").FOOTPRINT:
		projected.append(point+Vector2(0,40))
		projected.append(point+Vector2(45,68))
	draw_colored_polygon(Geometry2D.convex_hull(projected),Color(0.02,0.05,0.08,0.24))
	poly([Vector2(8,28),Vector2(88,-12),Vector2(101,-4),Vector2(21,36)],Color(0.02,0.05,0.08,0.22))
	for actor: Node2D in get_parent().get_node("Actors").get_children():
		if actor.has_method("ground_shadow"):
			var points: PackedVector2Array = actor.ground_shadow()
			for i in range(points.size()): points[i] += actor.position
			draw_colored_polygon(points,Color(0.02,0.05,0.08,0.23))
			if actor.kind == 1:
				var pool := PackedVector2Array()
				for i in range(12):
					pool.append(actor.position+Vector2(12,1)+(Vector2(cos(i*TAU/12)*28,sin(i*TAU/12)*14)).round())
				draw_colored_polygon(pool,Color(0.96,0.81,0.43,0.10))
		elif actor.get_script() == preload("res://scripts/world/prop.gd"):
			var point: Vector2 = actor.position
			poly([point+Vector2(-15,-3),point+Vector2(0,-10),point+Vector2(32,5),point+Vector2(16,12)],Color(0.02,0.05,0.08,0.25))
	# Low shrubs and pale flower accents around the compressed front lawn.
	for point: Vector2 in [Vector2(-75,70),Vector2(-90,85),Vector2(-110,100),Vector2(110,135),Vector2(130,145),Vector2(145,155)]:
		draw_rect(Rect2(point,Vector2(18,6)),Color("2b4c42"))
		draw_rect(Rect2(point+Vector2(2,-4),Vector2(14,7)),Color("547354"))
		draw_rect(Rect2(point+Vector2(4,-4),Vector2(2,2)),Color("c4c4a3"))
	var edge := PackedVector2Array([Vector2(0,-320),Vector2(672,16),Vector2(0,352),Vector2(-672,16),Vector2(0,-320)])
	draw_polyline(edge,Color("83938a"),3)

func poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points),color)



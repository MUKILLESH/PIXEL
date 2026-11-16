extends Node2D
const FONT = preload("res://assets/fonts/after_hours.tres")
func _draw() -> void:
	# Cobblestone medieval roads & Village Square leading up to Bellhaven Belfry
	var approach := PackedVector2Array([Vector2(-290,230),Vector2(-155,160),Vector2(-75,105),Vector2(-10,25),Vector2(25,0),Vector2(75,28),Vector2(170,85),Vector2(320,150)])
	draw_polyline(approach,Color("433e39"),60)
	draw_polyline(approach,Color("5e554c"),56)
	draw_polyline(approach,Color("4f4841"),36)
	# Village Square cobblestone loop
	var loop := PackedVector2Array([Vector2(-155,160),Vector2(-80,198),Vector2(25,221),Vector2(145,165),Vector2(225,125),Vector2(145,85),Vector2(170,85)])
	draw_polyline(loop,Color("433e39"),22)
	draw_polyline(loop,Color("695f55"),18)
	for p: Vector2 in [Vector2(-80,155),Vector2(205,180),Vector2(-235,55)]:
		poly([p+Vector2(-36,-12),p+Vector2(-12,-24),p+Vector2(36,0),p+Vector2(12,12)],Color("57514b"))
	# Stone cobble stepping stones by the eastern lane
	for i in range(7):
		var p := Vector2(100+i*5,39+i*3)
		draw_line(p,p+Vector2(-13,7),Color("786f65"),2)
	# Belfry & Blacksmith stone forecourt aprons
	poly([Vector2(-40,4),Vector2(40,-36),Vector2(96,-8),Vector2(16,32)],Color("5e544b"))
	poly([Vector2(-55,25),Vector2(25,-15),Vector2(90,18),Vector2(10,58)],Color("695e54"))
	paint_ground_details()
	# Warm forge ember spill onto cobbles near Blacksmith bays
	poly([Vector2(48,-52),Vector2(88,-72),Vector2(114,-56),Vector2(74,-36)],Color(0.95,0.48,0.16,0.16))
	# Environmental storytelling: Blacksmith anvil/tools outside east workshop & market goods by square
	draw_rect(Rect2(138, 12, 10, 7), Color("4f3622"))
	draw_rect(Rect2(140, 8, 7, 5), Color("586275")) # Anvil
	draw_rect(Rect2(152, 16, 7, 6), Color("36495c")) # Quench water tub
	draw_rect(Rect2(153, 17, 5, 3), Color("599bb8"))
	draw_rect(Rect2(-68, 124, 11, 8), Color("6e472b")) # Market crate
	draw_rect(Rect2(-54, 127, 8, 6), Color("b89d72")) # Flour/grain sack
	# Village Square central stone-curbed cistern apron and open green plaza
	poly([Vector2(-24,149),Vector2(30,122),Vector2(84,149),Vector2(30,176)],Color("49433c"))
	draw_polyline(PackedVector2Array([Vector2(-24,149),Vector2(30,122),Vector2(84,149),Vector2(30,176),Vector2(-24,149)]),Color("696057"),2)
	draw_string(FONT,Vector2(-18,194),"VILLAGE SQUARE",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("b8b294"))
	draw_string(FONT,Vector2(-270,206),"TO BRIARWOOD",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("c7be9e"))
	draw_string(FONT,Vector2(182,126),"TO IRONWATCH",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("c7be9e"))
	# Cast shadows derived from real footprints
	var projected := PackedVector2Array()
	for point: Vector2 in preload("res://scripts/world/sjt_building.gd").FOOTPRINT:
		projected.append(point+Vector2(0,40))
		projected.append(point+Vector2(45,68))
	draw_colored_polygon(Geometry2D.convex_hull(projected),Color(0.02,0.03,0.06,0.28))
	poly([Vector2(8,28),Vector2(88,-12),Vector2(101,-4),Vector2(21,36)],Color(0.02,0.03,0.06,0.24))
	for actor: Node2D in get_parent().get_parent().get_node("Actors").get_children():
		if actor.has_method("ground_shadow"):
			var points: PackedVector2Array = actor.ground_shadow()
			for i in range(points.size()): points[i] += actor.position
			draw_colored_polygon(points,Color(0.02,0.03,0.06,0.25))
			if actor.kind == 1:
				var pool := PackedVector2Array()
				for i in range(12):
					pool.append(actor.position+Vector2(12,1)+(Vector2(cos(i*TAU/12)*32,sin(i*TAU/12)*16)).round())
				draw_colored_polygon(pool,Color(0.98,0.75,0.34,0.14))
		elif actor.get_script() == preload("res://scripts/world/prop.gd"):
			var point: Vector2 = actor.position
			poly([point+Vector2(-15,-3),point+Vector2(0,-10),point+Vector2(32,5),point+Vector2(16,12)],Color(0.02,0.03,0.06,0.28))
	# Wild village meadow shrubs and gentle swaying night-bloom flowers
	var sway_x: int = 0
	for point: Vector2 in [Vector2(-75,70),Vector2(-90,85),Vector2(-110,100),Vector2(110,135),Vector2(130,145),Vector2(145,155)]:
		draw_rect(Rect2(point,Vector2(18,6)),Color("1f382d"))
		draw_rect(Rect2(point+Vector2(2 + sway_x,-4),Vector2(14,7)),Color("375740"))
		draw_rect(Rect2(point+Vector2(4 + sway_x,-4),Vector2(2,2)),Color("e0ba67"))
	var edge := PackedVector2Array([Vector2(0,-320),Vector2(672,16),Vector2(0,352),Vector2(-672,16),Vector2(0,-320)])
	draw_polyline(edge,Color("5c564e"),3)

func poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points),color)

func paint_ground_details() -> void:
	var road := PackedVector2Array([Vector2(-290,230),Vector2(-155,160),Vector2(-75,105),Vector2(-10,25),Vector2(25,0),Vector2(75,28),Vector2(170,85),Vector2(320,150)])
	var walk := PackedVector2Array([Vector2(-155,160),Vector2(-80,198),Vector2(25,221),Vector2(145,165),Vector2(225,125),Vector2(145,85),Vector2(170,85)])
	var colors: Array[Color] = [Color("746b59"),Color("82745e"),Color("655e50"),Color("8d7d64"),Color("6d6859")]
	for y in range(-70,252,6):
		for x in range(-310,341,10):
			var p := Vector2(x+posmod(y/6,2)*5,y)
			var d: float = path_distance(p,road)
			var dw: float = path_distance(p,walk)
			if d < 23 or dw < 7:
				var index: int = posmod(x*13+y*7,5)
				poly([p+Vector2(-4,0),p+Vector2(-2,-2),p+Vector2(3,-2),p+Vector2(5,0),p+Vector2(2,2),p+Vector2(-3,2)],colors[index])
				draw_line(p+Vector2(-2,-2),p+Vector2(3,-2),colors[index].lightened(0.12),1)
				if posmod(x+y,61)==0: draw_line(p,p+Vector2(2,2),Color("45473b"),1)
			elif d < 34 and posmod(x+y,4)==0:
				draw_rect(Rect2(p,Vector2(4,2)),Color("52503d"))
	# Small coherent meadow/soil patches instead of pixel noise everywhere.
	for i in range(180):
		var p := Vector2(posmod(i*113,760)-380,posmod(i*73,440)-170)
		if path_distance(p,road) < 40 or path_distance(p,walk) < 20: continue
		var color := Color("42553b") if i%3 else Color("4a5037")
		draw_rect(Rect2(p,Vector2(12,3)),color)
		draw_rect(Rect2(p+Vector2(3,-2),Vector2(6,7)),color)
		for j in range(3):
			var q := p+Vector2(j*4,0)
			draw_line(q,q+Vector2(-2,-3),Color("6a7850"),1)
		if i%9==0:
			draw_rect(Rect2(p+Vector2(3,-3),Vector2(2,2)),Color("b4a371"))
	# Cistern coping blocks and moss framing, kept off the interaction center.
	var ring := PackedVector2Array([Vector2(-24,149),Vector2(30,122),Vector2(84,149),Vector2(30,176),Vector2(-24,149)])
	for edge in range(4):
		for step in range(7):
			var a: Vector2 = ring[edge].lerp(ring[edge+1],step/7.0).round()
			var b: Vector2 = ring[edge].lerp(ring[edge+1],(step+0.8)/7.0).round()
			draw_line(a,b,Color("968b72"),3)

func path_distance(p: Vector2, points: PackedVector2Array) -> float:
	var distance: float = INF
	for i in range(points.size()-1):
		distance = minf(distance,p.distance_to(Geometry2D.get_closest_point_to_segment(p,points[i],points[i+1])))
	return distance

extends Node2D
const Art = preload("res://scripts/world/dawnspire_art.gd")
var _anim_phase: float = 1.0
func _draw() -> void:
	_backdrop()
	# 1. Outer Storm-Cloud Horizon & Alpine Basalt Precipice (-640..640 x -420..420)
	pass
	pass
	# Drifting storm cloud shelves at mountain edges
	var cloud_shift: float = sin(_anim_phase) * 14.0
	for ci in range(-3, 4):
		var cy: float = float(ci) * 86.0
		draw_rect(Rect2(-560 + cloud_shift + float((ci % 2) * 32), cy, 170, 22), Color(0.18, 0.25, 0.36, 0.36))
		draw_rect(Rect2(360 - cloud_shift - float((ci % 2) * 28), cy - 18.0, 180, 24), Color(0.18, 0.25, 0.36, 0.36))

	# Distant Dawnspire peak silhouette glowing faintly on northern skyline
	draw_colored_polygon(PackedVector2Array([
		Vector2(-110, -250), Vector2(0, -345), Vector2(120, -250)
	]), Color("1b2438"))
	draw_line(Vector2(0, -345), Vector2(0, -305), Color(0.85, 0.72, 0.45, 0.35), 2.0)

	# 2. Split Mountain Plateaus separated by the Ravine (y = -46..-4) & Summit Cliff (y = -158..-140)
	# South Foothills + Whispering Cliffs + South Skybridge Rim (y: -8..248)
	draw_rect(Rect2(-328, -8, 656, 256), Color("242b3b"))
	draw_rect(Rect2(-320, -4, 640, 244), Color("2a3245"))
	# Snow frost patches along foothills & cliff ledges
	for fx in range(-300, 300, 64):
		draw_rect(Rect2(fx, 198 + ((fx * 3) % 24), 46, 16), Color(0.76, 0.84, 0.92, 0.16))
		draw_rect(Rect2(fx + 20, 84 + ((fx * 5) % 22), 38, 12), Color(0.76, 0.84, 0.92, 0.14))

	# Deep Chasm / Ravine (y = -46..-6) slicing mountain West-to-East
	draw_rect(Rect2(-340, -48, 680, 44), Color("0b0f18"))
	draw_rect(Rect2(-330, -40, 660, 28), Color("0f1522"))
	# Swirling abyssal ravine mist inside the chasm
	for mx in range(-300, 310, 88):
		var m_off: float = sin(_anim_phase + float(mx) * 0.03) * 14.0
		draw_rect(Rect2(mx + m_off, -34, 62, 10), Color(0.55, 0.72, 0.88, 0.12))

	# North Ridge (Pilgrim's Refuge NW & Celestial Observatory NE, y = -150..-48)
	draw_rect(Rect2(-324, -150, 648, 104), Color("272f42"))
	draw_rect(Rect2(-312, -142, 624, 90), Color("2e384d"))
	# Upper Sanctuary Cliff Wall separating Observatory ridge from Summit Plateau
	draw_rect(Rect2(-324, -158, 320, 14), Color("1c2230"))
	draw_rect(Rect2(52, -158, 272, 14), Color("1c2230"))

	# Upper Summit Plateau (Dawnspire Sanctuary & Great Bell Gate, y = -250..-152)
	draw_rect(Rect2(-132, -250, 298, 98), Color("2b344a"))
	draw_rect(Rect2(-124, -242, 282, 84), Color("343f59"))

	_terrain_detail()
	# 3. Ancient Mountain Flagstone Paths
	var road_edge := Color("434d63")
	var road_core := Color("333b4f")
	# Foothills road -> Whispering Cliffs switchback -> South Skybridge Plaza
	var south_route := PackedVector2Array([
		Vector2(-252, 222), Vector2(-190, 212), Vector2(-148, 198), Vector2(-84, 198),
		Vector2(30, 184), Vector2(180, 174), Vector2(210, 118), Vector2(210, 74),
		Vector2(144, 66), Vector2(40, 38), Vector2(0, 20)
	])
	draw_polyline(south_route, road_edge, 28.0)
	draw_polyline(south_route, road_core, 20.0)
	# Southern anchor spurs west toward winch components & optional overlooks
	draw_polyline(PackedVector2Array([Vector2(0, 24), Vector2(-100, 48), Vector2(-196, 36)]), road_core, 16.0)
	draw_polyline(PackedVector2Array([Vector2(-190, 212), Vector2(-264, 148)]), road_core, 14.0)
	draw_polyline(PackedVector2Array([Vector2(-44, 208), Vector2(-18, 218)]), road_core, 12.0)

	# North Ridge paths: Bridge landing -> Refuge West & Observatory East & Stairway North
	draw_polyline(PackedVector2Array([Vector2(-268, -82), Vector2(-214, -78), Vector2(-130, -78), Vector2(0, -68), Vector2(188, -78), Vector2(240, -76)]), road_edge, 24.0)
	draw_polyline(PackedVector2Array([Vector2(-268, -82), Vector2(-214, -78), Vector2(-130, -78), Vector2(0, -68), Vector2(188, -78), Vector2(240, -76)]), road_core, 18.0)
	draw_polyline(PackedVector2Array([Vector2(24, -74), Vector2(24, -184)]), road_core, 22.0)
	draw_polyline(PackedVector2Array([Vector2(-32, -184), Vector2(24, -184), Vector2(96, -184)]), road_core, 20.0)

	_sanctuary_floors()
	_finishing_clusters()

func _backdrop() -> void:
	draw_rect(Rect2(-1024,-640,2048,1280),Color("202c45"))
	# Receding ridges use clustered silhouettes, not noise or gradients.
	for layer in range(3):
		var pts: Array = [Vector2(-900,490)]
		for i in range(19):
			var x: float = -900+i*100
			var y: float = -370+layer*105+sin(i*2.7+layer)*64
			pts.append(Vector2(x,y+100))
			pts.append(Vector2(x+35,y))
			pts.append(Vector2(x+63,y+48))
		pts.append(Vector2(1000,490))
		Art.poly(self,pts,["354960","2b3b53","233149"][layer])
	# Thin distant snow caps and evergreen foothills.
	for i in range(12):
		var x: float = -650+i*118
		Art.poly(self,[Vector2(x,-310),Vector2(x+20,-341),Vector2(x+44,-301),Vector2(x+21,-318)],"536b80")

func _terrain_detail() -> void:
	# Facets extend OUTSIDE the unchanged playable rectangles.
	for side in [-1,1]:
		for y in range(-240,249,33):
			var x: float = side*328
			var d: float = 24+posmod(y,19)
			Art.poly(self,[Vector2(x,y),Vector2(x+side*d,y+17),Vector2(x+side*(d+8),y+100),Vector2(x,y+70)],"34394f")
			draw_line(Vector2(x,y),Vector2(x+side*d,y+17),Color("758297"),2)
			for k in range(3):
				draw_line(Vector2(x+side*(6+k*8),y+18),Vector2(x+side*(8+k*8),y+67),Color("222b40"))
	for x in range(-320,321,32):
		Art.poly(self,[Vector2(x,240),Vector2(x+32,240),Vector2(x+39,325+posmod(x,37)),Vector2(x+7,347+posmod(x,27))],"384156")
		draw_line(Vector2(x,246),Vector2(x+32,246),Color("8792a3"),2)
		for y in range(256,330,16):
			draw_line(Vector2(x+5,y),Vector2(x+29,y+6),Color("242e42"))
	# The fall-reset edge is visibly cut at its ACTUAL x=280 / y=210 thresholds.
	Art.poly(self,[Vector2(280,74),Vector2(328,96),Vector2(328,240),Vector2(115,240),Vector2(115,210),Vector2(280,210)],"252d42")
	draw_polyline(PackedVector2Array([Vector2(280,74),Vector2(280,210),Vector2(115,210)]),Color("a1aeb9"),2)
	for y in range(90,210,17):
		draw_line(Vector2(282,y),Vector2(324,y+20),Color("46526b"))
	# Low-contrast rock strata, alpine tufts and frost clusters away from the wind lane.
	for y in range(14,232,20):
		for x in range(-310,100,26):
			var px: float = x+posmod(y,13)
			draw_line(Vector2(px,y),Vector2(px+13,y+2),Color("394457"))
			draw_line(Vector2(px+2,y+3),Vector2(px+17,y+4),Color("242c40"))
			if posmod(x+y,5)==0:
				draw_line(Vector2(px,y),Vector2(px-2,y-4),Color("536b65"))
				draw_line(Vector2(px+2,y),Vector2(px+3,y-5),Color("617b70"))
	# Exposed rock layers within the existing nonwalkable ravine.
	for x in range(-320,320,22):
		if abs(x)<35: continue
		Art.poly(self,[Vector2(x,-47),Vector2(x+20,-47),Vector2(x+14,-19),Vector2(x+3,-25)],"42485e")
		draw_line(Vector2(x+1,-46),Vector2(x+18,-46),Color("909cac"))
		draw_line(Vector2(x+7,-41),Vector2(x+8,-25),Color("282e42"))
	for x in range(-318,315,20):
		if x>=-4 and x<=52: continue
		draw_rect(Rect2(x,-157,19,14),Color("4a5368"))
		draw_line(Vector2(x,-157),Vector2(x+18,-157),Color("8e9baa"))

func _sanctuary_floors() -> void:
	# Road joints are quiet at native scale; stair opening stays exactly x=-4..52.
	for y in range(-145,-75,7):
		draw_line(Vector2(14,y),Vector2(34,y),Color("94a0af"))
		draw_line(Vector2(14,y+2),Vector2(34,y+2),Color("252f43"))
	for p: Vector2 in [Vector2(204,-98),Vector2(-32,-196)]:
		Art.platform(self,p,46)
		for r in [16,26,38]:
			Art.ring(self,p,r,r*0.5,"a58b61")
		for i in range(12):
			var a: float = i*TAU/12
			var v := Vector2(cos(a)*40,sin(a)*20)
			draw_line((p+v).round(),(p+v*0.87).round(),Color("d8c591"))
	# Chapel threshold carpet and memorial stones, below actors and journal.
	Art.diamond(self,Vector2(-214,-84),50,"675452")
	for x in [-268,-160]:
		draw_rect(Rect2(x,-99,9,15),Color("67717d"))
		for y in range(-96,-86,3): draw_line(Vector2(x+2,y),Vector2(x+7,y),Color("b6b6a5"))

func _finishing_clusters() -> void:
	# Frosted granite tongues and clustered alpine vegetation frame existing routes.
	for p: Vector2 in [Vector2(-308,68),Vector2(-252,102),Vector2(-138,116),Vector2(-44,122),Vector2(20,92),Vector2(-300,228),Vector2(303,46)]:
		Art.poly(self,[p+Vector2(-22,2),p+Vector2(-12,-12),p+Vector2(10,-15),p+Vector2(25,0),p+Vector2(6,10)],"3c495d")
		Art.poly(self,[p+Vector2(-22,2),p+Vector2(-12,-12),p+Vector2(10,-15),p+Vector2(2,-5)],"71808e")
		draw_line(p+Vector2(2,-5),p+Vector2(6,10),Color("222b3d"))
		for j in range(5):
			var g := p+Vector2(-18+j*7,12+posmod(j,3))
			draw_line(g,g+Vector2(-3,-5),Color("58796b"))
			draw_line(g+Vector2(1,0),g+Vector2(2,-7),Color("748b78"))
	# Broken road joints follow the actual path rather than suggesting a new route.
	var road := [Vector2(-252,222),Vector2(-190,212),Vector2(-148,198),Vector2(-84,198),Vector2(30,184),Vector2(180,174),Vector2(210,118),Vector2(210,74),Vector2(144,66),Vector2(40,38),Vector2(0,20)]
	for i in range(road.size()-1):
		var a: Vector2 = road[i]
		var b: Vector2 = road[i+1]
		var normal := (b-a).normalized().orthogonal()*7
		for j in range(0,int(a.distance_to(b)),12):
			var p: Vector2 = a.move_toward(b,j).round()
			draw_line((p-normal).round(),(p+normal).round(),Color("596579"))
			draw_line(p+Vector2(1,1),(p+normal+Vector2(1,1)).round(),Color("252f42"))
	# Distant trees stand outside physical boundaries and remain behind gameplay.
	for side in [-1,1]:
		for i in range(9):
			Art.pine(self,Vector2(side*(362+posmod(i*13,32)),-75+i*38),43+posmod(i*7,14))
	# Sculpt the visible lower escarpment into overlapping angular granite strata.
	for i in range(15):
		var x: float = -316+i*43
		var y: float = 272+posmod(i*11,23)
		Art.poly(self,[Vector2(x,y),Vector2(x+26,y-13),Vector2(x+39,y+11),Vector2(x+25,y+63),Vector2(x+12,y+46)],"40495e")
		draw_polyline(PackedVector2Array([Vector2(x,y),Vector2(x+26,y-13),Vector2(x+39,y+11)]),Color("65748a"),1)
		draw_line(Vector2(x+23,y+4),Vector2(x+16,y+43),Color("293249"))
	# Strata below the exact southern fall edge emphasize a sheer drop, not walkable paving.
	for x in range(118,278,19):
		Art.poly(self,[Vector2(x,212),Vector2(x+17,212),Vector2(x+11,238),Vector2(x+2,230)],"424c63")
		draw_line(Vector2(x+4,215),Vector2(x+6,229),Color("252d43"))
	for x in range(-290,286,37):
		if abs(x)<35: continue
		draw_line(Vector2(x,-48),Vector2(x+19,-48),Color("d0d4cc"),1)

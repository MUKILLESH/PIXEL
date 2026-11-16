extends Node2D
## Offline-only source for the Floodmill static ground cache.
const Art = preload("res://scripts/world/floodmill_art.gd")
func _draw() -> void:
	# Shallow flooded gardens and dark silt below the readable stone lanes.
	for p: Vector2 in [Vector2(-147,24),Vector2(83,170),Vector2(155,125),Vector2(-123,140),Vector2(115,-115),Vector2(-249,-120)]:
		Art.poly(self,[p+Vector2(-43,0),p+Vector2(-31,-14),p+Vector2(2,-21),p+Vector2(40,-6),p+Vector2(47,6),p+Vector2(16,17),p+Vector2(-23,14)],"2d4140")
		Art.poly(self,[p+Vector2(-38,0),p+Vector2(-18,-12),p+Vector2(4,-16),p+Vector2(36,-5),p+Vector2(30,8),p+Vector2(7,12),p+Vector2(-22,9)],"2c5054")
		for i in range(7):
			var q := p+Vector2(-27+i*9,posmod(i*7,13)-5)
			draw_rect(Rect2(q,Vector2(8,1)),Color("527774"))
	_draw_base()
	_draw_details()
func _draw_base() -> void:
	var stone_wet := Color("3b474a")
	var cobble := Color("4f5856")
	var cobble_light := Color("626b67")
	var plank := Color("63442a")
	var canal_bank := Color("2e3536")
	var deep_water := Color("163e4f")
	var mid_water := Color("215a70")
	var puddle := Color(0.14, 0.38, 0.48, 0.62)

	# 1. Entrance road -> Abandoned Village Square -> East Watermill -> South Bank Promenade
	draw_polyline(PackedVector2Array([Vector2(-216, 212), Vector2(-148, 192), Vector2(-84, 140), Vector2(-56, 92)]), stone_wet, 28.0)
	draw_polyline(PackedVector2Array([Vector2(-216, 212), Vector2(-148, 192), Vector2(-84, 140), Vector2(-56, 92)]), cobble, 20.0)

	# Floodmill Town Square mossy flagstones
	draw_rect(Rect2(-98, 56, 108, 72), Color("364244"))
	draw_rect(Rect2(-92, 62, 96, 60), cobble)
	for cx in range(-86, 0, 18):
		for cy in range(66, 118, 14):
			draw_rect(Rect2(cx, cy, 14, 10), cobble_light)
	# Square corner puddles with shimmering reflections
	draw_colored_polygon(PackedVector2Array([Vector2(-86, 104), Vector2(-54, 100), Vector2(-46, 114), Vector2(-78, 118)]), puddle)
	draw_colored_polygon(PackedVector2Array([Vector2(-22, 66), Vector2(4, 62), Vector2(8, 76), Vector2(-18, 80)]), puddle)

	# Path East to Ruined Homestead Locket & Old Watermill courtyard
	draw_polyline(PackedVector2Array([Vector2(-46, 106), Vector2(22, 120), Vector2(60, 122)]), cobble, 14.0)
	draw_polyline(PackedVector2Array([Vector2(0, 86), Vector2(86, 72), Vector2(156, 62)]), stone_wet, 24.0)
	draw_polyline(PackedVector2Array([Vector2(0, 86), Vector2(86, 72), Vector2(156, 62)]), cobble, 18.0)
	draw_circle(Vector2(156, 68), 40.0, Color("3c4746"))
	draw_circle(Vector2(156, 68), 32.0, cobble)

	# South Millpond & Eastern Mill Tailrace
	draw_rect(Rect2(208, -28, 72, 152), canal_bank)
	draw_rect(Rect2(214, -22, 60, 140), deep_water)
	draw_rect(Rect2(220, -18, 48, 130), mid_water)
	# Path North-West to Canal Sluice Promenade
	draw_polyline(PackedVector2Array([Vector2(-56, 72), Vector2(-36, 18), Vector2(36, 8)]), stone_wet, 22.0)
	draw_polyline(PackedVector2Array([Vector2(-56, 72), Vector2(-36, 18), Vector2(36, 8)]), cobble, 16.0)
	draw_polyline(PackedVector2Array([Vector2(-84, 14), Vector2(-64, 4), Vector2(48, 4), Vector2(108, 24)]), cobble, 18.0)

	# 2. East-West Sluice Canal at y = -32 (x in [-900..900], y in [-46..-18])
	draw_rect(Rect2(-900, -50, 1800, 38), canal_bank)
	draw_rect(Rect2(-900, -45, 1800, 28), deep_water)
	draw_rect(Rect2(-900, -41, 1800, 20), mid_water)
	# 4. North Courtyard -> Cutaway Forgotten Archive Hall & Second Beacon Sanctuary
	draw_polyline(PackedVector2Array([Vector2(-64, -56), Vector2(-88, -82), Vector2(-104, -84)]), cobble, 18.0)

	# Isometric Cutaway Forgotten Archive Oak Plank Floor centered around (-134, -76) front tip
	var a_floor := PackedVector2Array([
		Vector2(-134, -76),
		Vector2(-66, -110),
		Vector2(-134, -144),
		Vector2(-202, -110),
	])
	draw_colored_polygon(a_floor, Color("291d14"))
	var a_inner := PackedVector2Array([
		Vector2(-134, -79),
		Vector2(-70, -110),
		Vector2(-134, -141),
		Vector2(-198, -110),
	])
	draw_colored_polygon(a_inner, Color("473121"))
	# Raised stone road from Archive Courtyard NE -> Second Beacon Sanctuary -> Ironwatch Gate
	draw_polyline(PackedVector2Array([Vector2(-64, -64), Vector2(-20, -96), Vector2(22, -148), Vector2(64, -206)]), stone_wet, 22.0)
	draw_polyline(PackedVector2Array([Vector2(-64, -64), Vector2(-20, -96), Vector2(22, -148), Vector2(64, -206)]), cobble, 15.0)
	draw_polyline(PackedVector2Array([Vector2(64, -206), Vector2(130, -202), Vector2(186, -196)]), cobble, 16.0)

	# Second Beacon Sanctuary Terraced Plaza (64, -208)
	draw_circle(Vector2(64, -208), 46.0, Color("313d40"))
	draw_circle(Vector2(64, -208), 38.0, Color("485457"))
	# Environmental storytelling: erased villagers' sunken cart wheel, broken crate, clay amphora, and marsh reeds
	draw_circle(Vector2(-106, 22), 7.0, Color("4a3220"))
	draw_circle(Vector2(-106, 22), 4.0, Color("215a70"))
	draw_rect(Rect2(-52, 84, 8, 6), Color("543924")) # Broken chair/stool
	draw_rect(Rect2(24, 166, 5, 7), Color("7d634d")) # Clay storage jar
	draw_rect(Rect2(32, 170, 7, 4), Color("8b969c")) # Abandoned washbasin
	# Subtle crisp area labels
	var font = preload("res://assets/fonts/after_hours.tres")
	var labels := [
		[Vector2(-248, 244), "FLOODMILL"],
		[Vector2(-154, 148), "VILLAGE SQUARE"],
		[Vector2(122, 74), "OLD WATERMILL"],
		[Vector2(48, -10), "SLUICE CANAL"],
		[Vector2(-196, -64), "FORGOTTEN ARCHIVE"],
		[Vector2(26, -160), "SECOND BEACON"],
		[Vector2(142, -218), "TO IRONWATCH KEEP"],
	]
	for item in labels:
		draw_string(font, item[0], item[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.90, 0.88, 0.74, 0.76))


func _draw_details() -> void:
	# Damp open ground, intentionally sparse enough to preserve walkable route contrast.
	var rng := RandomNumberGenerator.new()
	rng.seed = 48321
	var routes := [[Vector2(-216,212),Vector2(-148,192),Vector2(-84,140),Vector2(-56,92)],[Vector2(-46,106),Vector2(22,120),Vector2(60,122)],[Vector2(0,86),Vector2(86,72),Vector2(156,62)],[Vector2(-56,72),Vector2(-36,18),Vector2(36,8)],[Vector2(-84,14),Vector2(-64,4),Vector2(48,4),Vector2(108,24)],[Vector2(-64,-64),Vector2(-20,-96),Vector2(22,-148),Vector2(64,-206),Vector2(186,-196)]]
	# Closely fitted irregular paving, with missing stones and moss joints.
	for x in range(-240,206,9):
		for y in range(-210,218,6):
			var q := Vector2(x+(3 if y%12 else 0),y)
			var near: float = 10000
			for route: Array in routes:
				for j in range(route.size()-1):
					near = minf(near,q.distance_to(Geometry2D.get_closest_point_to_segment(q,route[j],route[j+1])))
			if (near < 7 or Rect2(-90,64,90,55).has_point(q)) and not (y > -55 and y < -10):
				if posmod(x*13+y*3,17) < 3: continue
				Art.poly(self,[q+Vector2(-4,0),q+Vector2(-1,-2),q+Vector2(4,-1),q+Vector2(4,2),q+Vector2(0,3),q+Vector2(-4,2)],"687c73" if posmod(x+y,4) else "7f8b7e")
				draw_line(q+Vector2(-3,2),q+Vector2(0,3),Color("344d49"),1)
	for i in range(1500):
		var p := Vector2(rng.randi_range(-640,640),rng.randi_range(-360,360))
		var distance: float = 10000
		for route: Array in routes:
			for j in range(route.size()-1):
				distance = minf(distance,p.distance_to(Geometry2D.get_closest_point_to_segment(p,route[j],route[j+1])))
		if p.y > -53 and p.y < -10: continue
		if Rect2(-205,-148,145,73).has_point(p) or Rect2(208,-28,72,152).has_point(p): continue
		if distance < 8 or Rect2(-96,60,100,64).has_point(p):
			Art.poly(self,[p+Vector2(-4,0),p+Vector2(0,-2),p+Vector2(5,0),p+Vector2(1,3)],"8a9381" if i%4 else "697c74")
			draw_line(p+Vector2(-3,1),p+Vector2(1,3),Color("344a48"),1)
		elif distance > 17:
			draw_rect(Rect2(p,Vector2(8,3)),Color("2c4140"))
			draw_line(p,p+Vector2(3,-3),Color("586a50"),1)
			if i%6 == 0: Art.reeds(self,p,i)
			if i%11 == 0:
				Art.poly(self,[p+Vector2(-12,0),p+Vector2(-3,-4),p+Vector2(16,-2),p+Vector2(11,4)],"2a4e53")
				draw_rect(Rect2(p+Vector2(-5,1),Vector2(8,1)),Color("55787a"))
	# Dressed wet canal walls. Never paint across the existing traversal gate.
	for x in range(-900,900,12):
		if x > -98 and x < -30: continue
		for y in [-50,-15]:
			draw_rect(Rect2(x,y,10,3),Color("78827a"))
			draw_rect(Rect2(x,y+3,10,2),Color("3c5152"))
			if posmod(x*11,13) < 3:
				draw_rect(Rect2(x+2,y,4,4),Color("526f53"))
				Art.reeds(self,Vector2(x,y-1),x)
	# Mill pond depth bands, mossy foundations and submerged fragments.
	for x in [210,266]:
		draw_rect(Rect2(x,-18,5,134),Color("345957"))
	for p: Vector2 in [Vector2(225,92),Vector2(257,65),Vector2(236,105),Vector2(-244,-29),Vector2(118,-26)]:
		draw_rect(Rect2(p,Vector2(7,3)),Color("547251"))
		draw_rect(Rect2(p+Vector2(1,1),Vector2(3,1)),Color("8b9a67"))
	# Archive diagonal wooden floorboards and contrasting inset tile threshold.
	var origin := Vector2(-134,-76)
	for u in range(2,65,6):
		for v in range(2,65,17):
			var p := origin+Vector2(u-v,-(u+v)*0.5)
			Art.poly(self,[p,p+Vector2(5,-2),p+Vector2(-10,-10),p+Vector2(-15,-7)],"655b46" if (u+v)%3 else "76684c")
			draw_line(p,p+Vector2(-15,-7),Color("363c34"),1)
	for i in range(6):
		Art.block(self,Vector2(-155+i*8,-85-i*4),5,2,2)
	# Raised sanctuary: 2:1 stone platform, worn concentric diamond courses and carved runes.
	Art.block(self,Vector2(64,-207),48,24,4)
	Art.block(self,Vector2(64,-211),40,20,3)
	for u in range(-3,4):
		for v in range(-3,4):
			var p := Vector2(64+(u-v)*5,-215+(u+v)*2.5).round()
			Art.poly(self,[p+Vector2(-4,0),p+Vector2(0,-2),p+Vector2(4,0),p+Vector2(0,2)],"7f9389" if (u+v)%3 else "586d6a")
	for i in range(8):
		var a: float = i*TAU/8
		var p := Vector2(64,-213)+Vector2(cos(a)*34,sin(a)*17).round()
		draw_line(p+Vector2(-2,1),p+Vector2(0,-3),Color("b8ba91"),1)
		draw_line(p+Vector2(0,-3),p+Vector2(3,0),Color("b8ba91"),1)
	# Purposeful remains, all on ground and non-blocking: toy boat, a torn notice, table remnants.
	var toy := Vector2(-75,126)
	Art.poly(self,[toy,toy+Vector2(9,-2),toy+Vector2(6,2),toy+Vector2(2,3)],"a18a60")
	draw_line(toy+Vector2(4,0),toy+Vector2(4,-5),Color("c8b78b"),1)
	draw_rect(Rect2(-171,101,8,4),Color("b4ae8b"))
	draw_line(Vector2(-170,102),Vector2(-166,102),Color("666a56"),1)
	for p: Vector2 in [Vector2(30,153),Vector2(81,161),Vector2(-198,77)]:
		draw_line(p,p+Vector2(14,-7),Color("70654a"),3)
		draw_line(p+Vector2(2,1),p+Vector2(13,-5),Color("a19168"),1)
	# Directional contact shadows grounded beneath the original building footprints.
	for item: Array in [[Vector2(-152,74),48,36],[Vector2(56,178),44,32],[Vector2(-216,-16),40,28],[Vector2(174,44),54,38]]:
		var p: Vector2 = item[0]
		draw_colored_polygon(PackedVector2Array([p+Vector2(-item[2],-item[2]*0.5),p+Vector2(item[1],-item[1]*0.5),p+Vector2(item[1]+21,13),p+Vector2(12,23)]),Color(0.03,0.09,0.10,0.18))

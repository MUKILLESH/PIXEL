extends Node2D
## Draws Ironwatch Keep's basalt flagstones, ruined courtyard statue circle,
## cutaway archive library tiles, Hall of Crests heraldic floor, Shadowed Passage stealth
## lane with glowing Safe Alcoves, and northern Beacon Vault star-mandala.
## No oversized permanent ground text labels (landmarks speak through architecture).

var crest_puzzle_solved: bool = false
var shadow_passage_cleared: bool = false
var third_beacon_activated: bool = false
var active_checkpoint_id: String = "checkpoint_0"
var _pulse_phase: float = 0.0
var _redraw_accum: float = 0.0

const Art = preload("res://scripts/world/ironwatch_art.gd")
func _draw() -> void:
	_draw_base()
	_draw_details()
func _draw_base() -> void:
	var stone_dark := Color("1d202b")
	var basalt := Color("282c3a")
	var basalt_light := Color("363c4f")
	var road_trim := Color("43495e")
	var arcane_purple := Color("3b2759")
	var gold_inlay := Color("c99c49")

	# 1. Outer Mountain Precipice Backdrop & Fortress Walkways connecting all 6 wings
	draw_rect(Rect2(-640, -420, 1280, 840), Color("11131f"))
	draw_rect(Rect2(-420, -290, 840, 580), Color("161826"))
	draw_rect(Rect2(-340, -240, 680, 490), Color("1a1d2b"))
	draw_rect(Rect2(-315, -220, 630, 450), stone_dark)
	# Subtle outer battlement stones around southern mountain rim so edges never crop sharply
	for rx in range(-320, 320, 48):
		draw_rect(Rect2(rx, 240, 26, 10), Color("242736"))
		draw_rect(Rect2(rx + 12, -252, 24, 10), Color("1f2230"))

	# Courtyard -> East Archives -> West Barracks -> North Hall of Crests paths
	draw_polyline(PackedVector2Array([Vector2(185, 222), Vector2(120, 185), Vector2(18, 152), Vector2(-18, 25)]), road_trim, 32.0)
	draw_polyline(PackedVector2Array([Vector2(185, 222), Vector2(120, 185), Vector2(18, 152), Vector2(-18, 25)]), basalt, 24.0)
	draw_polyline(PackedVector2Array([Vector2(18, 152), Vector2(-185, 130)]), basalt, 24.0)
	draw_polyline(PackedVector2Array([Vector2(18, 152), Vector2(185, 52)]), basalt, 24.0)
	draw_polyline(PackedVector2Array([Vector2(-18, 25), Vector2(-160, 12), Vector2(-160, -32)]), basalt, 22.0)

	# 3. Abandoned Barracks Stone Floor (South-West Wing)
	draw_rect(Rect2(-285, 86, 175, 118), Color("232733"))
	for bx in range(-278, -118, 18):
		for by in range(92, 198, 16):
			draw_rect(Rect2(bx, by, 14, 12), Color("2c303f"))

	# 4. Cutaway Fortress Archives Floor (East Wing)
	draw_rect(Rect2(138, -22, 150, 116), Color("242836"))
	for ax in range(144, 280, 16):
		for ay in range(-16, 86, 14):
			draw_rect(Rect2(ax, ay, 12, 10), Color("2e3345"))
	# Warm candle pool on Archive floor
	draw_circle(Vector2(204, 34), 34.0, Color(0.92, 0.72, 0.34, 0.14))

	# 5. Hall of Crests Arcane Mandala (Center Plaza)
	draw_rect(Rect2(-96, -34, 178, 86), arcane_purple)
	draw_rect(Rect2(-90, -28, 166, 74), Color("241e38"))

	# 6. Shadowed Passage Stealth Corridor (West North-South Lane)
	draw_rect(Rect2(-206, -188, 92, 164), Color("161524"))
	draw_rect(Rect2(-198, -182, 76, 154), Color("1d1c30"))
	# 7. Warden's Chamber & Beacon Vault (North Celestial Dais)
	draw_rect(Rect2(-102, -218, 304, 134), Color("1e1a30"))
	draw_rect(Rect2(-94, -210, 288, 118), Color("282242"))
	draw_polyline(PackedVector2Array([Vector2(-150, -164), Vector2(-45, -150), Vector2(70, -148), Vector2(152, -162)]), Color("373059"), 22.0)

	# Flanking battlements & northern curtain walls
	draw_rect(Rect2(-335, -238, 670, 16), Color("242736"))
	draw_rect(Rect2(-335, 224, 670, 16), Color("242736"))
	draw_rect(Rect2(-115, -72, 430, 16), Color("262938"))

	# Cracked stonework seams, worn Warden banners, discarded gear & orange torch flicker
	draw_polyline(PackedVector2Array([Vector2(66, 174), Vector2(76, 182), Vector2(88, 178)]), Color("161822"), 1.5)
	draw_polyline(PackedVector2Array([Vector2(-74, 128), Vector2(-62, 134), Vector2(-54, 126)]), Color("161822"), 1.5)
	# Discarded Warden heater shield & bent pike outside Abandoned Barracks
	draw_colored_polygon(PackedVector2Array([Vector2(-248, 92), Vector2(-240, 92), Vector2(-241, 100), Vector2(-244, 103), Vector2(-247, 100)]), Color("5d677a"))
	draw_line(Vector2(-254, 104), Vector2(-236, 94), Color("5c3f26"), 2.0)
	# Tattered crimson-violet Warden banners along Keep walls
	for bx in [-46, 8, 134, 210]:
		draw_rect(Rect2(bx, 184, 7, 14), Color("4f2238"))
		draw_rect(Rect2(bx + 2, 186, 3, 7), Color("d9a94e"))


func _draw_details() -> void:
	var routes := [[Vector2(185,222),Vector2(120,185),Vector2(18,152),Vector2(-18,25)],[Vector2(18,152),Vector2(-185,130)],[Vector2(18,152),Vector2(185,52)],[Vector2(-18,25),Vector2(-160,12),Vector2(-160,-32)],[Vector2(-150,-164),Vector2(-45,-150),Vector2(70,-148),Vector2(152,-162)]]
	for x in range(-306,308,20):
		for y in range(-211,223,5):
			var p := Vector2(x+(10 if posmod(y,10) < 5 else 0),y)
			var distance: float = 10000
			for route: Array in routes:
				for i in range(route.size()-1):
					distance = minf(distance,p.distance_to(Geometry2D.get_closest_point_to_segment(p,route[i],route[i+1])))
			if Rect2(-210,-190,100,165).has_point(p): continue # Stealth floor stays quiet.
			var in_room: bool = Rect2(-94,-210,288,116).has_point(p) or Rect2(138,-22,150,116).has_point(p) or Rect2(-285,86,175,118).has_point(p)
			if distance < 11 or in_room:
				Art.poly(self,[p+Vector2(-10,0),p+Vector2(0,-5),p+Vector2(10,0),p+Vector2(0,5)],"373f51" if posmod(x*7+y,9) else "3d4659")
				draw_polyline(PackedVector2Array([p+Vector2(-9,0),p+Vector2(0,5),p+Vector2(9,0)]),Color("2b3344"),1)
				if posmod(x*11+y,31) == 0: draw_line(p,p+Vector2(3,2),Color("191e2d"),1)
	# Separate chambers: woven carpets with worn bronze borders.
	for item: Array in [[Vector2(215,38),31,17],[Vector2(-35,-145),28,17]]:
		var p: Vector2 = item[0]
		var w: float = item[1]
		var d: float = item[2]
		Art.poly(self,[p+Vector2(-w,0),p+Vector2(0,-d),p+Vector2(w,0),p+Vector2(0,d)],"7b674f")
		Art.poly(self,[p+Vector2(-w+3,0),p+Vector2(0,-d+2),p+Vector2(w-3,0),p+Vector2(0,d-2)],"513547")
		for i in range(-2,3):
			draw_line(p+Vector2(i*6-4,0),p+Vector2(i*6,-3),Color("94765b"),1)
			draw_line(p+Vector2(i*6,-3),p+Vector2(i*6+4,0),Color("94765b"),1)
	# Three deliberate 2:1 ceremonial platforms. The actual checkpoints are NOT re-projected.
	for item: Array in [[Vector2(18,152),55],[Vector2(-18,16),46],[Vector2(70,-148),52]]:
		var p: Vector2 = item[0]
		var w: float = item[1]
		Art.block(self,p+Vector2(0,3),w,w/2,5)
		Art.block(self,p-Vector2(0,2),w-7,(w-7)/2,4)
		for r in [w-12,w-22]:
			draw_polyline(PackedVector2Array([p+Vector2(-r,-5),p+Vector2(0,-r/2-5),p+Vector2(r,-5),p+Vector2(0,r/2-5),p+Vector2(-r,-5)]),Color("af9770"),1)
		for i in range(12):
			var a: float = i*TAU/12
			var q := p+Vector2(cos(a)*(w-13),sin(a)*(w-13)*0.5-5).round()
			draw_line(q,q+Vector2(2,-3),Color("c4b28b"),1)
			draw_line(q+Vector2(2,-3),q+Vector2(4,0),Color("c4b28b"),1)
	# Stair courses at the Warden's command platform and along the vault approach.
	for i in range(4):
		draw_line(Vector2(-65+i*3,-126-i*4),Vector2(-20+i*3,-126-i*4),Color("73768a"),2)
		draw_line(Vector2(-65+i*3,-124-i*4),Vector2(-20+i*3,-124-i*4),Color("262c40"),1)
	# Exposed passages have large, quiet floor blocks for ring and player contrast.
	for y in range(-180,-29,12):
		for x in range(-194,-125,18):
			draw_rect(Rect2(x,y,16,10),Color("2d3045") if posmod(x+y,5) else Color("34384d"))
			if posmod(x+y,7) == 0:
				draw_polyline(PackedVector2Array([Vector2(x+2,y),Vector2(x+5,y+4),Vector2(x+3,y+8)]),Color("1c2235"),1)
	# Grounded shadow wedges: direction is consistent and the stealth lane is excluded.
	for item: Array in [[Vector2(248,178),55],[Vector2(-265,118),54],[Vector2(-18,-44),48],[Vector2(215,24),66]]:
		var p: Vector2 = item[0]
		var width: float = item[1]
		draw_colored_polygon(PackedVector2Array([p+Vector2(-width,0),p+Vector2(width,0),p+Vector2(width+26,21),p+Vector2(18,32)]),Color(0.03,0.04,0.09,0.28))
	# Lost equipment on the barracks apron: split sword, shield, helmet and abandoned papers.
	for p: Vector2 in [Vector2(-226,185),Vector2(-151,151)]:
		Art.poly(self,[p+Vector2(-5,-3),p+Vector2(6,-3),p+Vector2(4,4),p+Vector2(0,7),p+Vector2(-4,4)],"6b6e7c")
		draw_line(p+Vector2(-3,-1),p+Vector2(3,4),Color("343e50"),2)
		draw_line(p+Vector2(10,3),p+Vector2(18,-4),Color("9e9b98"),2)
		draw_line(p+Vector2(9,0),p+Vector2(13,5),Color("a58a60"),2)
	for p: Vector2 in [Vector2(254,53),Vector2(-173,110)]:
		Art.poly(self,[p,p+Vector2(7,-3),p+Vector2(12,0),p+Vector2(4,4)],"b7ac90")
		draw_line(p+Vector2(3,0),p+Vector2(7,1),Color("79725e"),1)

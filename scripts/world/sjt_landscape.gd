extends Node2D
const FONT = preload("res://assets/fonts/after_hours.tres")

var pedestal_awakened: bool = false
var _anim_time: float = 0.0
var _redraw_accum: float = 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_anim_time = fmod(_anim_time + delta, TAU * 8.0)
	_redraw_accum += delta
	if _redraw_accum >= 0.08:
		_redraw_accum = 0.0
		queue_redraw()

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
	# Warm forge ember spill onto cobbles near Blacksmith bays
	poly([Vector2(48,-52),Vector2(88,-72),Vector2(114,-56),Vector2(74,-36)],Color(0.95,0.48,0.16,0.16))
	# Atmospheric warm lantern/candle pools at Cottage doorstep, Belfry steps, and Rune Pedestal
	var flicker: float = 1.0 + sin(_anim_time * 5.2) * 0.14
	for spot: Array in [[Vector2(-82,24),26,Color(0.96,0.72,0.34,0.11)],[Vector2(30,2),28,Color(0.96,0.76,0.38,0.12)],[Vector2(120,55),24,Color(0.98,0.80,0.36,0.10)]]:
		var pool := PackedVector2Array()
		var r: float = float(spot[1]) * flicker
		for i in range(12):
			pool.append(spot[0] + Vector2(cos(i * TAU / 12) * r, sin(i * TAU / 12) * r * 0.5).round())
		draw_colored_polygon(pool, spot[2])
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
	var ripple_off: float = sin(_anim_time * 2.1) * 3.0
	draw_line(Vector2(22 + ripple_off, 148), Vector2(36 + ripple_off, 148), Color(0.55, 0.85, 0.96, 0.35), 1.0)
	if pedestal_awakened:
		var beam := PackedVector2Array([Vector2(120,55),Vector2(75,28),Vector2(25,0),Vector2(-10,25),Vector2(-75,105),Vector2(-155,160),Vector2(-198,178)])
		draw_polyline(beam,Color(0.38,0.85,0.92,0.22),10)
		draw_polyline(beam,Color(0.70,0.96,0.98,0.62),2)
		for m in range(5):
			var mote_y: float = 48.0 - fmod(_anim_time * 12.0 + float(m) * 9.0, 28.0)
			var mote_x: float = 120.0 + sin(_anim_time * 2.0 + float(m)) * 8.0
			draw_rect(Rect2(mote_x, mote_y, 2, 2), Color(0.88, 0.96, 1.0, 0.72))
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
	for actor: Node2D in get_parent().get_node("Actors").get_children():
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
	var sway_x: int = roundi(sin(_anim_time * 1.9) * 1.2)
	for point: Vector2 in [Vector2(-75,70),Vector2(-90,85),Vector2(-110,100),Vector2(110,135),Vector2(130,145),Vector2(145,155)]:
		draw_rect(Rect2(point,Vector2(18,6)),Color("1f382d"))
		draw_rect(Rect2(point+Vector2(2 + sway_x,-4),Vector2(14,7)),Color("375740"))
		draw_rect(Rect2(point+Vector2(4 + sway_x,-4),Vector2(2,2)),Color("e0ba67"))
	var edge := PackedVector2Array([Vector2(0,-320),Vector2(672,16),Vector2(0,352),Vector2(-672,16),Vector2(0,-320)])
	draw_polyline(edge,Color("5c564e"),3)

func poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points),color)

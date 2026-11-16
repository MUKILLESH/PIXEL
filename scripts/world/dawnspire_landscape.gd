extends Node2D
## Procedural alpine precipice, storm-cloud horizon, Whispering Cliffs wind zones & shelters,
## deep ravine & counterweight Skybridge deck, Pilgrim's Refuge tiles, Celestial Observatory
## star ring, and Dawnspire Sanctuary three-beacon convergence terrain.
## Redraws throttled at ~12.5 Hz. No oversized permanent ground text labels.

var cliffs_navigated: bool = false
var skybridge_repaired: bool = false
var observatory_solved: bool = false
var beacons_synchronized: bool = false
var great_bell_gate_unlocked: bool = false
var active_cliff_checkpoint_id: String = "cliff_cp_0"
var wind_gust_active: bool = false
var wind_warning_active: bool = false
var wind_strength: float = 0.0

var _anim_phase: float = 0.0
var _redraw_accum: float = 0.0

func _process(delta: float) -> void:
	_anim_phase = fmod(_anim_phase + delta * 1.6, TAU)
	if not Engine.is_editor_hint():
		_redraw_accum += delta
		if _redraw_accum >= 0.08:
			_redraw_accum = 0.0
			queue_redraw()

func _draw() -> void:
	# 1. Outer Storm-Cloud Horizon & Alpine Basalt Precipice (-640..640 x -420..420)
	draw_rect(Rect2(-640, -420, 1280, 840), Color("101624"))
	draw_rect(Rect2(-460, -310, 920, 620), Color("162033"))
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

	# 4. Whispering Cliffs Checkpoints (Safe Shelter Stones) & Wind Gust Streaks
	var cps := [
		{"id": "cliff_cp_0", "pos": Vector2(30, 184)},
		{"id": "cliff_cp_1", "pos": Vector2(180, 174)},
		{"id": "cliff_cp_2", "pos": Vector2(210, 74)},
	]
	for cp in cps:
		var cp_pos: Vector2 = cp["pos"]
		var is_active: bool = (active_cliff_checkpoint_id == String(cp["id"]))
		var ring_col := Color("8be6f0") if is_active else Color("7c889e")
		draw_circle(cp_pos, 18.0, Color(0.20, 0.25, 0.34, 0.85))
		draw_arc(cp_pos, 18.0, 0.0, TAU, 24, ring_col, 1.8 if is_active else 1.1)
		draw_circle(cp_pos, 5.0, ring_col)

	# Telegraphed Wind Zone across eastern Whispering Cliffs (x: 118..278, y: 86..196)
	var wind_box := Rect2(118, 86, 160, 110)
	if wind_gust_active and not cliffs_navigated:
		draw_rect(wind_box, Color(0.55, 0.82, 0.96, 0.12))
		for wi in range(7):
			var wy: float = 96.0 + float(wi) * 14.0
			var wx: float = 122.0 + fmod((_anim_phase * 48.0 + float(wi) * 29.0), 130.0)
			draw_line(Vector2(wx, wy), Vector2(wx + 24.0, wy + 2.0), Color(0.84, 0.94, 1.0, 0.55), 1.6)
	elif wind_warning_active and not cliffs_navigated:
		draw_rect(wind_box, Color(0.95, 0.78, 0.42, 0.08))
		for wi in range(5):
			var wy: float = 100.0 + float(wi) * 20.0
			var wx: float = 128.0 + fmod((_anim_phase * 22.0 + float(wi) * 21.0), 120.0)
			draw_line(Vector2(wx, wy), Vector2(wx + 12.0, wy), Color(0.95, 0.84, 0.52, 0.35), 1.0)
	else:
		draw_line(Vector2(280, 78), Vector2(280, 208), Color(0.75, 0.35, 0.38, 0.45), 1.5)

	# 5. Skybridge Deck across the Ravine (x = -22..22, y = -48..2)
	if skybridge_repaired:
		# Solid stone-and-timber suspension bridge + tension cables
		draw_rect(Rect2(-24, -48, 48, 50), Color("4c4237"))
		for py in range(-44, 0, 7):
			draw_rect(Rect2(-20, py, 40, 4), Color("7c6248"))
		draw_line(Vector2(-24, -48), Vector2(-24, 2), Color("b89658"), 2.0)
		draw_line(Vector2(24, -48), Vector2(24, 2), Color("b89658"), 2.0)
		draw_line(Vector2(-24, -22), Vector2(-42, -4), Color("8be6f0"), 1.5)
		draw_line(Vector2(24, -22), Vector2(42, -4), Color("8be6f0"), 1.5)
	else:
		# Broken stumps over chasm + dangling snapped iron cables
		draw_rect(Rect2(-22, -48, 44, 10), Color("3c332d"))
		draw_rect(Rect2(-22, -8, 44, 10), Color("3c332d"))
		draw_line(Vector2(-18, -38), Vector2(-12, -27), Color("5b6273"), 1.5)
		draw_line(Vector2(18, -8), Vector2(10, -20), Color("5b6273"), 1.5)

	# 6. Celestial Observatory Star Mandala Ring (centered around x = 204, y = -98)
	var obs_c := Vector2(204, -98)
	var ring_tint := Color("8be6f0") if observatory_solved else Color("6e7894")
	draw_circle(obs_c, 42.0, Color(0.14, 0.17, 0.28, 0.72))
	draw_arc(obs_c, 40.0, 0.0, TAU, 36, ring_tint, 1.5)
	draw_arc(obs_c, 26.0, 0.0, TAU, 30, Color("d4a84f"), 1.2)
	for ai in range(8):
		var ang: float = float(ai) * (PI / 4.0) + (_anim_phase * 0.25 if observatory_solved else 0.0)
		draw_line(obs_c + Vector2(cos(ang), sin(ang)) * 14.0, obs_c + Vector2(cos(ang), sin(ang)) * 38.0, ring_tint, 1.0)
	if not observatory_solved:
		# Sealed Sanctuary stair rune barrier
		draw_line(Vector2(-2, -150), Vector2(50, -150), Color("e67365"), 2.4)
	else:
		# Unsealed golden-cyan stair beam heading north into Dawnspire Sanctuary
		draw_line(obs_c, Vector2(24, -150), Color(0.55, 0.92, 1.0, 0.52), 2.5)
		draw_line(Vector2(24, -150), Vector2(-32, -196), Color(0.98, 0.85, 0.45, 0.58), 2.5)

	# 7. Dawnspire Sanctuary Three-Beacon Convergence Centerpiece (around Vector2(-32, -196))
	var sanc_c := Vector2(-32, -196)
	draw_circle(sanc_c, 34.0, Color(0.16, 0.20, 0.30, 0.80))
	draw_arc(sanc_c, 34.0, 0.0, TAU, 36, Color("ffe38f") if beacons_synchronized else Color("6b7694"), 2.0)
	if beacons_synchronized:
		var pulse_r: float = 16.0 + sin(_anim_phase * 2.0) * 3.0
		draw_arc(sanc_c, pulse_r, 0.0, TAU, 24, Color("8ef5ff"), 1.6)
		# Three incoming Beacon rays from Ashvale valley below (Briarwood, Floodmill, Ironwatch)
		draw_line(Vector2(-150, 40), sanc_c, Color(0.98, 0.82, 0.36, 0.45), 2.0)
		draw_line(Vector2(24, 40), sanc_c, Color(0.45, 0.90, 0.98, 0.45), 2.0)
		draw_line(Vector2(170, 40), sanc_c, Color(0.75, 0.62, 0.98, 0.45), 2.0)
		if great_bell_gate_unlocked:
			draw_line(sanc_c, Vector2(96, -194), Color(0.98, 0.88, 0.48, 0.72), 3.0)

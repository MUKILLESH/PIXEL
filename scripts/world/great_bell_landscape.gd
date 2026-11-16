extends Node2D
## Procedural 2.5D pixel-art terrain for Chapter 5 (The Great Bell Sanctum).
## Draws Areas A-D: The Bell Antechamber, Hall of Forgotten Names,
## The Heart of the Bell (conduit beams & breaking chains), and The Dawn Terrace.

var memory_fragments_count: int = 0
var elena_message_heard: bool = false
var conduit_briarwood: bool = false
var conduit_floodmill: bool = false
var conduit_ironwatch: bool = false
var network_stabilized: bool = false
var binding_severed: bool = false
var storm_resolved: bool = false
var elena_journal_placed: bool = false

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
	# Sky/Abyss backdrop shifts from stormy obsidian-violet to warm sunrise gold when storm resolves
	var void_col := Color("202c3d") if storm_resolved else Color("0d101b")
	var ridge_col := Color("334459") if storm_resolved else Color("141a2b")
	draw_rect(Rect2(-640, -420, 1280, 840), void_col)
	draw_rect(Rect2(-640, -360, 1280, 720), ridge_col)

	if storm_resolved:
		# Seamless morning sky bands & golden sunrise shafts over Dawn Terrace
		draw_rect(Rect2(-640, -420, 1280, 840), Color(0.98, 0.78, 0.48, 0.07))
		for ri in range(4):
			var ray_x: float = 212.0 + float(ri) * 42.0
			draw_line(Vector2(ray_x + 56.0, -240.0), Vector2(ray_x - 36.0, 20.0), Color(1.0, 0.88, 0.58, 0.14), 10.0)
	else:
		# Veilstorm swirling violet storm clouds beyond precipice
		var drift: float = sin(_anim_phase) * 12.0
		for si in range(-2, 3):
			var sy: float = float(si) * 90.0
			draw_rect(Rect2(-520 + drift, sy, 180, 22), Color(0.24, 0.19, 0.34, 0.32))
			draw_rect(Rect2(240 - drift, sy - 20.0, 200, 24), Color(0.22, 0.18, 0.32, 0.30))

	# Area A: The Bell Antechamber (x: -316..0, y: 128..246)
	draw_rect(Rect2(-318, 126, 320, 122), Color("252c3b"))
	draw_rect(Rect2(-310, 134, 304, 108), Color("323b4f"))
	for tx in range(-296, -12, 32):
		for ty in range(144, 232, 24):
			draw_rect(Rect2(tx, ty, 28, 20), Color("39445c") if ((tx + ty) % 64 == 0) else Color("2e374a"))
	# Bronze floor runner & recessed compass medallion toward Forgotten Hall arch
	draw_rect(Rect2(-190, 128, 28, 86), Color("5e4b34"))
	draw_rect(Rect2(-186, 128, 20, 82), Color("7a6141"))
	draw_arc(Vector2(-152, 184), 20.0, 0.0, TAU, 24, Color("9c7c48"), 1.5)
	for br in [Vector2(-248, 166), Vector2(-56, 166)]:
		draw_circle(br, 22.0, Color(1.0, 0.72, 0.34, 0.11 + 0.03 * sin(_anim_phase * 2.0)))

	# Area B: Hall of Forgotten Names (x: -316..112, y: -2..126)
	draw_rect(Rect2(-318, -4, 432, 132), Color("212738"))
	draw_rect(Rect2(-310, 4, 416, 118), Color("2b3349"))
	for hx in range(-296, 98, 28):
		for hy in range(14, 112, 22):
			draw_rect(Rect2(hx, hy, 24, 18), Color("333e57") if ((hx + hy) % 56 == 0) else Color("283044"))
	# Engraved gallery memory-plaques & alcove crystal shimmer
	for px in range(-282, 92, 42):
		draw_rect(Rect2(px, 6, 18, 4), Color("556787"))
	for alc in [Vector2(-254, 64), Vector2(-176, 30), Vector2(-86, 44)]:
		draw_circle(alc, 16.0, Color(0.50, 0.88, 0.98, 0.12))
	# Memory-crystal gallery carpet
	draw_rect(Rect2(-264, 58, 320, 20), Color("394a63"))
	draw_rect(Rect2(-188, 6, 24, 116), Color("3f536e"))
	draw_rect(Rect2(18, -2, 24, 90), Color("4c5e7a"))
	draw_circle(Vector2(44, 48), 18.0, Color(0.98, 0.84, 0.48, 0.14) if elena_message_heard else Color(0.55, 0.88, 0.98, 0.12))
	if elena_message_heard:
		draw_rect(Rect2(20, -2, 20, 84), Color(0.55, 0.88, 0.96, 0.22))

	# Area C: The Heart of the Bell (x: -168..198, y: -186..-2)
	draw_rect(Rect2(-170, -188, 370, 188), Color("1e2333"))
	draw_rect(Rect2(-162, -180, 354, 174), Color("272e42"))
	# Concentric sunken dais circles & radial harmonic spokes beneath the Great Bell
	draw_circle(Vector2(30, -84), 86.0, Color("30384f"))
	draw_circle(Vector2(30, -84), 68.0, Color("232a3c"))
	draw_circle(Vector2(30, -84), 48.0, Color("3c4763"))
	for si in range(8):
		var ang: float = float(si) * TAU / 8.0
		draw_line(Vector2(30, -84) + Vector2(cos(ang), sin(ang)) * 50.0, Vector2(30, -84) + Vector2(cos(ang), sin(ang)) * 82.0, Color("485575"), 1.5)
	var ring_col: Color = Color(0.98, 0.86, 0.48, 0.72) if storm_resolved else Color(0.45, 0.78, 0.92, 0.48)
	draw_arc(Vector2(30, -84), 78.0, 0.0, TAU, 36, ring_col, 1.5)
	draw_arc(Vector2(30, -84), 48.0, 0.0, TAU, 32, Color("d9a94e") if network_stabilized else Color("5c6680"), 1.5)
	for rc in [Vector2(-96, -84), Vector2(30, -154), Vector2(150, -84)]:
		draw_arc(rc, 14.0, 0.0, TAU, 20, Color("667591"), 1.2)

	# Conduit stone tracks (West: Briarwood, North: Floodmill, East: Ironwatch)
	draw_line(Vector2(-96, -84), Vector2(30, -84), Color("545d75"), 8.0)
	draw_line(Vector2(30, -154), Vector2(30, -84), Color("545d75"), 8.0)
	draw_line(Vector2(150, -84), Vector2(30, -84), Color("545d75"), 8.0)

	# Dark memory-chains binding the Bell until severed
	if not binding_severed:
		for ch_end in [Vector2(-44, -138), Vector2(104, -138), Vector2(-38, -28), Vector2(98, -28)]:
			draw_line(Vector2(30, -84), ch_end, Color("241c30"), 3.0)
			draw_line(Vector2(30, -84), ch_end, Color("6e5285"), 1.0)
	else:
		# Broken golden sparks drifting upward once chains sever
		for si in range(6):
			var sp_y: float = -48.0 - fmod(_anim_phase * 8.0 + float(si) * 14.0, 72.0)
			var sp_x: float = 30.0 + sin(_anim_phase + float(si)) * 28.0
			draw_rect(Rect2(sp_x, sp_y, 2, 2), Color(1.0, 0.92, 0.56, 0.85))

	# Active Beacon Conduit Energy Beams feeding Great Bell
	var pulse: float = 0.72 + 0.25 * sin(_anim_phase * 2.4)
	if conduit_briarwood:
		draw_line(Vector2(-96, -84), Vector2(30, -84), Color(0.42, 0.92, 0.62, 0.42 * pulse), 5.0)
		draw_line(Vector2(-96, -84), Vector2(30, -84), Color(0.84, 1.0, 0.88, 0.85), 1.5)
	if conduit_floodmill:
		draw_line(Vector2(30, -154), Vector2(30, -84), Color(0.45, 0.88, 0.98, 0.42 * pulse), 5.0)
		draw_line(Vector2(30, -154), Vector2(30, -84), Color(0.86, 0.98, 1.0, 0.85), 1.5)
	if conduit_ironwatch:
		draw_line(Vector2(150, -84), Vector2(30, -84), Color(0.98, 0.78, 0.36, 0.42 * pulse), 5.0)
		draw_line(Vector2(150, -84), Vector2(30, -84), Color(1.0, 0.94, 0.76, 0.85), 1.5)
	if network_stabilized:
		draw_arc(Vector2(30, -84), 66.0, 0.0, TAU, 36, Color(0.98, 0.90, 0.55, 0.48 * pulse), 3.0)

	# Area D: The Dawn Terrace (x: 198..348, y: -148..-12)
	var terrace_base := Color("595348") if storm_resolved else Color("2b3242")
	var terrace_tile := Color("73695b") if storm_resolved else Color("363f54")
	draw_rect(Rect2(198, -148, 150, 136), terrace_base)
	draw_rect(Rect2(204, -142, 138, 124), terrace_tile)
	if storm_resolved:
		# Distant sunlit mountain ridges & warm morning halo around Memorial
		draw_colored_polygon(PackedVector2Array([Vector2(355, -20), Vector2(435, -138), Vector2(530, -20)]), Color(0.28, 0.36, 0.46, 0.45))
		draw_colored_polygon(PackedVector2Array([Vector2(430, -20), Vector2(515, -110), Vector2(610, -20)]), Color(0.36, 0.44, 0.54, 0.35))
		draw_rect(Rect2(204, -142, 138, 124), Color(1.0, 0.86, 0.56, 0.14))
		draw_circle(Vector2(298, -84), 24.0, Color(1.0, 0.90, 0.58, 0.18))
	# Carved balustrade stone trim & bollards along Dawn Terrace east edge
	draw_rect(Rect2(338, -146, 8, 132), Color("8c8273") if storm_resolved else Color("4a5469"))
	for by in range(-136, -16, 28):
		draw_rect(Rect2(337, by, 10, 6), Color("c4b79e") if storm_resolved else Color("667491"))

	# Subtle wall borders showing exact doorways
	var wall_col := Color("495369")
	draw_rect(Rect2(-318, 126, 108, 6), wall_col)
	draw_rect(Rect2(-142, 126, 256, 6), wall_col)
	draw_rect(Rect2(-318, -4, 314, 6), wall_col)
	draw_rect(Rect2(64, -4, 134, 6), wall_col)
	draw_rect(Rect2(196, -184, 6, 76), wall_col)
	draw_rect(Rect2(196, -48, 6, 48), wall_col)

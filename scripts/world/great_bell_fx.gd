extends Node2D
## GFX-6 Animated overlay layer for the Great Bell Sanctum.
## Child of Landscape (z_index = 0) so effects sit above static floor/architecture
## while staying strictly behind Y-sorted actors and HUD/interaction prompts.
## Throttled to ~15 FPS so steady frame time stays locked at 60 FPS.

const Art = preload("res://scripts/world/great_bell_art.gd")

const DAIS := Vector2(30, -84)
const BELL_RIM := Vector2(30, -190)
const CONDUIT_W := Vector2(-96, -84)
const CONDUIT_N := Vector2(30, -154)
const CONDUIT_E := Vector2(150, -84)
const CHAIN_BELL := [Vector2(-4, -212), Vector2(64, -212), Vector2(-12, -192), Vector2(72, -192)]
const CHAIN_ANCHORS := [Vector2(-92, -162), Vector2(150, -162), Vector2(20, -108), Vector2(40, -108)]

var _phase: float = 0.0
var _accum: float = 0.0

func _process(delta: float) -> void:
	_phase = fmod(_phase + delta * 1.8, TAU * 4.0)
	if not Engine.is_editor_hint():
		_accum += delta
		if _accum >= 0.066:
			_accum = 0.0
			queue_redraw()

func _draw() -> void:
	var p: Node2D = get_parent() as Node2D
	if p == null:
		return
	var mem_cnt: int = int(p.get("memory_fragments_count"))
	var elena_heard: bool = bool(p.get("elena_message_heard"))
	var c_briar: bool = bool(p.get("conduit_briarwood"))
	var c_flood: bool = bool(p.get("conduit_floodmill"))
	var c_iron: bool = bool(p.get("conduit_ironwatch"))
	var stabilized: bool = bool(p.get("network_stabilized"))
	var severed: bool = bool(p.get("binding_severed"))
	var dawn: bool = bool(p.get("storm_resolved"))
	var journal: bool = bool(p.get("elena_journal_placed"))

	_draw_atmosphere(dawn)
	_draw_brazier_flicker(dawn)
	_draw_hall_motes(mem_cnt, elena_heard)
	_draw_conduit_pulses(c_briar, c_flood, c_iron, stabilized, severed)
	_draw_bell_resonance(stabilized, severed, dawn)
	if dawn:
		_draw_terrace_sunbeams(journal)

func _draw_atmosphere(dawn: bool) -> void:
	if not dawn:
		# Drifting abyss cloud wisps outside the Sanctum cliffs
		var drift := sin(_phase * 0.35) * 14.0
		for wi in range(5):
			var wy: float = -220.0 + float(wi) * 95.0
			var wx: float = -520.0 + drift * (1.0 if wi % 2 == 0 else -1.0)
			draw_rect(Rect2(floorf(wx), wy, 140, 6), Color(0.20, 0.16, 0.34, 0.24))
			draw_rect(Rect2(floorf(380.0 - drift * 0.8), wy + 18.0, 150, 6), Color(0.18, 0.15, 0.30, 0.22))
		# Diagonal cool stormlight shafts from the 4 Gothic lancet windows
		var a_beam: float = 0.07 + 0.02 * sin(_phase * 0.7)
		for wx in [-142.0, -108.0, 150.0, 172.0]:
			draw_colored_polygon(PackedVector2Array([
				Vector2(wx - 4.0, -196.0),
				Vector2(wx + 4.0, -196.0),
				Vector2(wx - 10.0, -134.0),
				Vector2(wx - 22.0, -134.0)
			]), Color(0.45, 0.62, 0.94, a_beam))
	else:
		# Soft sunlit shafts through the four Gothic lancet windows
		var a_sun: float = 0.12 + 0.03 * sin(_phase * 0.6)
		for wx in [-142.0, -108.0, 150.0, 172.0]:
			draw_colored_polygon(PackedVector2Array([
				Vector2(wx - 5.0, -196.0),
				Vector2(wx + 5.0, -196.0),
				Vector2(wx - 14.0, -124.0),
				Vector2(wx - 28.0, -124.0)
			]), Color(1.0, 0.86, 0.54, a_sun))

func _draw_brazier_flicker(dawn: bool) -> void:
	var braziers := [Vector2(-248, 166), Vector2(-56, 166), Vector2(-96, -24), Vector2(150, -24)]
	for bi in range(braziers.size()):
		var b: Vector2 = braziers[bi]
		var flk: float = 0.85 + 0.15 * sin(_phase * 2.8 + float(bi) * 1.7)
		var outer_a: float = (0.06 if dawn else 0.11) * flk
		var inner_a: float = (0.10 if dawn else 0.18) * flk
		Art.ellipse(self, b, 24.0, 12.0, Color(1.0, 0.66, 0.28, outer_a))
		Art.ellipse(self, b, 13.0, 7.0, Color(1.0, 0.86, 0.48, inner_a))
		# Rising 1px embers above flame
		var ey: float = b.y - 22.0 - fmod(_phase * 6.0 + float(bi) * 3.0, 10.0)
		var ex: float = b.x + sin(_phase * 2.1 + float(bi) * 2.3) * 3.0
		draw_rect(Rect2(floorf(ex), floorf(ey), 1, 1), Color(1.0, 0.88, 0.45, 0.8))

func _draw_hall_motes(mem_cnt: int, elena_heard: bool) -> void:
	var alcoves := [Vector2(-254, 64), Vector2(-176, 30), Vector2(-86, 44)]
	for i in range(alcoves.size()):
		var a: Vector2 = alcoves[i]
		var lit: bool = mem_cnt > i
		var col_m: Color = Color("f2cf78") if lit else Color("8bf0ff")
		var pulse: float = 0.10 + 0.04 * sin(_phase * 1.4 + float(i))
		Art.ellipse(self, a + Vector2(0, 2), 17.0, 8.5, Color(col_m.r, col_m.g, col_m.b, pulse))
		for m in range(2):
			var my: float = a.y - 14.0 - fmod(_phase * 4.5 + float(i * 5 + m * 6), 14.0)
			var mx: float = a.x - 4.0 + float(m * 7) + sin(_phase + float(m + i)) * 2.0
			draw_rect(Rect2(floorf(mx), floorf(my), 1, 1), Color(col_m.r, col_m.g, col_m.b, 0.85))
	# Elena Echo plinth subtle shimmer
	var epos := Vector2(44, 48)
	var ec: Color = Color("fae08c") if elena_heard else Color("7fe3f0")
	Art.ellipse(self, epos + Vector2(0, 2), 18.0, 9.0, Color(ec.r, ec.g, ec.b, 0.12 + 0.04 * sin(_phase * 1.5)))

func _draw_conduit_pulses(briar: bool, flood: bool, iron: bool, stabilized: bool, severed: bool) -> void:
	var t_flow: float = fmod(_phase * 0.45, 1.0)
	if briar:
		var from := CONDUIT_W
		var to := DAIS + Vector2(-26, 0)
		draw_line(from, to, Color(0.25, 0.88, 0.56, 0.45), 4.0)
		draw_line(from, to, Color(0.80, 1.0, 0.88, 0.90), 1.0)
		for k in range(4):
			var u: float = fmod(t_flow + float(k) * 0.25, 1.0)
			var pt := from.lerp(to, u).floor()
			draw_rect(Rect2(pt.x - 2, pt.y - 1, 4, 2), Color(Art.BRIAR[4]))
			draw_rect(Rect2(pt.x - 1, pt.y - 2, 2, 4), Color(Art.BRIAR[3], 0.7))
	if flood:
		var from_n := CONDUIT_N
		var to_n := DAIS + Vector2(0, -14)
		draw_line(from_n, to_n, Color(0.24, 0.72, 0.96, 0.45), 4.0)
		draw_line(from_n, to_n, Color(0.84, 0.96, 1.0, 0.90), 1.0)
		for k in range(3):
			var u2: float = fmod(t_flow + float(k) * 0.33, 1.0)
			var pt2 := from_n.lerp(to_n, u2).floor()
			draw_rect(Rect2(pt2.x - 1, pt2.y - 2, 2, 4), Color(Art.FLOOD[4]))
			draw_rect(Rect2(pt2.x - 2, pt2.y - 1, 4, 2), Color(Art.FLOOD[3], 0.7))
	if iron:
		var from_e := CONDUIT_E
		var to_e := DAIS + Vector2(26, 0)
		draw_line(from_e, to_e, Color(0.96, 0.70, 0.22, 0.45), 4.0)
		draw_line(from_e, to_e, Color(1.0, 0.95, 0.75, 0.90), 1.0)
		for k in range(4):
			var u3: float = fmod(t_flow + float(k) * 0.25, 1.0)
			var pt3 := from_e.lerp(to_e, u3).floor()
			draw_rect(Rect2(pt3.x - 2, pt3.y - 1, 4, 2), Color(Art.IRON[4]))
			draw_rect(Rect2(pt3.x - 1, pt3.y - 2, 2, 4), Color(Art.IRON[3], 0.7))

	# Synchronized dais glow & illuminated radial seams
	if stabilized or severed:
		var p_ring: float = 0.55 + 0.30 * sin(_phase * 2.0)
		var col_ring: Color = Color(0.98, 0.86, 0.46, 0.52 * p_ring) if severed else Color(0.45, 0.90, 0.98, 0.50 * p_ring)
		Art.ellipse_band(self, DAIS, 64.0, 35.0, 1.5, col_ring)
		Art.ellipse_band(self, DAIS, 94.0, 52.0, 1.0, Color(col_ring.r, col_ring.g, col_ring.b, col_ring.a * 0.7))
		Art.ellipse_band(self, DAIS, 128.0, 71.0, 1.5, col_ring)
		for i in range(8):
			var ang: float = float(i) * TAU / 8.0
			var p0 := Art.ep(DAIS, 62.0, 34.0, ang)
			var p1 := Art.ep(DAIS, 122.0, 67.0, ang)
			draw_line(p0, p1, Color(col_ring.r, col_ring.g, col_ring.b, 0.42 * p_ring), 1.0)
		# Three vertical convergence threads rising from dais center into the Great Bell mouth
		if stabilized and not severed:
			draw_line(DAIS + Vector2(-4, -10), BELL_RIM + Vector2(-8, 0), Color(0.38, 0.92, 0.65, 0.42 * p_ring), 1.5)
			draw_line(DAIS + Vector2(0, -12), BELL_RIM + Vector2(0, 2), Color(0.45, 0.90, 1.0, 0.55 * p_ring), 2.0)
			draw_line(DAIS + Vector2(4, -10), BELL_RIM + Vector2(8, 0), Color(1.0, 0.82, 0.38, 0.42 * p_ring), 1.5)

func _draw_bell_resonance(stabilized: bool, severed: bool, dawn: bool) -> void:
	var bell_ctr := BELL_RIM + Vector2(0, -20)
	if not severed:
		if stabilized:
			# Crackling tension arcs along the 4 memory chains prior to severing
			var flash: float = 0.5 + 0.5 * sin(_phase * 4.2)
			for i in range(4):
				var a: Vector2 = CHAIN_BELL[i]
				var b: Vector2 = CHAIN_ANCHORS[i]
				var mid := a.lerp(b, fmod(_phase * 0.6 + float(i) * 0.25, 1.0)).floor()
				draw_rect(Rect2(mid.x - 1, mid.y - 1, 3, 3), Color(0.88, 0.62, 1.0, 0.85 * flash))
				draw_rect(Rect2(mid.x, mid.y, 1, 1), Color(1.0, 1.0, 1.0, flash))
			Art.ellipse_band(self, bell_ctr, 52.0, 26.0, 1.0, Color(0.48, 0.90, 0.98, 0.40 * flash))
	else:
		# Expanding serene resonance waves & ascending golden memory motes
		for ri in range(2):
			var w: float = fmod(_phase * 0.35 + float(ri) * 0.5, 1.0)
			var rx: float = 44.0 + w * 40.0
			var ry: float = 20.0 + w * 20.0
			var alpha: float = (1.0 - w) * (0.45 if dawn else 0.55)
			Art.ellipse_band(self, BELL_RIM + Vector2(0, -14), rx, ry, 1.0, Color(1.0, 0.88, 0.52, alpha))
		for mi in range(8):
			var my: float = BELL_RIM.y - 6.0 - fmod(_phase * 9.0 + float(mi) * 9.0, 56.0)
			var mx: float = BELL_RIM.x - 36.0 + float((mi * 13) % 72) + sin(_phase + float(mi)) * 4.0
			var mc := Color("fff0c0") if mi % 2 == 0 else Color("8be6f0")
			draw_rect(Rect2(floorf(mx), floorf(my), 2, 2), Color(mc.r, mc.g, mc.b, 0.82))

func _draw_terrace_sunbeams(journal_placed: bool) -> void:
	var pulse: float = 0.85 + 0.15 * sin(_phase * 0.9)
	for ri in range(4):
		var rx: float = 220.0 + float(ri) * 34.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(rx + 120.0, -440.0),
			Vector2(rx + 136.0, -440.0),
			Vector2(rx - 14.0, -16.0),
			Vector2(rx - 30.0, -16.0)
		]), Color(1.0, 0.88, 0.56, 0.08 * pulse))
	# Floating golden dust motes over the Dawn Terrace overlooking Ashvale
	for di in range(6):
		var dx: float = 216.0 + float((di * 23) % 116) + sin(_phase * 0.7 + float(di)) * 5.0
		var dy: float = -134.0 + float((di * 19) % 108) - fmod(_phase * 3.0 + float(di) * 5.0, 12.0)
		draw_rect(Rect2(floorf(dx), floorf(dy), 1, 1), Color(1.0, 0.94, 0.72, 0.75))
	if journal_placed:
		Art.ellipse(self, Vector2(298, -82), 20.0, 10.0, Color(1.0, 0.90, 0.58, 0.14 * pulse))

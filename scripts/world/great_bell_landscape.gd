extends Node2D
## GFX-6 Great Bell Sanctum terrain (static layer).
## Draws Areas A-D: Bell Antechamber, Hall of Forgotten Names, Heart of the Bell
## (ritual dais, three conduit channels, the suspended Great Bell) and Dawn Terrace.
## Redraws only when quest state changes; continuous animation runs in SanctumFx.

const Art = preload("res://scripts/world/great_bell_art.gd")
const FxScript = preload("res://scripts/world/great_bell_fx.gd")

var memory_fragments_count: int = 0
var elena_message_heard: bool = false
var conduit_briarwood: bool = false
var conduit_floodmill: bool = false
var conduit_ironwatch: bool = false
var network_stabilized: bool = false
var binding_severed: bool = false
var storm_resolved: bool = false
var elena_journal_placed: bool = false

const DAIS := Vector2(30, -84)
const BELL_RIM := Vector2(30, -190)
const BELL_R := 45
const BELL_H := 36
const CONDUIT_W := Vector2(-96, -84)
const CONDUIT_N := Vector2(30, -154)
const CONDUIT_E := Vector2(150, -84)
const CHAIN_BELL := [Vector2(-4, -212), Vector2(64, -212), Vector2(-12, -192), Vector2(72, -192)]
const CHAIN_ANCHORS := [Vector2(-92, -162), Vector2(150, -162), Vector2(20, -108), Vector2(40, -108)]

var fx: Node2D

func _ready() -> void:
	fx = Node2D.new()
	fx.name = "SanctumFx"
	fx.z_index = 0
	fx.set_script(FxScript)
	add_child(fx)

func bell_state() -> int:
	if storm_resolved:
		return 3
	if binding_severed:
		return 2
	if network_stabilized:
		return 1
	return 0

func _stone_pal() -> Array:
	var s: Array = Art.STONE
	return [s[1], s[2], s[3], s[4], s[5], s[6]]

func _floor_pal() -> Array:
	var s: Array = Art.STONE
	if storm_resolved:
		return ["1a1d27", "2a2d38", "363844", "41434f", "555865", "6b6e7b"]
	return [s[1], s[2], s[3], s[4], s[5], s[6]]

func _draw() -> void:
	_draw_sky()
	_draw_foundations()
	_draw_western_viaduct()
	_draw_floors()
	_draw_antechamber_details()
	_draw_hall_details()
	_draw_heart_dais()
	_draw_terrace_details()
	_draw_walls()
	_draw_heart_north_wall()
	_draw_bell_and_binding()
	if not elena_message_heard:
		_draw_heart_seal()

# ---------------------------------------------------------------- sky / void
func _draw_sky() -> void:
	var bands: Array
	if storm_resolved:
		bands = ["1c2340", "2b2f52", "45405f", "6a4f66", "9a6468", "c97f68", "e8a56c", "f6c985", "ffe3a8"]
	else:
		bands = ["05060c", "080a13", "0b0e1b", "0f1324", "13172c", "171b33", "1b1f3a", "1f2240", "232646"]
	var y := -460
	var bh := 64
	for i in range(bands.size()):
		draw_rect(Rect2(-720, y, 1440, bh), Color(bands[i]))
		if i < bands.size() - 1:
			var nxt := Color(bands[i + 1])
			for dx in range(-720, 720, 4):
				draw_rect(Rect2(dx + (i % 2) * 2, y + bh - 2, 2, 1), nxt)
				draw_rect(Rect2(dx + 2 - (i % 2) * 2, y + bh - 4, 1, 1), nxt)
		y += bh
	draw_rect(Rect2(-720, y, 1440, 400), Color(bands[bands.size() - 1]))
	if storm_resolved:
		var sun := Vector2(470, -40)
		for k in range(4):
			Art.ellipse(self, sun, 70.0 - float(k) * 14.0, 70.0 - float(k) * 14.0, Color(1.0, 0.86, 0.55, 0.10 + 0.05 * float(k)))
		Art.ellipse(self, sun, 18.0, 18.0, Color("fff2c4"))
		Art.ellipse(self, sun, 14.0, 14.0, Color("ffffff"))
	# Distant layered mountain silhouettes
	var ranges := [
		[-60.0, 46.0, 0.0, "2b2c4a" if storm_resolved else "0d1020"],
		[-10.0, 60.0, 37.0, "3b3554" if storm_resolved else "10142a"],
		[40.0, 78.0, 91.0, "4a3f58" if storm_resolved else "131830"],
	]
	for rg in ranges:
		var base_y: float = rg[0]
		var amp: float = rg[1]
		var seed_f: float = rg[2]
		var pts := PackedVector2Array()
		pts.append(Vector2(-720, 420))
		var x := -720.0
		while x <= 720.0:
			var hgt: float = amp * (0.55 + 0.45 * sin(x * 0.013 + seed_f)) * (0.6 + 0.4 * absf(sin(x * 0.031 + seed_f * 1.7)))
			pts.append(Vector2(x, floorf(base_y - hgt)))
			x += 12.0
		pts.append(Vector2(720, 420))
		draw_colored_polygon(pts, Color(rg[3]))
	if storm_resolved:
		var sx := 360.0
		while sx < 700.0:
			var hgt0: float = 78.0 * (0.55 + 0.45 * sin(sx * 0.013 + 91.0)) * (0.6 + 0.4 * absf(sin(sx * 0.031 + 91.0 * 1.7)))
			var hgt1: float = 78.0 * (0.55 + 0.45 * sin((sx + 6.0) * 0.013 + 91.0)) * (0.6 + 0.4 * absf(sin((sx + 6.0) * 0.031 + 91.0 * 1.7)))
			draw_line(Vector2(sx, floorf(40.0 - hgt0)), Vector2(sx + 6.0, floorf(40.0 - hgt1)), Color("e6ae74"), 2.0)
			sx += 6.0
		for cl in [Vector2(250, -150), Vector2(420, -120), Vector2(560, -175), Vector2(-420, -190), Vector2(-300, -250)]:
			draw_rect(Rect2(cl.x, cl.y, 90, 4), Color(1.0, 0.86, 0.70, 0.55))
			draw_rect(Rect2(cl.x + 14, cl.y - 3, 50, 3), Color(1.0, 0.93, 0.80, 0.6))
			draw_rect(Rect2(cl.x + 8, cl.y + 4, 70, 2), Color(0.86, 0.56, 0.52, 0.5))
	else:
		for cl in [Vector2(-560, -300), Vector2(-420, -230), Vector2(230, -280), Vector2(380, -210), Vector2(500, -330), Vector2(-600, -150)]:
			draw_rect(Rect2(cl.x, cl.y, 150, 10), Color("1c1830"))
			draw_rect(Rect2(cl.x + 20, cl.y - 6, 90, 6), Color("251f3c"))
			draw_rect(Rect2(cl.x + 30, cl.y - 7, 60, 1), Color("3a3058"))
			draw_rect(Rect2(cl.x + 10, cl.y + 10, 120, 3), Color("120f20"))

# ---------------------------------------------------------- foundations
func _draw_foundations() -> void:
	var fp: Array = ["07080e", "0c0f18", "121622", "181d2b", "20263a"]
	if storm_resolved:
		fp = ["15141c", "1f1e28", "2a2833", "35323d", "45404b"]
	for r in [Rect2(-330, 256, 340, 110), Rect2(10, 136, 112, 80), Rect2(122, 6, 84, 72), Rect2(206, -2, 152, 86)]:
		Art.masonry(self, r, fp, 14, 7, int(r.position.x))
		var bx: float = r.position.x + 18.0
		while bx < r.end.x - 6.0:
			draw_rect(Rect2(bx, r.position.y, 6, r.size.y), Color(fp[3]))
			draw_rect(Rect2(bx, r.position.y, 1, r.size.y), Color(fp[4]))
			bx += 44.0
		for k in range(3):
			draw_rect(Rect2(r.position.x, r.end.y - 24.0 + float(k) * 8.0, r.size.x, 8), Color(0, 0, 0, 0.25 + 0.2 * float(k)))
		draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 2), Color(0, 0, 0, 0.45))

# West exterior viaduct bridge visually connecting Dawnspire Summit to DawnspireReturnGate
func _draw_western_viaduct() -> void:
	var fp: Array = ["07080e", "0c0f18", "121622", "181d2b", "20263a"]
	var pier := Rect2(-490, 232, 162, 120)
	Art.masonry(self, pier, fp, 12, 6, 19)
	for ax in [-470, -400]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(ax, 352), Vector2(ax, 274), Vector2(ax + 24, 256), Vector2(ax + 48, 274), Vector2(ax + 48, 352)
		]), Color("080a13"))
	Art.flagstones(self, Rect2(-490, 194, 164, 38), _floor_pal(), 18, 10, 81)
	draw_rect(Rect2(-490, 192, 164, 4), Color(Art.STONE[5]))
	draw_rect(Rect2(-490, 230, 164, 4), Color(Art.STONE[5]))
	for x in range(-484, -328, 24):
		draw_rect(Rect2(x, 186, 6, 8), Color(Art.STONE[4]))
		draw_rect(Rect2(x, 226, 6, 8), Color(Art.STONE[4]))

# ---------------------------------------------------------------- floors
func _draw_floors() -> void:
	var fp := _floor_pal()
	Art.flagstones(self, Rect2(-312, 136, 306, 104), fp, 24, 12, 11)
	Art.flagstones(self, Rect2(-312, 6, 418, 114), fp, 20, 11, 23)
	Art.flagstones(self, Rect2(-162, -182, 352, 176), fp, 22, 12, 37)
	for th in [Rect2(-212, 118, 72, 20), Rect2(-6, -12, 72, 20), Rect2(188, -110, 20, 64)]:
		Art.flagstones(self, th, fp, 12, 6, int(th.position.x) + 5)
		draw_rect(Rect2(th.position.x, th.position.y, th.size.x, 1), Color(Art.GOLD[1]))
		draw_rect(Rect2(th.position.x, th.end.y - 1.0, th.size.x, 1), Color(Art.GOLD[0]))
	var tp: Array = [Art.LIME[1], Art.LIME[2], Art.LIME[3], Art.LIME[4], Art.LIME[5], Art.LIME[6]] if storm_resolved else ["0f121b", "1a1f2c", "242a3a", "2c3346", "394259", "4a556e"]
	Art.flagstones(self, Rect2(206, -144, 136, 126), tp, 16, 10, 51)

func _draw_antechamber_details() -> void:
	var d := storm_resolved
	var cr := Rect2(-198, 136, 44, 104)
	draw_rect(cr, Color("2a1418") if not d else Color("4a2420"))
	draw_rect(Rect2(cr.position.x + 3, cr.position.y, cr.size.x - 6, cr.size.y), Color("4a1f24") if not d else Color("74302a"))
	draw_rect(Rect2(cr.position.x + 3, cr.position.y, 2, cr.size.y), Color(Art.GOLD[1]))
	draw_rect(Rect2(cr.end.x - 5, cr.position.y, 2, cr.size.y), Color(Art.GOLD[1]))
	var yy := 142
	while yy < 236:
		draw_rect(Rect2(-178, yy, 4, 3), Color(Art.GOLD[2]))
		draw_rect(Rect2(-179, yy + 3, 6, 2), Color(Art.GOLD[1]))
		draw_rect(Rect2(-190, yy + 6, 2, 1), Color("6a2c30"))
		draw_rect(Rect2(-164, yy + 6, 2, 1), Color("6a2c30"))
		yy += 14
	draw_rect(Rect2(-312, 204, 114, 18), Color("3a1a1e") if not d else Color("5e2a24"))
	draw_rect(Rect2(-312, 205, 114, 1), Color(Art.GOLD[1]))
	draw_rect(Rect2(-312, 220, 114, 1), Color(Art.GOLD[1]))
	var m := Vector2(-152, 184)
	Art.ellipse(self, m, 24, 13, Color(Art.STONE[2]))
	Art.ellipse_band(self, m, 24, 13, 2, Color(Art.GOLD[1]))
	Art.ellipse_band(self, m, 17, 9, 1, Color(Art.BRONZE[4]))
	for i in range(8):
		var a := float(i) * TAU / 8.0
		var p := Art.ep(m, 20, 11, a)
		draw_rect(Rect2(p.x - 1, p.y - 1, 2, 2), Color(Art.GOLD[3] if i % 2 == 0 else Art.CYAN[2]))
	draw_colored_polygon(PackedVector2Array([m + Vector2(0, -9), m + Vector2(3, 0), m + Vector2(0, 5), m + Vector2(-3, 0)]), Color(Art.GOLD[2]))
	for g in [Vector2(-296, 150), Vector2(-28, 150), Vector2(-296, 228), Vector2(-28, 228)]:
		draw_rect(Rect2(g.x, g.y, 10, 6), Color(Art.STONE[1]))
		for gx in range(3):
			draw_rect(Rect2(g.x + 1 + gx * 3, g.y + 1, 1, 4), Color(Art.STONE[4]))
	for rb in [Vector2(-306, 190), Vector2(-14, 176), Vector2(-120, 236)]:
		draw_rect(Rect2(rb.x, rb.y, 4, 3), Color(Art.STONE[5]))
		draw_rect(Rect2(rb.x + 4, rb.y + 1, 2, 2), Color(Art.STONE[4]))

func _draw_hall_details() -> void:
	for i in range(9):
		var sx: float = -300.0 + float(i) * 44.0
		if absf(sx + 176.0) < 20.0:
			continue
		var sr := Rect2(sx, 96, 30, 18)
		draw_rect(sr, Color(Art.STONE[2]))
		draw_rect(Rect2(sr.position.x + 1, sr.position.y + 1, sr.size.x - 2, sr.size.y - 2), Color(Art.STONE[4]))
		draw_rect(Rect2(sr.position.x + 1, sr.position.y + 1, sr.size.x - 2, 1), Color(Art.STONE[6]))
		for r in range(3):
			Art.inscription(self, sr.position.x + 4, sr.position.y + 4 + float(r) * 4, sr.size.x - 8, i * 5 + r, Color(Art.STONE[1]), Color(Art.STONE[5]))
	draw_rect(Rect2(-268, 56, 330, 22), Color("17203a"))
	draw_rect(Rect2(-268, 58, 330, 18), Color("223055"))
	draw_rect(Rect2(-268, 58, 330, 1), Color(Art.CYAN[1]))
	draw_rect(Rect2(-268, 75, 330, 1), Color(Art.CYAN[1]))
	var gx := -262
	while gx < 58:
		Art.glyph(self, gx, 65, gx / 9, Color(Art.CYAN[1]))
		gx += 9
	draw_rect(Rect2(-188, 6, 24, 112), Color("1b2542"))
	draw_rect(Rect2(-185, 6, 18, 112), Color("223055"))
	draw_rect(Rect2(18, 6, 24, 112), Color("1b2542"))
	draw_rect(Rect2(21, 6, 18, 112), Color("2a3560") if not elena_message_heard else Color("33406e"))
	for i in range(3):
		var alc: Vector2 = [Vector2(-254, 64), Vector2(-176, 30), Vector2(-86, 44)][i]
		var lit: bool = memory_fragments_count > i
		Art.ellipse(self, alc + Vector2(0, 2), 18, 9, Color(Art.STONE[1]))
		Art.ellipse_band(self, alc + Vector2(0, 2), 18, 9, 1, Color(Art.CYAN[2] if not lit else Art.GOLD[2]))
		Art.ellipse_band(self, alc + Vector2(0, 2), 12, 6, 1, Color(Art.CYAN[1] if not lit else Art.GOLD[1]))
		for k in range(6):
			var p := Art.ep(alc + Vector2(0, 2), 15, 7.5, float(k) * TAU / 6.0)
			draw_rect(Rect2(p.x, p.y, 1, 1), Color(Art.CYAN[3]))
	Art.ellipse(self, Vector2(44, 50), 20, 10, Color(Art.STONE[2]))
	Art.ellipse_band(self, Vector2(44, 50), 20, 10, 2, Color(Art.GOLD[2] if elena_message_heard else Art.CYAN[1]))
	draw_rect(Rect2(-40, 50, 32, 10), Color(Art.STONE[3]))
	draw_rect(Rect2(-40, 50, 32, 1), Color(Art.STONE[6]))
	draw_rect(Rect2(-40, 59, 32, 1), Color(Art.STONE[1]))

func _draw_heart_dais() -> void:
	var st := bell_state()
	var lit := network_stabilized or binding_severed
	Art.ellipse(self, DAIS + Vector2(0, 5), 148, 82, Color(Art.STONE[1]))
	Art.ellipse(self, DAIS, 146, 80, Color(Art.STONE[4]))
	Art.ellipse(self, DAIS, 144, 78, Color(Art.STONE[3]))
	Art.ellipse_band(self, DAIS, 146, 80, 1, Color(Art.STONE[6]))
	Art.ellipse_band(self, DAIS, 138, 76, 6, Color(Art.STONE[2]))
	for i in range(48):
		var a := float(i) * TAU / 48.0
		var p := Art.ep(DAIS, 135, 73.5, a)
		Art.glyph(self, p.x - 1, p.y - 2, i, Color(Art.GOLD[1] if i % 4 else Art.STONE[6]))
	Art.ellipse(self, DAIS, 128, 71, Color(Art.STONE[4]))
	Art.ellipse_band(self, DAIS, 128, 71, 2, Color(Art.BRONZE[3] if st < 2 else Art.GOLD[2]))
	Art.ellipse(self, DAIS, 124, 68, Color(Art.STONE[3]))
	for i in range(16):
		var a := float(i) * TAU / 16.0
		var p0 := Art.ep(DAIS, 62, 34, a)
		var p1 := Art.ep(DAIS, 122, 67, a)
		var n := 24
		for k in range(n + 1):
			var q := p0.lerp(p1, float(k) / float(n)).floor()
			draw_rect(Rect2(q.x, q.y, 1, 1), Color(Art.STONE[1]))
	for i in range(8):
		var a := float(i) * TAU / 8.0 + TAU / 16.0
		var p := Art.ep(DAIS, 94, 52, a)
		match i % 3:
			0:
				Art.ellipse(self, p, 4, 3, Color(Art.GOLD[1]))
				Art.ellipse(self, p, 2, 1, Color(Art.GOLD[3]))
				for r in range(4):
					var rp := p + Vector2(cos(float(r) * TAU / 4.0), sin(float(r) * TAU / 4.0) * 0.6) * 6.0
					draw_rect(Rect2(floorf(rp.x), floorf(rp.y), 1, 1), Color(Art.GOLD[2]))
			1:
				Art.ellipse(self, p, 4, 3, Color(Art.STONE[6]))
				Art.ellipse(self, p + Vector2(2, -1), 3, 2, Color(Art.STONE[3]))
			_:
				draw_rect(Rect2(p.x - 3, p.y, 7, 1), Color(Art.CYAN[2]))
				draw_rect(Rect2(p.x, p.y - 2, 1, 5), Color(Art.CYAN[2]))
				draw_rect(Rect2(p.x, p.y, 1, 1), Color(Art.CYAN[4]))
	Art.ellipse_band(self, DAIS, 64, 35, 3, Color(Art.STONE[5]))
	Art.ellipse_band(self, DAIS, 61, 33, 1, Color(Art.BRONZE[4] if st < 2 else Art.GOLD[3]))
	Art.ellipse(self, DAIS, 46, 25, Color(Art.STONE[2]))
	Art.ellipse_band(self, DAIS, 46, 25, 1, Color(Art.STONE[6]))
	for i in range(24):
		var a := float(i) * TAU / 24.0
		var p := Art.ep(DAIS, 40, 21.5, a)
		Art.glyph(self, p.x - 1, p.y - 2, i + 3, Color(Art.AMETHYST[3] if st == 0 else (Art.CYAN[3] if st == 1 else Art.GOLD[3])))
	Art.ellipse(self, DAIS, 26, 14, Color(Art.BRONZE[2] if st >= 2 else Art.BRONZE_DIM[3]))
	Art.ellipse(self, DAIS + Vector2(-2, -1), 22, 11, Color(Art.BRONZE[4] if st >= 2 else Art.BRONZE_DIM[5]))
	Art.ellipse_band(self, DAIS, 26, 14, 1, Color(Art.BRONZE[1]))
	Art.ellipse(self, DAIS + Vector2(4, -6), 36, 9, Color(0, 0, 0, 0.28 if st < 3 else 0.16))
	_channel(CONDUIT_W, DAIS + Vector2(-26, 0), Art.BRIAR, conduit_briarwood)
	_channel(CONDUIT_E, DAIS + Vector2(26, 0), Art.IRON, conduit_ironwatch)
	_channel(CONDUIT_N, DAIS + Vector2(0, -14), Art.FLOOD, conduit_floodmill)
	for pair in [[CONDUIT_W, Art.BRIAR, conduit_briarwood], [CONDUIT_N, Art.FLOOD, conduit_floodmill], [CONDUIT_E, Art.IRON, conduit_ironwatch]]:
		var c: Vector2 = pair[0]
		var pal: Array = pair[1]
		var on: bool = pair[2]
		Art.ellipse(self, c + Vector2(0, 1), 18, 10, Color(Art.STONE[1]))
		Art.ellipse(self, c, 17, 9, Color(Art.STONE[4]))
		Art.ellipse_band(self, c, 17, 9, 2, Color(pal[1] if not on else pal[3]))
		Art.ellipse_band(self, c, 12, 6, 1, Color(Art.BRONZE[3]))
		for k in range(4):
			var p := Art.ep(c, 15, 7.8, float(k) * TAU / 4.0 + TAU / 8.0)
			draw_rect(Rect2(p.x - 1, p.y - 1, 3, 2), Color(Art.GOLD[2] if on else Art.BRONZE[2]))
	for mpos in [Vector2(-60, -142), Vector2(120, -142), Vector2(-62, -30), Vector2(122, -30)]:
		Art.ellipse(self, mpos, 9, 5, Color(Art.STONE[1]))
		Art.ellipse_band(self, mpos, 9, 5, 2, Color(Art.BRONZE[3] if lit else Art.BRONZE_DIM[4]))
		for k in range(8):
			var p := Art.ep(mpos, 10, 5.6, float(k) * TAU / 8.0)
			draw_rect(Rect2(p.x, p.y, 1, 1), Color(Art.BRONZE[5] if lit else Art.BRONZE_DIM[6]))
		draw_rect(Rect2(mpos.x - 1, mpos.y - 1, 2, 2), Color(Art.GOLD[2]))

func _channel(from: Vector2, to: Vector2, pal: Array, on: bool) -> void:
	var horizontal: bool = absf(from.y - to.y) < 1.0
	var r: Rect2
	if horizontal:
		r = Rect2(minf(from.x, to.x), from.y - 4.0, absf(to.x - from.x), 8)
	else:
		r = Rect2(from.x - 4.0, minf(from.y, to.y), 8, absf(to.y - from.y))
	draw_rect(r.grow(1), Color(Art.STONE[6]))
	draw_rect(r, Color(Art.STONE[1]))
	var inner := r.grow(-2)
	draw_rect(inner, Color(pal[0] if not on else pal[2]))
	if horizontal:
		var x := r.position.x + 6.0
		while x < r.end.x - 2.0:
			draw_rect(Rect2(x, r.position.y - 1.0, 2, r.size.y + 2.0), Color(Art.BRONZE[3]))
			draw_rect(Rect2(x, r.position.y - 1.0, 1, 1), Color(Art.BRONZE[6]))
			x += 12.0
		if on:
			draw_rect(Rect2(inner.position.x, inner.position.y + 1.0, inner.size.x, 1), Color(pal[4]))
	else:
		var y := r.position.y + 6.0
		while y < r.end.y - 2.0:
			draw_rect(Rect2(r.position.x - 1.0, y, r.size.x + 2.0, 2), Color(Art.BRONZE[3]))
			draw_rect(Rect2(r.position.x - 1.0, y, 1, 1), Color(Art.BRONZE[6]))
			y += 12.0
		if on:
			draw_rect(Rect2(inner.position.x + 1.0, inner.position.y, 1, inner.size.y), Color(pal[4]))

func _draw_terrace_details() -> void:
	var d := storm_resolved
	var c := Vector2(272, -84)
	Art.ellipse(self, c, 34, 18, Color(Art.LIME[2] if d else Art.STONE[2]))
	Art.ellipse_band(self, c, 34, 18, 2, Color(Art.GOLD[2] if d else Art.STONE[5]))
	Art.ellipse_band(self, c, 24, 12, 1, Color(Art.LIME[5] if d else Art.STONE[4]))
	for i in range(12):
		var p := Art.ep(c, 29, 15, float(i) * TAU / 12.0)
		draw_rect(Rect2(p.x - 1, p.y, 3, 1), Color(Art.GOLD[3] if d else Art.STONE[6]))
	draw_rect(Rect2(206, -80, 32, 8), Color(Art.LIME[3] if d else Art.STONE[3]))
	for k in range(14):
		var mx: float = 210.0 + float(Art.h(k, 4, 9) % 124)
		var my: float = -140.0 + float(Art.h(k, 8, 9) % 116)
		draw_rect(Rect2(mx, my, 3, 1), Color("5d6b46") if d else Color("1f2a2a"))
		draw_rect(Rect2(mx + 1, my + 1, 1, 1), Color("7a8a56") if d else Color("263333"))
	draw_rect(Rect2(280, -80, 36, 6), Color(Art.LIME[2] if d else Art.STONE[2]))
	draw_rect(Rect2(280, -80, 36, 1), Color(Art.LIME[5] if d else Art.STONE[5]))
	if elena_journal_placed:
		for k in range(5):
			draw_rect(Rect2(284 + k * 6, -77, 2, 2), Color("e2c26a") if k % 2 == 0 else Color("c9d8f0"))

# ---------------------------------------------------------------- walls
func _draw_walls() -> void:
	var cap := _stone_pal()
	var face: Array = [Art.STONE[0], Art.STONE[1], Art.STONE[2], Art.STONE[3]]
	var trim: String = Art.GOLD[1]
	var walls := [
		[Rect2(-330, 120, 118, 16), 10.0], [Rect2(-140, 120, 150, 16), 10.0],
		[Rect2(-330, -10, 324, 16), 10.0], [Rect2(66, -10, 56, 16), 10.0], [Rect2(122, -10, 84, 16), 10.0],
		[Rect2(-328, -10, 16, 266), 12.0], [Rect2(-6, 128, 16, 128), 12.0], [Rect2(106, -2, 16, 138), 12.0],
		[Rect2(-178, -196, 16, 196), 12.0], [Rect2(190, -196, 16, 86), 12.0], [Rect2(190, -46, 16, 52), 12.0],
		[Rect2(-330, 240, 340, 16), 10.0],
	]
	walls.sort_custom(func(a, b): return (a[0] as Rect2).end.y < (b[0] as Rect2).end.y)
	for w in walls:
		Art.wall_block(self, w[0], w[1], cap, face, trim, int((w[0] as Rect2).position.x + (w[0] as Rect2).position.y))
	var y := -4
	while y < 244:
		draw_rect(Rect2(-330, y - 12, 20, 6), Color(Art.STONE[5]))
		draw_rect(Rect2(-330, y - 12, 20, 1), Color(Art.STONE[7]))
		draw_rect(Rect2(-311, y - 12, 1, 6), Color(Art.STONE[1]))
		y += 36
	# Carved memorial stelae along Hall's north parapet (names of the forgotten)
	for i in range(11):
		var sx: float = -306.0 + float(i) * 28.0
		if sx > -20.0:
			break
		var top: float = -34.0 + float(Art.h(i, 1, 3) % 5)
		var hgt: float = 4.0 - top
		draw_rect(Rect2(sx, top, 16, hgt), Color(Art.STONE[3]))
		draw_rect(Rect2(sx + 1, top + 1, 14, hgt - 2), Color(Art.STONE[5]))
		draw_rect(Rect2(sx + 1, top + 1, 14, 1), Color(Art.STONE[7]))
		draw_rect(Rect2(sx + 12, top + 2, 3, hgt - 3), Color(Art.STONE[4]))
		draw_colored_polygon(PackedVector2Array([Vector2(sx, top), Vector2(sx + 8, top - 5), Vector2(sx + 16, top)]), Color(Art.STONE[5]))
		for r in range(4):
			Art.inscription(self, sx + 3, top + 6 + float(r) * 5, 8, i * 7 + r, Color(Art.STONE[2]), Color(Art.STONE[6]))
		if i % 3 == 1:
			draw_rect(Rect2(sx + 10, top - 3, 6, 4), Color(Art.STONE[1]))
	var dawn := storm_resolved
	Art.warden_statue(self, Vector2(-318, 134), true, false, dawn)
	Art.warden_statue(self, Vector2(2, 134), false, true, dawn)
	Art.warden_statue(self, Vector2(-318, 4), false, false, dawn)
	Art.warden_statue(self, Vector2(114, 4), true, true, dawn)
	_balustrade(Rect2(198, -160, 160, 16), true)
	_balustrade(Rect2(198, -18, 160, 16), true)
	_balustrade(Rect2(342, -160, 16, 158), false)

func _balustrade(r: Rect2, horizontal: bool) -> void:
	var d := storm_resolved
	var stone: Array = [Art.LIME[1], Art.LIME[2], Art.LIME[3], Art.LIME[4], Art.LIME[5], Art.LIME[6]] if d else [Art.STONE[1], Art.STONE[2], Art.STONE[3], Art.STONE[4], Art.STONE[5], Art.STONE[6]]
	draw_rect(Rect2(r.position.x, r.end.y, r.size.x, 3), Color(0, 0, 0, 0.25))
	if horizontal:
		var rail_y: float = r.end.y - 12.0
		draw_rect(Rect2(r.position.x, r.end.y - 3.0, r.size.x, 3), Color(stone[2]))
		var x := r.position.x + 2.0
		while x < r.end.x - 2.0:
			draw_rect(Rect2(x, rail_y + 3.0, 3, 6), Color(stone[3]))
			draw_rect(Rect2(x, rail_y + 3.0, 1, 6), Color(stone[5]))
			draw_rect(Rect2(x - 1.0, rail_y + 5.0, 5, 2), Color(stone[2]))
			x += 6.0
		draw_rect(Rect2(r.position.x, rail_y, r.size.x, 3), Color(stone[4]))
		draw_rect(Rect2(r.position.x, rail_y, r.size.x, 1), Color(stone[5]))
		var px := r.position.x
		while px <= r.end.x:
			draw_rect(Rect2(px, rail_y - 4.0, 6, 16), Color(stone[3]))
			draw_rect(Rect2(px, rail_y - 4.0, 6, 2), Color(stone[5]))
			draw_rect(Rect2(px + 1.0, rail_y - 6.0, 4, 2), Color(Art.GOLD[2] if d else Art.GOLD[0]))
			px += 40.0
	else:
		draw_rect(Rect2(r.position.x, r.position.y - 6.0, r.size.x, r.size.y), Color(stone[2]))
		draw_rect(Rect2(r.position.x + 2.0, r.position.y - 6.0, r.size.x - 4.0, r.size.y), Color(stone[4]))
		draw_rect(Rect2(r.position.x + 2.0, r.position.y - 6.0, 1, r.size.y), Color(stone[5]))
		var y := r.position.y
		while y < r.end.y:
			draw_rect(Rect2(r.position.x + 1.0, y - 8.0, r.size.x - 2.0, 4), Color(stone[3]))
			draw_rect(Rect2(r.position.x + 1.0, y - 8.0, r.size.x - 2.0, 1), Color(stone[5]))
			y += 20.0

# North cathedral facade calibrated cleanly below HUD & climax letterbox (y = -248..-184)
func _draw_heart_north_wall() -> void:
	var dawn := storm_resolved
	var face := Rect2(-180, -242, 386, 60)
	Art.masonry(self, face, [Art.STONE[0], Art.STONE[1], Art.STONE[2], Art.STONE[3]], 12, 6, 97)
	# Stepped vaulted ribs near upper cornice
	for k in range(3):
		draw_rect(Rect2(face.position.x, face.position.y + float(k) * 4.0, face.size.x, 2), Color(Art.STONE[3 - k]))
	draw_rect(Rect2(-180, -222, 386, 5), Color(Art.STONE[4]))
	draw_rect(Rect2(-180, -222, 386, 1), Color(Art.STONE[6]))
	draw_rect(Rect2(-180, -218, 386, 1), Color(Art.GOLD[1] if not dawn else Art.GOLD[2]))
	var gx := -176
	while gx < 202:
		if gx < -60 or gx > 120:
			Art.glyph(self, gx, -228, gx / 6, Color(Art.GOLD[1] if not dawn else Art.GOLD[3]))
		gx += 6
	# Four pointed Gothic lancet windows
	var glass := Color("2a3a6a") if not dawn else Color("f0b46a")
	var glass_hi := Color("6f8fd0") if not dawn else Color("fff0c0")
	for wx in [-142, -108, 150, 172]:
		Art.lancet(self, wx, -191, 12, 44, glass, glass_hi, Art.STONE[2])
	# Blind Gothic apse arcade behind the Great Bell
	for ax in range(-40, 100, 20):
		draw_colored_polygon(PackedVector2Array([Vector2(ax, -184), Vector2(ax, -212), Vector2(ax + 7, -218), Vector2(ax + 14, -212), Vector2(ax + 14, -184)]), Color(Art.STONE[1]))
		draw_rect(Rect2(ax, -212, 1, 28), Color(Art.STONE[3]))
	# Flanking pilasters
	for p in [-160, -125, -90, 136, 186]:
		Art.pillar(self, Vector2(p, -184), 8, 58, dawn)
	# Skirting base & wall top coping
	draw_rect(Rect2(-180, -188, 386, 6), Color(Art.STONE[3]))
	draw_rect(Rect2(-180, -188, 386, 1), Color(Art.GOLD[1]))
	draw_rect(Rect2(-180, -183, 386, 1), Color(Art.STONE[0]))
	Art.flagstones(self, Rect2(-180, -250, 386, 8), _stone_pal(), 14, 4, 5)
	draw_rect(Rect2(-180, -250, 386, 1), Color(Art.STONE[7]))

func _draw_bell_and_binding() -> void:
	var st := bell_state()
	var dawn := st == 3
	# Twin belfry piers wide of ConduitFloodmill (x = -46 and x = +106)
	Art.pillar(self, Vector2(-46, -184), 16, 56, dawn)
	Art.pillar(self, Vector2(106, -184), 16, 56, dawn)
	# Heavy carved oak & bronze yoke spanning across the piers at y = -244..-234
	var yoke := Rect2(-60, -244, 180, 10)
	draw_rect(yoke.grow(1), Color(Art.BRONZE[0]))
	draw_rect(yoke, Color("3a2716"))
	draw_rect(Rect2(yoke.position.x, yoke.position.y, yoke.size.x, 2), Color("6b4a2a"))
	draw_rect(Rect2(yoke.position.x, yoke.end.y - 2.0, yoke.size.x, 2), Color("24180e"))
	var gx := yoke.position.x + 4.0
	while gx < yoke.end.x - 4.0:
		draw_rect(Rect2(gx, yoke.position.y + 4, 8, 1), Color("2a1c10"))
		gx += 13.0
	for bx in [-56, -38, 10, 50, 96, 114]:
		draw_rect(Rect2(bx, yoke.position.y - 1, 4, 12), Color(Art.BRONZE[3]))
		draw_rect(Rect2(bx, yoke.position.y - 1, 1, 12), Color(Art.BRONZE[6]))
		draw_rect(Rect2(bx + 1, yoke.position.y + 4, 2, 2), Color(Art.BRONZE[1]))
	# Iron hangers into crown
	draw_rect(Rect2(20, -236, 4, 10), Color(Art.STONE[1]))
	draw_rect(Rect2(36, -236, 4, 10), Color(Art.STONE[1]))
	draw_rect(Rect2(20, -236, 1, 10), Color(Art.STONE[5]))
	draw_rect(Rect2(36, -236, 1, 10), Color(Art.STONE[5]))
	# Binding chains prior to severing (routed clear of ConduitFloodmill at (30, -154))
	if not binding_severed:
		for i in range(4):
			Art.chain(self, CHAIN_BELL[i], CHAIN_ANCHORS[i], Color(Art.AMETHYST[1]), Color(Art.AMETHYST[2]), Color(Art.AMETHYST[4] if st == 1 else Art.AMETHYST[3]))
	# Monumental bronze Great Bell (92px wide dome, clear above ConduitFloodmill!)
	Art.great_bell(self, BELL_RIM, BELL_R, BELL_H, st)
	if binding_severed:
		for i in range(4):
			var a: Vector2 = CHAIN_BELL[i]
			var b: Vector2 = CHAIN_ANCHORS[i]
			Art.chain(self, a, a.lerp(b, 0.22) + Vector2(0, 5), Color(Art.STONE[1]), Color(Art.STONE[3]), Color(Art.STONE[6]))
			Art.chain(self, b, b.lerp(a, 0.16), Color(Art.STONE[1]), Color(Art.STONE[3]), Color(Art.STONE[6]))
		for k in range(10):
			var fx_x: float = -100.0 + float(Art.h(k, 2, 41) % 250)
			var fx_y: float = -168.0 + float(Art.h(k, 6, 41) % 140)
			draw_rect(Rect2(fx_x, fx_y, 3, 2), Color(Art.STONE[2]))
			draw_rect(Rect2(fx_x, fx_y, 1, 1), Color(Art.AMETHYST[2]))
	else:
		for i in range(4):
			var a2: Vector2 = CHAIN_BELL[i]
			Art.ellipse(self, a2, 3, 2.5, Color(Art.AMETHYST[1]))
			draw_rect(Rect2(a2.x - 1, a2.y - 1, 2, 2), Color(Art.AMETHYST[4]))

func _draw_heart_seal() -> void:
	var r := Rect2(-6, -14, 72, 10)
	draw_rect(r, Color(0.32, 0.72, 0.90, 0.22))
	var x := r.position.x
	var i := 0
	while x < r.end.x:
		Art.glyph(self, x + 1, r.position.y + 3, i, Color(Art.CYAN[3]))
		x += 6.0
		i += 1
	draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 1), Color(Art.CYAN[3]))
	draw_rect(Rect2(r.position.x, r.end.y - 1.0, r.size.x, 1), Color(Art.CYAN[2]))

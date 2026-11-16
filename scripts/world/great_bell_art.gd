extends RefCounted
## GFX-6 Great Bell Sanctum pixel-art helpers.
## Pure drawing utilities: no gameplay state, no collision, no runtime textures.
## Everything is emitted as crisp integer-aligned rects/polygons so CanvasItem
## command caching keeps static architecture free between state changes.

# Obsidian / blue-gray stone ramp (dark -> light)
const STONE := ["07080e", "0e111b", "151a27", "1d2333", "272e42", "333c54", "434e69", "586682", "75839e"]
# Hammered bronze ramp (deep shadow -> specular)
const BRONZE := ["1f150e", "3a2715", "5a3c1d", "7c5426", "a06d30", "c48c3f", "e0b058", "f6d78a", "fff3c8"]
# Dormant (pre-dawn) bronze: tarnished, cool
const BRONZE_DIM := ["130f0d", "241b15", "36291e", "4a3826", "614a30", "7b603b", "967748", "b39462", "d2b88a"]
const VERDIGRIS := ["2d4a46", "3f6a62", "5b8f80", "7fb5a2"]
const GOLD := ["6b4a1c", "a8782e", "d9a94e", "f2cf78", "fff0c0"]
const CYAN := ["123a48", "1f6378", "3fa3bd", "7fe3f0", "d4fbff"]
const AMETHYST := ["1a0f24", "2e1a40", "4d2a66", "7a4aa3", "b07ee0", "e2c8ff"]
const BRIAR := ["123d2e", "1f6b4c", "2fa874", "62e3a4", "c8ffe2"]
const FLOOD := ["0f2c4a", "1d5688", "3591d0", "72d2ff", "d8f6ff"]
const IRON := ["4a2e0c", "8a5a18", "c98a26", "ffc94a", "fff1c0"]
const LIME := ["3a352e", "554d42", "746a5a", "938672", "b3a58c", "d2c5a8", "ece2c8"]

static func col(hex: String, a: float = 1.0) -> Color:
	var c := Color(hex)
	c.a = a
	return c

static func h(x: int, y: int, s: int = 0) -> int:
	var n: int = x * 374761393 + y * 668265263 + s * 1442695041
	n = (n ^ (n >> 13)) * 1274126177
	n = n ^ (n >> 16)
	return absi(n) % 100000

static func px(c: CanvasItem, x: float, y: float, w: float, hh: float, color: Color) -> void:
	c.draw_rect(Rect2(floorf(x), floorf(y), w, hh), color)

static func clip_px(c: CanvasItem, r: Rect2, clip: Rect2, color: Color) -> void:
	var i := r.intersection(clip)
	if i.size.x > 0.0 and i.size.y > 0.0:
		c.draw_rect(i, color)

## Scanline-filled ellipse (crisp pixel edges, no antialiasing).
static func ellipse(c: CanvasItem, ctr: Vector2, rx: float, ry: float, color: Color) -> void:
	var iy := int(ry)
	for y in range(-iy, iy + 1):
		var t: float = float(y) / maxf(ry, 1.0)
		var w: float = floorf(rx * sqrt(maxf(0.0, 1.0 - t * t)))
		c.draw_rect(Rect2(floorf(ctr.x - w), floorf(ctr.y) + y, w * 2.0 + 1.0, 1), color)

## Elliptical annulus band (outer rx/ry, thickness in pixels horizontally / vertically).
static func ellipse_band(c: CanvasItem, ctr: Vector2, rx: float, ry: float, thick: float, color: Color) -> void:
	var irx: float = rx - thick
	var iry: float = ry - thick * (ry / rx)
	var iy := int(ry)
	for y in range(-iy, iy + 1):
		var t: float = float(y) / ry
		var w: float = floorf(rx * sqrt(maxf(0.0, 1.0 - t * t)))
		var wi: float = -1.0
		if absf(float(y)) < iry:
			var ti: float = float(y) / iry
			wi = floorf(irx * sqrt(maxf(0.0, 1.0 - ti * ti)))
		var yy: float = floorf(ctr.y) + y
		if wi < 0.0:
			c.draw_rect(Rect2(floorf(ctr.x - w), yy, w * 2.0 + 1.0, 1), color)
		else:
			c.draw_rect(Rect2(floorf(ctr.x - w), yy, w - wi, 1), color)
			c.draw_rect(Rect2(floorf(ctr.x + wi) + 1.0, yy, w - wi, 1), color)

## Point on an ellipse at angle a.
static func ep(ctr: Vector2, rx: float, ry: float, a: float) -> Vector2:
	return Vector2(floorf(ctr.x + cos(a) * rx), floorf(ctr.y + sin(a) * ry))

## Tiny carved glyphs (3x4 bitmasks) used for runes and name inscriptions.
const GLYPHS := [0b101111101010, 0b111010010111, 0b010111010101, 0b110101110101, 0b011100100011, 0b111101101111, 0b101010101010, 0b010101111010]
static func glyph(c: CanvasItem, x: float, y: float, idx: int, color: Color) -> void:
	var g: int = GLYPHS[posmod(idx, GLYPHS.size())]
	for i in range(12):
		if (g >> i) & 1:
			c.draw_rect(Rect2(floorf(x) + float(i % 3), floorf(y) + float(i / 3), 1, 1), color)

## Row of carved "names": clusters of 1px strokes with gaps, like engraved text.
static func inscription(c: CanvasItem, x: float, y: float, w: float, seed_value: int, ink: Color, hl: Color) -> void:
	var cx: float = x
	var i := 0
	while cx < x + w - 2.0:
		var word: float = 3.0 + float(h(i, seed_value, 7) % 7)
		word = minf(word, x + w - cx)
		c.draw_rect(Rect2(floorf(cx), floorf(y), word, 1), ink)
		c.draw_rect(Rect2(floorf(cx), floorf(y) + 1.0, word, 1), hl)
		cx += word + 2.0
		i += 1

## Staggered stone slabs with bevelled highlights, worn speckle and cracks.
static func flagstones(c: CanvasItem, r: Rect2, pal: Array, sw: int, sh: int, seed_value: int) -> void:
	c.draw_rect(r, col(pal[0]))
	var row := 0
	var y: float = r.position.y
	while y < r.end.y:
		var off: float = float((row % 2) * (sw / 2))
		var x: float = r.position.x - off
		var colidx := 0
		while x < r.end.x:
			var v: int = h(int(x) + colidx, int(y), seed_value) % 9
			var base: String = pal[2] if v < 4 else (pal[3] if v < 7 else pal[1])
			var slab := Rect2(x + 1.0, y + 1.0, float(sw) - 1.0, float(sh) - 1.0)
			clip_px(c, slab, r, col(base))
			clip_px(c, Rect2(x + 1.0, y + 1.0, float(sw) - 2.0, 1), r, col(pal[4]))
			clip_px(c, Rect2(x + 1.0, y + 1.0, 1, float(sh) - 2.0), r, col(pal[3]))
			clip_px(c, Rect2(x + 1.0, y + float(sh) - 1.0, float(sw) - 1.0, 1), r, col(pal[1]))
			# worn speckles
			for k in range(2):
				var sx: float = x + 2.0 + float(h(int(x), int(y), seed_value + k) % maxi(sw - 4, 1))
				var sy: float = y + 2.0 + float(h(int(y), int(x), seed_value + k + 3) % maxi(sh - 4, 1))
				clip_px(c, Rect2(sx, sy, 1, 1), r, col(pal[1] if k == 0 else pal[4]))
			if v == 8 and sw > 10:
				var cx0: float = x + 3.0 + float(h(int(x), 3, seed_value) % (sw - 6))
				for j in range(sh - 3):
					clip_px(c, Rect2(cx0 + float((j * 3) % 4) - 1.0, y + 2.0 + float(j), 1, 1), r, col(pal[0]))
			x += float(sw)
			colidx += 1
		y += float(sh)
		row += 1

## Small-course ashlar masonry for wall faces.
static func masonry(c: CanvasItem, r: Rect2, pal: Array, bw: int, bh: int, seed_value: int) -> void:
	c.draw_rect(r, col(pal[0]))
	var row := 0
	var y: float = r.position.y
	while y < r.end.y:
		var x: float = r.position.x - float((row % 2) * (bw / 2))
		while x < r.end.x:
			var v: int = h(int(x), int(y), seed_value) % 7
			var base: String = pal[2] if v < 4 else (pal[3] if v < 6 else pal[1])
			clip_px(c, Rect2(x + 1.0, y + 1.0, float(bw) - 1.0, float(bh) - 1.0), r, col(base))
			clip_px(c, Rect2(x + 1.0, y + 1.0, float(bw) - 1.0, 1), r, col(pal[3] if v < 6 else pal[2]))
			x += float(bw)
		y += float(bh)
		row += 1

## A wall seen in 3/4: collision footprint `r`, apparent height `hh`.
static func wall_block(c: CanvasItem, r: Rect2, hh: float, cap_pal: Array, face_pal: Array, trim: String, seed_value: int) -> void:
	var face := Rect2(r.position.x, r.end.y - hh, r.size.x, hh)
	var cap := Rect2(r.position.x, r.position.y - hh, r.size.x, r.size.y)
	# contact shadow on the floor just south of the face
	c.draw_rect(Rect2(r.position.x, r.end.y, r.size.x, 3), Color(0, 0, 0, 0.32))
	c.draw_rect(Rect2(r.position.x, r.end.y + 3, r.size.x, 2), Color(0, 0, 0, 0.16))
	masonry(c, face, face_pal, 10, 5, seed_value)
	c.draw_rect(Rect2(face.position.x, face.end.y - 1.0, face.size.x, 1), col(face_pal[0]))
	if trim != "":
		c.draw_rect(Rect2(face.position.x, face.position.y + 1.0, face.size.x, 1), col(trim))
	flagstones(c, cap, cap_pal, 12, 6, seed_value + 11)
	c.draw_rect(Rect2(cap.position.x, cap.position.y, cap.size.x, 1), col(cap_pal[5] if cap_pal.size() > 5 else cap_pal[4]))
	c.draw_rect(Rect2(cap.position.x, cap.position.y, 1, cap.size.y), col(cap_pal[1]))
	c.draw_rect(Rect2(cap.end.x - 1.0, cap.position.y, 1, cap.size.y), col(cap_pal[0]))

## Carved Gothic pillar standing at `base` (bottom-centre), width w, height hh.
static func pillar(c: CanvasItem, base: Vector2, w: int, hh: int, dawn: bool) -> void:
	var x0: float = base.x - float(w) / 2.0
	var top: float = base.y - float(hh)
	var gold: Array = GOLD
	# plinth
	px(c, x0 - 3, base.y - 7, w + 6, 7, col(STONE[3]))
	px(c, x0 - 3, base.y - 7, w + 6, 1, col(STONE[6]))
	px(c, x0 - 2, base.y - 10, w + 4, 3, col(STONE[4]))
	px(c, x0 - 2, base.y - 10, w + 4, 1, col(gold[1] if not dawn else gold[2]))
	# fluted shaft: per-column ramp, light from upper-left
	for i in range(w):
		var t: float = float(i) / float(maxi(w - 1, 1))
		var idx: int = 6 if t < 0.18 else (5 if t < 0.4 else (4 if t < 0.7 else (3 if t < 0.9 else 2)))
		if i % 3 == 2:
			idx = maxi(idx - 1, 1)
		px(c, x0 + i, top + 8, 1, float(hh) - 18.0, col(STONE[idx]))
	# weathering cracks
	for k in range(3):
		var cy: float = top + 14.0 + float(h(int(base.x), k, 5) % maxi(hh - 30, 1))
		var cx: float = x0 + 1.0 + float(h(int(base.y), k, 9) % maxi(w - 2, 1))
		for j in range(4):
			px(c, cx + float(j % 2), cy + j, 1, 1, col(STONE[1]))
	# capital with gold astragal and abacus
	px(c, x0 - 1, top + 6, w + 2, 2, col(gold[2] if dawn else gold[1]))
	px(c, x0 - 3, top + 2, w + 6, 4, col(STONE[5]))
	px(c, x0 - 3, top + 2, w + 6, 1, col(STONE[7]))
	px(c, x0 - 4, top, w + 8, 2, col(STONE[4]))
	px(c, x0 - 4, top, w + 8, 1, col(STONE[6]))
	px(c, x0 + float(w) / 2.0 - 1.0, top + 3, 2, 2, col(gold[3]))

## Pointed Gothic lancet window: frame stone, glass colour, tracery.
static func lancet(c: CanvasItem, cx: float, base_y: float, w: int, hh: int, glass: Color, glass_hi: Color, frame: String) -> void:
	var half: float = float(w) / 2.0
	var arch_h: float = half * 1.4
	var body_top: float = base_y - float(hh) + arch_h
	# outer frame
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(cx - half - 3, base_y + 2), Vector2(cx - half - 3, body_top), Vector2(cx, base_y - float(hh) - 4),
		Vector2(cx + half + 3, body_top), Vector2(cx + half + 3, base_y + 2)]), col(frame))
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(cx - half, base_y), Vector2(cx - half, body_top), Vector2(cx, base_y - float(hh)),
		Vector2(cx + half, body_top), Vector2(cx + half, base_y)]), glass)
	# leaded mullion + transoms
	px(c, cx - 0.5, base_y - float(hh) + 3.0, 1, float(hh) - 3.0, col(STONE[1]))
	var ty: float = body_top + 4.0
	while ty < base_y - 2.0:
		px(c, cx - half, ty, float(w), 1, col(STONE[1]))
		ty += 9.0
	# light catch on upper-left panes
	px(c, cx - half + 1.0, body_top + 1.0, 2, maxf(float(hh) - arch_h - 4.0, 2.0), glass_hi)
	# tracery rose
	px(c, cx - 2, body_top - 6.0, 4, 4, col(STONE[1]))
	px(c, cx - 1, body_top - 5.0, 2, 2, glass_hi)
	# sill
	px(c, cx - half - 4, base_y + 2, float(w) + 8.0, 2, col(STONE[5]))
	px(c, cx - half - 4, base_y + 2, float(w) + 8.0, 1, col(STONE[7]))

## Chain of alternating links from a to b.
static func chain(c: CanvasItem, a: Vector2, b: Vector2, dark: Color, mid: Color, hi: Color, step: float = 4.0) -> void:
	var d := b - a
	var n: int = maxi(int(d.length() / step), 1)
	for i in range(n + 1):
		var p := (a + d * (float(i) / float(n))).floor()
		if i % 2 == 0:
			c.draw_rect(Rect2(p.x - 2, p.y - 1, 4, 3), dark)
			c.draw_rect(Rect2(p.x - 1, p.y - 1, 2, 1), hi)
			c.draw_rect(Rect2(p.x - 1, p.y, 2, 1), dark.darkened(0.4))
		else:
			c.draw_rect(Rect2(p.x - 1, p.y - 2, 2, 4), mid)
			c.draw_rect(Rect2(p.x - 1, p.y - 2, 1, 1), hi)

## Bell silhouette half-width profile (y measured upward from rim, 0..1 of height).
const BELL_PROFILE := [
	[0.00, 1.00], [0.04, 0.98], [0.10, 0.90], [0.18, 0.80], [0.28, 0.70], [0.40, 0.62],
	[0.55, 0.58], [0.70, 0.58], [0.80, 0.56], [0.88, 0.50], [0.94, 0.40], [0.98, 0.26], [1.00, 0.0]]

static func bell_half_width(t_up: float) -> float:
	for i in range(BELL_PROFILE.size() - 1):
		var a: Array = BELL_PROFILE[i]
		var b: Array = BELL_PROFILE[i + 1]
		if t_up <= b[0]:
			var k: float = (t_up - a[0]) / maxf(b[0] - a[0], 0.0001)
			return lerpf(a[1], b[1], k)
	return 0.0

## The Great Bell. `rim` is the centre of the rim ellipse, R the rim half-width,
## H the body height. state: 0 dormant, 1 resonating (stabilized), 2 freed (severed), 3 dawn.
static func great_bell(c: CanvasItem, rim: Vector2, R: int, H: int, state: int) -> void:
	var pal: Array = BRONZE if state >= 2 else BRONZE_DIM
	var ry: float = floorf(float(R) * 0.16)
	# --- inner mouth (dark interior seen from above-front)
	ellipse(c, rim, float(R) - 3.0, ry, col(pal[0]))
	# clapper hanging inside the mouth
	var cl_col: String = pal[3]
	px(c, rim.x - 2, rim.y - ry - 6.0, 4, ry + 10.0, col(pal[1]))
	ellipse(c, Vector2(rim.x, rim.y + 6.0), 6.0, 5.0, col(pal[2]))
	ellipse(c, Vector2(rim.x - 1.0, rim.y + 5.0), 4.0, 3.0, col(cl_col))
	px(c, rim.x - 3, rim.y + 3.0, 2, 2, col(pal[6]))
	# --- body: per-column shading with ordered dithering between ramp steps
	var top: float = rim.y - float(H)
	for ix in range(-R, R + 1):
		var ax: float = absf(float(ix)) / float(R)
		# find top of silhouette for this column
		var col_top: float = rim.y
		for yy in range(H, -1, -1):
			if bell_half_width(float(yy) / float(H)) >= ax:
				col_top = rim.y - float(yy)
				break
		var lip: float = floorf(ry * sqrt(maxf(0.0, 1.0 - ax * ax)))
		var col_bot: float = rim.y + lip
		if col_bot <= col_top:
			continue
		# light from upper-left: map x in [-R,R] to ramp position
		var t: float = (float(ix) / float(R) + 1.0) * 0.5
		var shade: float
		if t < 0.08:
			shade = 3.0
		elif t < 0.30:
			shade = lerpf(5.0, 7.4, (t - 0.08) / 0.22)
		elif t < 0.42:
			shade = lerpf(7.4, 5.2, (t - 0.30) / 0.12)
		elif t < 0.80:
			shade = lerpf(5.2, 2.6, (t - 0.42) / 0.38)
		elif t < 0.93:
			shade = lerpf(2.6, 1.6, (t - 0.80) / 0.13)
		else:
			shade = 3.4 # reflected rim light on the shadow edge
		var lo: int = clampi(int(floorf(shade)), 0, 8)
		var hi: int = clampi(lo + 1, 0, 8)
		var frac: float = shade - floorf(shade)
		c.draw_rect(Rect2(rim.x + ix, col_top, 1, col_bot - col_top), col(pal[lo]))
		if frac > 0.25:
			# checker dither toward the next ramp step
			var yy0: int = int(col_top) + (absi(ix) % 2)
			var stride: int = 2 if frac > 0.6 else 4
			var yy := yy0
			while yy < int(col_bot):
				c.draw_rect(Rect2(rim.x + ix, yy, 1, 1), col(pal[hi]))
				yy += stride
	# --- sound-bow lip: thick rolled rim catching light
	for ix in range(-R, R + 1):
		var ax: float = absf(float(ix)) / float(R)
		var lip: float = floorf(ry * sqrt(maxf(0.0, 1.0 - ax * ax)))
		var t2: float = (float(ix) / float(R) + 1.0) * 0.5
		var li: int = 7 if t2 < 0.35 else (5 if t2 < 0.7 else 3)
		c.draw_rect(Rect2(rim.x + ix, rim.y + lip - 2.0, 1, 2), col(pal[li]))
		c.draw_rect(Rect2(rim.x + ix, rim.y + lip, 1, 1), col(pal[1]))
	# --- engraved bands that wrap the curved body (convex toward viewer)
	var band_cols: Array
	match state:
		0: band_cols = [AMETHYST[3], AMETHYST[2]]
		1: band_cols = [CYAN[3], CYAN[2]]
		_: band_cols = [GOLD[3], GOLD[2]]
	for band in [[0.16, 3, true], [0.34, 2, false], [0.74, 2, false], [0.86, 3, true]]:
		var by_t: float = band[0]
		var bh: int = band[1]
		var hw: float = floorf(bell_half_width(by_t) * float(R))
		var base_y: float = rim.y - floorf(by_t * float(H))
		for ix in range(int(-hw), int(hw) + 1):
			var ax2: float = absf(float(ix)) / maxf(hw, 1.0)
			var bulge: float = floorf(3.0 * sqrt(maxf(0.0, 1.0 - ax2 * ax2)))
			var y0: float = base_y + bulge
			c.draw_rect(Rect2(rim.x + ix, y0, 1, 1), col(pal[1]))
			c.draw_rect(Rect2(rim.x + ix, y0 + 1, 1, float(bh) - 1.0), col(pal[6] if ix < 0 else pal[4]))
			c.draw_rect(Rect2(rim.x + ix, y0 + float(bh), 1, 1), col(pal[2]))
		if band[2]:
			# glyph frieze on the broad bands
			var gx: float = -hw + 5.0
			var gi := 0
			while gx < hw - 6.0:
				var ax3: float = absf(gx) / maxf(hw, 1.0)
				var bulge2: float = floorf(3.0 * sqrt(maxf(0.0, 1.0 - ax3 * ax3)))
				glyph(c, rim.x + gx, base_y + bulge2 - 5.0, gi + int(by_t * 10.0), col(band_cols[0] if gi % 3 != 1 else band_cols[1]))
				gx += 7.0
				gi += 1
	# --- surface wear: verdigris blooms and scratches (deterministic)
	for k in range(26):
		var wx: int = -R + 6 + h(k, 1, 77) % (2 * R - 12)
		var wy_t: float = 0.08 + float(h(k, 2, 77) % 80) / 100.0
		var hw2: float = bell_half_width(wy_t) * float(R)
		if absf(float(wx)) > hw2 - 3.0:
			continue
		var wy: float = rim.y - floorf(wy_t * float(H))
		var vg: String = VERDIGRIS[1] if k % 3 else VERDIGRIS[2]
		if state >= 2:
			vg = VERDIGRIS[2] if k % 4 else VERDIGRIS[3]
		if k % 2 == 0:
			c.draw_rect(Rect2(rim.x + wx, wy, 2, 1), col(vg, 0.85))
			c.draw_rect(Rect2(rim.x + wx + 1, wy + 1, 1, 2), col(vg, 0.7))
		else:
			c.draw_rect(Rect2(rim.x + wx, wy, 3, 1), col(pal[2]))
	# --- crown: shoulder plate, argent canons, iron shackle
	var shoulder: float = floorf(bell_half_width(0.98) * float(R))
	px(c, rim.x - shoulder - 2.0, top - 2, shoulder * 2.0 + 5.0, 4, col(pal[3]))
	px(c, rim.x - shoulder - 2.0, top - 2, shoulder * 2.0 + 5.0, 1, col(pal[6]))
	for cx in [-10, -4, 3, 9]:
		px(c, rim.x + cx - 2, top - 12, 5, 10, col(pal[2]))
		px(c, rim.x + cx - 1, top - 12, 2, 9, col(pal[5] if cx < 0 else pal[4]))
		px(c, rim.x + cx - 2, top - 13, 5, 2, col(pal[6]))
	px(c, rim.x - 13, top - 16, 27, 4, col(STONE[1]))
	px(c, rim.x - 13, top - 16, 27, 1, col(STONE[5]))
	# --- specular glints
	if state >= 1:
		var gl: String = pal[8]
		px(c, rim.x - floorf(float(R) * 0.42), rim.y - floorf(float(H) * 0.52), 2, 6, col(gl))
		px(c, rim.x - floorf(float(R) * 0.46), rim.y - floorf(float(H) * 0.22), 1, 4, col(gl))
		px(c, rim.x - floorf(float(R) * 0.62), rim.y - 4.0, 3, 1, col(gl))

## Weathered Warden statue (optionally broken), standing at base.
static func warden_statue(c: CanvasItem, base: Vector2, broken: bool, flip: bool, dawn: bool) -> void:
	var s := -1.0 if flip else 1.0
	# pedestal
	px(c, base.x - 9, base.y - 8, 18, 8, col(STONE[3]))
	px(c, base.x - 9, base.y - 8, 18, 1, col(STONE[6]))
	px(c, base.x - 7, base.y - 5, 14, 1, col(GOLD[2] if dawn else GOLD[1]))
	# robed body (stepped silhouette)
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(base.x - 7, base.y - 8), Vector2(base.x - 5, base.y - 30), Vector2(base.x + 5, base.y - 30), Vector2(base.x + 7, base.y - 8)]), col(STONE[5]))
	px(c, base.x - 5, base.y - 30, 3, 22, col(STONE[6]))
	px(c, base.x + 3, base.y - 28, 3, 20, col(STONE[3]))
	for fy in [-24, -18, -13]:
		px(c, base.x - 3, base.y + fy, 1, 4, col(STONE[3]))
	# arms holding a small votive bell
	px(c, base.x - 6 * s, base.y - 26, 4, 3, col(STONE[6]))
	px(c, base.x - 1, base.y - 25, 3, 4, col(BRONZE[4] if dawn else BRONZE_DIM[5]))
	px(c, base.x - 1, base.y - 25, 1, 3, col(BRONZE[6] if dawn else BRONZE_DIM[7]))
	if broken:
		# snapped shoulder and missing head; rubble at the foot
		c.draw_colored_polygon(PackedVector2Array([Vector2(base.x - 5, base.y - 30), Vector2(base.x - 1, base.y - 33), Vector2(base.x + 2, base.y - 30)]), col(STONE[6]))
		px(c, base.x + 8 * s, base.y - 3, 4, 3, col(STONE[4]))
		px(c, base.x + 12 * s, base.y - 2, 2, 2, col(STONE[5]))
	else:
		# hooded head
		px(c, base.x - 3, base.y - 37, 6, 7, col(STONE[5]))
		px(c, base.x - 3, base.y - 37, 2, 7, col(STONE[7]))
		px(c, base.x - 1, base.y - 34, 3, 2, col(STONE[2]))

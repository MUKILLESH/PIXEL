extends StaticBody2D
## Procedural 2.5D pixel-art sanctum architecture for Chapter 5 (Great Bell Sanctum):
## sanctum_arch, great_bell_monolith, warden_stele, and dawn_memorial.

const Art = preload("res://scripts/world/great_bell_art.gd")

@export var kind: String = "sanctum_arch"

var binding_severed: bool = false
var network_stabilized: bool = false
var storm_resolved: bool = false
var elena_journal_placed: bool = false

func _ready() -> void:
	match kind:
		"sanctum_arch":
			# Twin pillars flanking wide doorway so Aren walks smoothly between them
			_add_box(Vector2(-38, -4), Vector2(14, 14))
			_add_box(Vector2(38, -4), Vector2(14, 14))
		"great_bell_monolith":
			# Small northern anchor pedestal so central altar (30, -78) and northern conduit (30, -154) stay clear
			_add_box(Vector2(0, -4), Vector2(22, 12))
		"warden_stele":
			_add_box(Vector2(0, -4), Vector2(20, 12))
		"dawn_memorial":
			_add_box(Vector2(0, -4), Vector2(26, 14))

func _add_box(pos: Vector2, sz: Vector2) -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = sz
	col.shape = rect
	col.position = pos
	add_child(col)

func _draw() -> void:
	match kind:
		"sanctum_arch":
			_draw_sanctum_arch()
		"great_bell_monolith":
			_draw_great_bell_monolith()
		"warden_stele":
			_draw_warden_stele()
		"dawn_memorial":
			_draw_dawn_memorial()

func _draw_sanctum_arch() -> void:
	var dawn := storm_resolved
	var trim: String = Art.GOLD[2] if dawn else Art.GOLD[1]
	# Twin fluted Gothic piers centered on the (-38, -4) and (+38, -4) collision plinths
	Art.pillar(self, Vector2(-38, 2), 14, 46, dawn)
	Art.pillar(self, Vector2(38, 2), 14, 46, dawn)
	# Compact overhead Gothic architrave spanning x = -48..+48 (clears GreatBellBinding at HeartArch!)
	Art.px(self, -48, -54, 96, 10, Color(Art.STONE[3]))
	Art.px(self, -46, -56, 92, 3, Color(Art.STONE[6]))
	Art.px(self, -48, -44, 96, 2, Color(Art.STONE[1]))
	Art.px(self, -44, -50, 88, 2, Color(trim))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-28, -54), Vector2(0, -63), Vector2(28, -54)
	]), Color(Art.STONE[4]))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-20, -54), Vector2(0, -60), Vector2(20, -54)
	]), Color(Art.STONE[2]))
	for gi in range(-3, 4):
		if gi == 0:
			continue
		Art.glyph(self, float(gi) * 9.0 - 1.0, -48.0, gi + 4, Color(trim))
	Art.px(self, -5, -56, 10, 9, Color(Art.STONE[5]))
	Art.px(self, -4, -55, 8, 7, Color(Art.GOLD[3] if dawn else Art.CYAN[2]))
	Art.px(self, -2, -53, 4, 4, Color(Art.GOLD[4] if dawn else Art.CYAN[4]))
	for sx in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(29.0 * sx, -44.0), Vector2(29.0 * sx, -35.0), Vector2(21.0 * sx, -44.0)
		]), Color(Art.STONE[4]))

func _draw_great_bell_monolith() -> void:
	# Compact carved Harmonic Anchor Capstan over collision plinth (30, -104), 22x12.
	# Monumental suspended Great Bell renders right above in Landscape so ConduitFloodmill at (30, -154) remains 100% clear.
	var dawn := storm_resolved
	var pal: Array = Art.BRONZE if (binding_severed or dawn) else Art.BRONZE_DIM
	var core_c: Color = Color(Art.GOLD[3]) if binding_severed else (Color(Art.CYAN[3]) if network_stabilized else Color(Art.AMETHYST[4]))
	# Base shadow & stepped obsidian plinth
	Art.ellipse(self, Vector2(0, 1), 16.0, 7.0, Color(0, 0, 0, 0.35))
	Art.px(self, -13, -10, 26, 12, Color(Art.STONE[2]))
	Art.px(self, -12, -9, 24, 9, Color(Art.STONE[4]))
	Art.px(self, -13, -10, 26, 1, Color(Art.STONE[6]))
	Art.px(self, -10, -22, 20, 12, Color(Art.STONE[3]))
	Art.px(self, -10, -22, 20, 2, Color(pal[5]))
	Art.px(self, -8, -19, 16, 7, Color(pal[2]))
	# Twin bronze chain-mooring lugs matching CHAIN_ANCHORS at (-10, -4) and (+10, -4) relative to (30, -104)
	for lx in [-11, 8]:
		Art.px(self, lx, -14, 3, 7, Color(pal[4]))
		Art.px(self, lx, -14, 1, 7, Color(pal[7]))
		Art.px(self, lx + 1, -12, 1, 2, Color(Art.STONE[0]))
	# Center harmonic conduit node & rune inlay
	Art.px(self, -3, -26, 6, 4, Color(pal[4]))
	Art.px(self, -2, -25, 4, 3, core_c)
	Art.px(self, -1, -24, 2, 1, Color("ffffff"))
	Art.px(self, -2, -16, 4, 5, core_c)
	Art.glyph(self, -5.0, -7.0, 2, Color(Art.GOLD[2] if dawn else Art.CYAN[2]))
	Art.glyph(self, 3.0, -7.0, 5, Color(Art.GOLD[2] if dawn else Art.CYAN[2]))

func _draw_warden_stele() -> void:
	var dawn := storm_resolved
	# Contact shadow & stepped limestone-obsidian base
	Art.ellipse(self, Vector2(0, 1), 15.0, 6.0, Color(0, 0, 0, 0.35))
	Art.px(self, -12, -8, 24, 9, Color(Art.STONE[2]))
	Art.px(self, -11, -9, 22, 2, Color(Art.STONE[6]))
	# Carved monolith body
	Art.px(self, -9, -40, 18, 32, Color(Art.STONE[4]))
	Art.px(self, -9, -40, 4, 32, Color(Art.STONE[5]))
	Art.px(self, 6, -40, 3, 32, Color(Art.STONE[2]))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, -40), Vector2(0, -47), Vector2(10, -40)
	]), Color(Art.STONE[5]))
	# Gold crest & incised chronicle lines
	Art.px(self, -2, -43, 4, 3, Color(Art.GOLD[3] if dawn else Art.GOLD[1]))
	for ry in [-35, -31, -27, -23, -19, -15]:
		Art.inscription(self, -6, ry, 12, absi(ry), Color(Art.GOLD[2] if ry == -27 else Art.STONE[1]), Color(Art.CYAN[2] if ry == -31 else Art.STONE[6]))

func _draw_dawn_memorial() -> void:
	Art.ellipse(self, Vector2(0, 1), 18.0, 7.0, Color(0, 0, 0, 0.30))
	Art.px(self, -15, -6, 30, 6, Color(Art.LIME[2]))
	Art.px(self, -15, -6, 30, 1, Color(Art.LIME[5]))
	Art.px(self, -10, -34, 20, 28, Color(Art.LIME[4]))
	Art.px(self, -10, -34, 4, 28, Color(Art.LIME[5]))
	Art.px(self, 5, -34, 5, 28, Color(Art.LIME[3]))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -34), Vector2(0, -43), Vector2(12, -34)
	]), Color(Art.LIME[5]))
	for ry in [-26, -22, -18, -14]:
		Art.inscription(self, -7, ry, 13, absi(ry) + 3, Color("594c38"), Color(Art.GOLD[2]))
	Art.px(self, -2, -32, 4, 3, Color(Art.GOLD[3]))
	if elena_journal_placed:
		Art.px(self, 7, -8, 9, 6, Color("5c351e"))
		Art.px(self, 8, -7, 7, 4, Color("7d492a"))
		Art.px(self, 10, -7, 3, 2, Color(Art.GOLD[3]))

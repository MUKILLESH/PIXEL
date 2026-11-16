extends StaticBody2D
## Procedural 2.5D pixel-art sanctum architecture for Chapter 5 (Great Bell Sanctum):
## sanctum_arch, great_bell_monolith, warden_stele, and dawn_memorial.

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
	draw_rect(Rect2(-46, -48, 16, 48), Color("364056"))
	draw_rect(Rect2(-44, -46, 5, 44), Color("4c5975"))
	draw_rect(Rect2(30, -48, 16, 48), Color("293142"))
	draw_rect(Rect2(41, -46, 5, 44), Color("1e2433"))
	draw_rect(Rect2(-50, -56, 100, 12), Color("485570"))
	draw_rect(Rect2(-48, -58, 96, 3), Color("677899"))
	draw_rect(Rect2(-24, -52, 48, 4), Color("d9a94e"))
	draw_rect(Rect2(-4, -55, 8, 6), Color("8be6f0"))

func _draw_great_bell_monolith() -> void:
	# Monumental obsidian-and-bronze belfry frame supporting the Great Bell
	draw_rect(Rect2(-34, -80, 10, 62), Color("293142"))
	draw_rect(Rect2(24, -80, 10, 62), Color("212838"))
	draw_rect(Rect2(-32, -78, 3, 58), Color("475470"))
	draw_rect(Rect2(24, -78, 3, 58), Color("3a455e"))
	# Massive timber-and-bronze overhead yoke beam & crest
	draw_rect(Rect2(-38, -86, 76, 10), Color("3b3026"))
	draw_rect(Rect2(-36, -88, 72, 3), Color("6b543b"))
	draw_rect(Rect2(-12, -94, 24, 6), Color("d9a94e") if storm_resolved else Color("6e6254"))
	draw_rect(Rect2(-38, -86, 8, 10), Color("a67c3c"))
	draw_rect(Rect2(30, -86, 8, 10), Color("a67c3c"))
	# Heavy suspension bronze shaft
	draw_rect(Rect2(-5, -78, 10, 14), Color("594836"))

	# Colossal hammered-bronze Great Bell dome & flared rim
	var dark_bronze: Color = Color("8c6629") if storm_resolved else Color("3d332c")
	var mid_bronze: Color = Color("b88b3d") if storm_resolved else Color("54463b")
	var high_bronze: Color = Color("e3b95c") if storm_resolved else Color("756250")
	var core_glow: Color = Color("ffe68a") if storm_resolved else Color("6b564a")
	draw_colored_polygon(PackedVector2Array([
		Vector2(-16, -66), Vector2(16, -66), Vector2(28, -22), Vector2(-28, -22)
	]), dark_bronze)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -64), Vector2(10, -64), Vector2(20, -24), Vector2(-20, -24)
	]), mid_bronze)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-9, -62), Vector2(-1, -62), Vector2(-3, -26), Vector2(-14, -26)
	]), high_bronze)
	# Engraved horizontal rune waist bands
	draw_rect(Rect2(-22, -46, 44, 3), Color("70d4e0") if network_stabilized or storm_resolved else Color("6e558a"))
	draw_rect(Rect2(-25, -34, 50, 2), Color("fae08c") if storm_resolved else Color("453732"))
	# Flared lower lip & bronze tongue clapper
	draw_rect(Rect2(-32, -23, 64, 7), high_bronze)
	draw_rect(Rect2(-32, -19, 64, 3), dark_bronze)
	draw_rect(Rect2(-5, -16, 10, 7), core_glow)
	draw_rect(Rect2(-3, -15, 6, 4), Color("ffffff") if storm_resolved else Color("332924"))

	# Monumental energy aura vs dark binding chains
	if network_stabilized or storm_resolved:
		draw_line(Vector2(0, -140), Vector2(0, -94), Color(0.98, 0.90, 0.56, 0.35), 8.0)
		draw_arc(Vector2(0, -44), 36.0, 0.0, TAU, 32, Color(0.98, 0.88, 0.52, 0.58), 2.0)
		draw_arc(Vector2(0, -44), 46.0, 0.0, TAU, 36, Color(0.55, 0.90, 0.98, 0.42), 1.5)
	if not binding_severed:
		for pair in [
			[Vector2(-18, -56), Vector2(-34, -10)],
			[Vector2(18, -56), Vector2(34, -10)],
			[Vector2(-26, -32), Vector2(-22, -4)],
			[Vector2(26, -32), Vector2(22, -4)],
		]:
			draw_line(pair[0], pair[1], Color("20162e"), 3.5)
			draw_line(pair[0], pair[1], Color("8058ad"), 1.2)
			draw_circle(pair[1], 3.0, Color("a478db"))

func _draw_warden_stele() -> void:
	draw_rect(Rect2(-11, -30, 22, 30), Color("364054"))
	draw_rect(Rect2(-8, -26, 16, 20), Color("4e5c78"))
	draw_line(Vector2(-5, -22), Vector2(5, -22), Color("d9a94e"), 1.0)
	draw_line(Vector2(-5, -17), Vector2(5, -17), Color("8be6f0"), 1.0)
	draw_line(Vector2(-5, -12), Vector2(5, -12), Color("d9a94e"), 1.0)

func _draw_dawn_memorial() -> void:
	# Stepped limestone base
	draw_rect(Rect2(-15, -6, 30, 6), Color("6e675c"))
	draw_rect(Rect2(-10, -32, 20, 26), Color("a69b88"))
	draw_rect(Rect2(5, -32, 5, 26), Color("7d7466"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -32), Vector2(0, -40), Vector2(12, -32)
	]), Color("c4b8a1"))
	# Engraved golden memorial lines
	for ry in [-25, -21, -17, -13]:
		draw_line(Vector2(-6, ry), Vector2(4, ry), Color("594c38"), 1.0)
	draw_rect(Rect2(-2, -31, 4, 3), Color("f2ca6b"))
	# Elena's weathered leather journal placed gently beside the base in epilogue
	if elena_journal_placed:
		draw_rect(Rect2(7, -8, 9, 6), Color("5c351e"))
		draw_rect(Rect2(8, -7, 7, 4), Color("7d492a"))
		draw_rect(Rect2(10, -7, 3, 2), Color("e6b85c"))

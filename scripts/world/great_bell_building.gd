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
	draw_rect(Rect2(-44, -44, 14, 44), Color("364056"))
	draw_rect(Rect2(30, -44, 14, 44), Color("293142"))
	draw_rect(Rect2(-48, -52, 96, 10), Color("485570"))
	draw_rect(Rect2(-20, -49, 40, 4), Color("d9a94e"))

func _draw_great_bell_monolith() -> void:
	# Colossal Great Bell suspended from ancient bronze yoke above the Heart Chamber
	draw_rect(Rect2(-26, -64, 52, 8), Color("3b332b"))
	draw_rect(Rect2(-22, -60, 8, 20), Color("4f4338"))
	draw_rect(Rect2(14, -60, 8, 20), Color("4f4338"))
	# Bell dome & flared rim
	var rim_col: Color = Color("c99a49") if storm_resolved else Color("6e5c48")
	var body_col: Color = Color("a87e38") if storm_resolved else Color("4a3f38")
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, -52), Vector2(12, -52), Vector2(22, -20), Vector2(-22, -20)
	]), body_col)
	draw_rect(Rect2(-24, -22, 48, 6), rim_col)
	draw_rect(Rect2(-4, -16, 8, 6), Color("ffd978") if storm_resolved else Color("5c4a3e"))
	# Subtle harmonic halo or dark curse chains
	if network_stabilized or storm_resolved:
		draw_arc(Vector2(0, -34), 28.0, 0.0, TAU, 24, Color(0.98, 0.88, 0.52, 0.55), 1.5)
	if not binding_severed:
		draw_line(Vector2(-18, -36), Vector2(-24, -6), Color("261d33"), 3.0)
		draw_line(Vector2(18, -36), Vector2(24, -6), Color("261d33"), 3.0)

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

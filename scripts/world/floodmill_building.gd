extends StaticBody2D
## Original 2.5D isometric pixel-art architecture for Floodmill: The Drowned Village.
## Builds weathered medieval cottages, ruined homesteads, the Old Watermill with a rotating wheel,
## the Canal Lockhouse, and a cutaway Forgotten Archive hall with per-bay Y-sorting.

@export_enum("MillerCottage", "RuinedHomestead", "CanalLockhouse", "OldWatermill", "ForgottenArchive") var kind: int = 0

var watermill_active: bool = false
var wheel_angle: float = 0.0

const STONE_LIGHT := Color("828a86")
const STONE_MID := Color("636b68")
const STONE_DARK := Color("434a48")
const STONE_MOSS := Color("3b5c43")
const TIMBER := Color("3d291b")
const TIMBER_LIGHT := Color("5e4029")
const TIMBER_ROT := Color("4a3828")
const PLASTER := Color("bfb49b")
const PLASTER_DAMP := Color("94917f")
const SHINGLE := Color("5e3e29")
const SHINGLE_DARK := Color("452c1c")
const SLATE := Color("384352")
const SLATE_LIGHT := Color("4c5b6e")
const WATER_SHEEN := Color(0.18, 0.42, 0.48, 0.55)
const LANTERN_GLOW := Color("ffbe52")
const GOLD := Color("e6b85c")

class ArchiveBayVisual extends Node2D:
	var pts: Array = []
	var bay_kind: String = "nw"

	func _draw() -> void:
		if bay_kind == "nw":
			# Northwest bookshelf bay (u0..u1, v=68, facing SE toward camera)
			var u0: float = pts[0]
			var u1: float = pts[1]
			var v: float = 68.0
			_poly([_p(u0, v, 0), _p(u1, v, 0), _p(u1, v, 58), _p(u0, v, 58)], Color("535b59"))
			_poly([_p(u0, v, 0), _p(u1, v, 0), _p(u1, v, 10), _p(u0, v, 10)], Color("3e4544"))
			# Tall oak bookcase recessed against wall
			_poly([_p(u0 + 2, v - 1, 6), _p(u1 - 2, v - 1, 6), _p(u1 - 2, v - 1, 46), _p(u0 + 2, v - 1, 46)], Color("3d291b"))
			_poly([_p(u0 + 3, v - 2, 8), _p(u1 - 3, v - 2, 8), _p(u1 - 3, v - 2, 44), _p(u0 + 3, v - 2, 44)], Color("221812"))
			for sh in [18.0, 29.0, 40.0]:
				draw_line(_p(u0 + 3, v - 2, sh), _p(u1 - 3, v - 2, sh), Color("6b492b"), 2.0)
				for bx in range(int(u0) + 4, int(u1) - 4, 4):
					var col := Color("9e4b3c") if (bx % 8 == 0) else (Color("487368") if (bx % 12 == 0) else Color("b59257"))
					draw_line(_p(bx, v - 2, sh - 8), _p(bx, v - 2, sh - 1), col, 2.0)
			# Upper stone parapet coping
			_poly([_p(u0 - 1, v - 2, 56), _p(u1 + 1, v - 2, 56), _p(u1 + 1, v + 4, 62), _p(u0 - 1, v + 4, 62)], Color("6d7572"))
			# Warm wall candle sconce
			var mid_u: float = (u0 + u1) * 0.5
			draw_rect(Rect2(_p(mid_u, v - 3, 49) - Vector2(2, 2), Vector2(4, 4)), Color("ffca57"))
		elif bay_kind == "ne":
			# Northeast bookshelf bay (u=68, v0..v1, facing SW toward camera)
			var v0: float = pts[0]
			var v1: float = pts[1]
			var u: float = 68.0
			_poly([_p(u, v0, 0), _p(u, v1, 0), _p(u, v1, 58), _p(u, v0, 58)], Color("454c4b"))
			_poly([_p(u, v0, 0), _p(u, v1, 0), _p(u, v1, 10), _p(u, v0, 10)], Color("323837"))
			_poly([_p(u - 1, v0 + 2, 6), _p(u - 1, v1 - 2, 6), _p(u - 1, v1 - 2, 46), _p(u - 1, v0 + 2, 46)], Color("3d291b"))
			_poly([_p(u - 2, v0 + 3, 8), _p(u - 2, v1 - 3, 8), _p(u - 2, v1 - 3, 44), _p(u - 2, v0 + 3, 44)], Color("1d140f"))
			for sh in [18.0, 29.0, 40.0]:
				draw_line(_p(u - 2, v0 + 3, sh), _p(u - 2, v1 - 3, sh), Color("6b492b"), 2.0)
				for bv in range(int(v0) + 4, int(v1) - 4, 4):
					var col := Color("4f7a80") if (bv % 8 == 0) else (Color("8a5540") if (bv % 12 == 0) else Color("bda168"))
					draw_line(_p(u - 2, bv, sh - 8), _p(u - 2, bv, sh - 1), col, 2.0)
			_poly([_p(u - 2, v0 - 1, 56), _p(u - 2, v1 + 1, 56), _p(u + 4, v1 + 1, 62), _p(u + 4, v0 - 1, 62)], Color("5a6260"))
			var mid_v: float = (v0 + v1) * 0.5
			draw_rect(Rect2(_p(u - 3, mid_v, 49) - Vector2(2, 2), Vector2(4, 4)), Color("ffca57"))
		elif bay_kind == "pillar":
			# Carved stone gallery column & candle pedestal
			draw_rect(Rect2(-6, -4, 12, 7), Color("434a48"))
			draw_rect(Rect2(-4, -38, 8, 36), Color("636b68"))
			draw_rect(Rect2(1, -38, 3, 36), Color("434a48"))
			draw_rect(Rect2(-6, -41, 12, 5), Color("828a86"))
			draw_rect(Rect2(-2, -45, 4, 4), Color("ffbe52"))
		elif bay_kind == "mezzanine":
			# Upper timber mezzanine balcony railing along NW back wall
			for bu in range(8, 66, 12):
				draw_line(_p(bu, 54, 28), _p(bu, 54, 42), Color("5e4029"), 2.0)
			draw_line(_p(6, 54, 42), _p(66, 54, 42), Color("7a5335"), 2.0)
			draw_line(_p(6, 54, 28), _p(66, 54, 28), Color("4a321f"), 3.0)

	func _p(u: float, v: float, h: float = 0.0) -> Vector2:
		return Vector2(u - v, -0.5 * (u + v) - h) - position

	func _poly(verts: Array, col: Color) -> void:
		draw_colored_polygon(PackedVector2Array(verts), col)

static func iso_p(u: float, v: float, h: float = 0.0) -> Vector2:
	return Vector2(u - v, -0.5 * (u + v) - h).round()

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	y_sort_enabled = true

	if kind == 4:
		_setup_archive_structure()
		return

	var col := CollisionPolygon2D.new()
	col.name = "Footprint"
	match kind:
		0: # MillerCottage
			col.polygon = PackedVector2Array([iso_p(2, 2), iso_p(46, 2), iso_p(46, 34), iso_p(2, 34)])
		1: # RuinedHomestead
			col.polygon = PackedVector2Array([iso_p(2, 2), iso_p(42, 2), iso_p(42, 30), iso_p(2, 30)])
		2: # CanalLockhouse
			col.polygon = PackedVector2Array([iso_p(2, 2), iso_p(38, 2), iso_p(38, 26), iso_p(2, 26)])
		3: # OldWatermill
			col.polygon = PackedVector2Array([iso_p(2, 2), iso_p(52, 2), iso_p(52, 36), iso_p(2, 36)])
	add_child(col)

func _setup_archive_structure() -> void:
	# Back walls only collide so Aren walks freely inside the cutaway Archive library floor
	var nw_col := CollisionPolygon2D.new()
	nw_col.name = "ArchiveWallNW"
	nw_col.polygon = PackedVector2Array([iso_p(0, 66), iso_p(68, 66), iso_p(68, 74), iso_p(0, 74)])
	add_child(nw_col)

	var ne_col := CollisionPolygon2D.new()
	ne_col.name = "ArchiveWallNE"
	ne_col.polygon = PackedVector2Array([iso_p(66, 0), iso_p(74, 0), iso_p(74, 72), iso_p(66, 72)])
	add_child(ne_col)

	for span in [[0.0, 22.0], [22.0, 44.0], [44.0, 68.0]]:
		var nw_bay := ArchiveBayVisual.new()
		nw_bay.bay_kind = "nw"
		nw_bay.pts = span
		nw_bay.position = iso_p((span[0] + span[1]) * 0.5, 68.0)
		add_child(nw_bay)

		var ne_bay := ArchiveBayVisual.new()
		ne_bay.bay_kind = "ne"
		ne_bay.pts = span
		ne_bay.position = iso_p(68.0, (span[0] + span[1]) * 0.5)
		add_child(ne_bay)

	var mez := ArchiveBayVisual.new()
	mez.bay_kind = "mezzanine"
	mez.position = iso_p(36.0, 54.0)
	add_child(mez)

	for p_coord in [iso_p(4.0, 62.0), iso_p(62.0, 4.0)]:
		var col_node := ArchiveBayVisual.new()
		col_node.bay_kind = "pillar"
		col_node.position = p_coord
		add_child(col_node)

func set_watermill_active(active: bool) -> void:
	watermill_active = active
	queue_redraw()

func _process(delta: float) -> void:
	if kind == 3 and watermill_active:
		wheel_angle = fmod(wheel_angle + delta * 1.4, TAU)
		queue_redraw()

func _poly_pts(verts: Array) -> void:
	draw_colored_polygon(PackedVector2Array(verts), verts.pop_back())

func _plane_u(u0: float, u1: float, v: float, b: float, t: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([iso_p(u0, v, b), iso_p(u1, v, b), iso_p(u1, v, t), iso_p(u0, v, t)]), col)

func _plane_v(u: float, v0: float, v1: float, b: float, t: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([iso_p(u, v0, b), iso_p(u, v1, b), iso_p(u, v1, t), iso_p(u, v0, t)]), col)

func _slab(u0: float, u1: float, v0: float, v1: float, h: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([iso_p(u0, v0, h), iso_p(u1, v0, h), iso_p(u1, v1, h), iso_p(u0, v1, h)]), col)

func _draw() -> void:
	if kind == 4:
		# Cutaway Archive oak floor is drawn on FloodmillLandscape; only draw subtle entrance stone trim here
		return

	match kind:
		0: _draw_miller_cottage()
		1: _draw_ruined_homestead()
		2: _draw_canal_lockhouse()
		3: _draw_old_watermill()

func _draw_miller_cottage() -> void:
	# Shallow floodwater lap + drop shadow
	_slab(-5, 52, -4, 40, 0, Color(0.03, 0.06, 0.08, 0.36))
	_slab(-3, 50, -2, 37, 0, WATER_SHEEN)
	# Damp stone plinth + plaster walls
	_plane_u(0, 48, 0, 0, 10, STONE_MID)
	_plane_v(0, 0, 36, 0, 10, STONE_DARK)
	_plane_u(0, 48, 0, 10, 34, PLASTER)
	_plane_v(0, 0, 36, 10, 34, PLASTER_DAMP)
	# Moss waterline patina
	_plane_u(4, 24, -1, 1, 7, STONE_MOSS)
	_plane_v(-1, 6, 24, 2, 8, STONE_MOSS)
	# Gable triangle on left wall
	draw_colored_polygon(PackedVector2Array([iso_p(0, 0, 34), iso_p(0, 36, 34), iso_p(0, 18, 52)]), PLASTER_DAMP)
	# Half-timber framing + boarded doorway + shuttered window
	draw_line(iso_p(0, 0, 34), iso_p(48, 0, 34), TIMBER, 2.5)
	draw_line(iso_p(0, 0, 10), iso_p(0, 0, 34), TIMBER, 2.5)
	draw_line(iso_p(24, 0, 10), iso_p(24, 0, 34), TIMBER, 2.0)
	draw_line(iso_p(48, 0, 10), iso_p(48, 0, 34), TIMBER, 2.5)
	draw_line(iso_p(0, 18, 10), iso_p(0, 18, 52), TIMBER, 2.0)
	_plane_u(8, 18, -1, 6, 26, Color("3c281a"))
	_plane_u(31, 41, -1, 17, 27, TIMBER)
	_plane_u(32, 40, -2, 18, 26, Color("2e3a42"))
	draw_line(iso_p(36, -2, 18), iso_p(36, -2, 26), TIMBER, 1.0)
	# Pitched weathered shingle roof with moss clumps
	draw_colored_polygon(PackedVector2Array([iso_p(-2, -2, 33), iso_p(50, -2, 33), iso_p(50, 18, 53), iso_p(-2, 18, 53)]), SHINGLE)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, 18, 53), iso_p(50, 18, 53), iso_p(50, 38, 33), iso_p(-2, 38, 33)]), SHINGLE_DARK)
	draw_line(iso_p(-2, 18, 53), iso_p(50, 18, 53), Color("7d5438"), 2.5)
	draw_colored_polygon(PackedVector2Array([iso_p(12, 2, 38), iso_p(24, 2, 38), iso_p(22, 10, 46), iso_p(10, 10, 46)]), STONE_MOSS)
	# Chimney stack
	_plane_u(34, 42, 22, 44, 62, STONE_MID)
	_plane_v(34, 22, 30, 44, 62, STONE_DARK)
	_slab(33, 43, 21, 31, 62, STONE_LIGHT)

func _draw_ruined_homestead() -> void:
	_slab(-4, 46, -4, 34, 0, Color(0.03, 0.06, 0.07, 0.36))
	# Crumbling mossy stone walls + exposed upper timber frame
	_plane_u(0, 44, 0, 0, 12, STONE_MID)
	_plane_v(0, 0, 32, 0, 12, STONE_DARK)
	_plane_u(0, 32, 0, 12, 28, PLASTER_DAMP)
	_plane_v(0, 0, 32, 12, 28, STONE_DARK)
	_plane_u(32, 44, 0, 12, 20, STONE_MID)
	# Sagging doorway with crooked oak plank door
	_plane_u(14, 24, -1, 0, 21, Color("1d1916"))
	draw_colored_polygon(PackedVector2Array([iso_p(15, -2, 0), iso_p(22, -2, 2), iso_p(24, -2, 19), iso_p(17, -2, 20)]), Color("5e3e29"))
	# Intact left roof pitch + collapsed exposed rafters on right half (Reference Image 3 style!)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, -2, 27), iso_p(22, -2, 27), iso_p(20, 16, 44), iso_p(-2, 16, 44)]), SHINGLE)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, 16, 44), iso_p(20, 16, 44), iso_p(22, 33, 27), iso_p(-2, 33, 27)]), SHINGLE_DARK)
	# Exposed broken roof beams & ridge timber
	draw_line(iso_p(-2, 16, 44), iso_p(42, 16, 44), TIMBER_LIGHT, 2.0)
	for ru in [24.0, 32.0, 40.0]:
		draw_line(iso_p(ru, 0, 28), iso_p(ru, 16, 44), TIMBER_ROT, 1.5)
		draw_line(iso_p(ru, 16, 44), iso_p(ru, 31, 28), TIMBER, 1.5)
	draw_colored_polygon(PackedVector2Array([iso_p(34, 16, 20), iso_p(43, 16, 20), iso_p(43, 26, 24), iso_p(34, 26, 24)]), STONE_MOSS)

func _draw_canal_lockhouse() -> void:
	_slab(-4, 42, -4, 32, 0, Color(0.02, 0.05, 0.07, 0.40))
	_plane_u(0, 40, 0, 0, 40, STONE_MID)
	_plane_v(0, 0, 28, 0, 40, STONE_DARK)
	_plane_u(0, 40, 0, 0, 8, STONE_DARK)
	_plane_u(8, 22, -1, 0, 22, Color("20252b"))
	_plane_u(10, 20, -2, 2, 20, Color("38291d"))
	# Lancets + mossy tide mark
	_plane_u(28, 34, -1, 18, 29, Color("1f262e"))
	_plane_u(29, 33, -2, 19, 28, Color("84b8ba"))
	_plane_u(2, 38, -1, 2, 6, STONE_MOSS)
	# Slate pyramidal roof + iron chain wheel
	var apex := iso_p(20, 14, 58)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, -2, 39), iso_p(42, -2, 39), apex]), SLATE_LIGHT)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, 30, 39), iso_p(-2, -2, 39), apex]), SLATE)
	draw_rect(Rect2(apex - Vector2(1, 7), Vector2(2, 7)), GOLD)

func _draw_old_watermill() -> void:
	# Stone watermill base, wheel pit trough, upper timber millhouse, high tower & rotating wheel
	_slab(-8, 58, -6, 42, 0, Color(0.02, 0.05, 0.06, 0.42))
	# Foaming tailrace channel along front-left wheel pit
	draw_colored_polygon(PackedVector2Array([iso_p(-8, -8, 0), iso_p(28, -8, 0), iso_p(28, 4, 0), iso_p(-8, 4, 0)]), Color("1d4a5c"))
	if watermill_active:
		draw_line(iso_p(-4, -5, 1), iso_p(22, -5, 1), Color("96e5f2"), 1.5)
		draw_line(iso_p(0, -2, 1), iso_p(24, -2, 1), Color("67b5cc"), 1.5)

	# Heavy stone ground floor & upper half-timbered loft (u = 0..54, v = 0..38)
	_plane_u(0, 54, 0, 0, 20, STONE_MID)
	_plane_v(0, 0, 38, 0, 20, STONE_DARK)
	_plane_u(0, 54, 0, 20, 42, PLASTER)
	_plane_v(0, 0, 38, 20, 42, PLASTER_DAMP)
	# Left gable triangle filling under pitched slate roof
	draw_colored_polygon(PackedVector2Array([iso_p(0, 0, 42), iso_p(0, 38, 42), iso_p(0, 19, 61)]), PLASTER_DAMP)
	draw_line(iso_p(0, 19, 20), iso_p(0, 19, 61), TIMBER, 2.0)
	# Timber framing & arched mill door + warm windows
	draw_line(iso_p(0, 0, 20), iso_p(54, 0, 20), TIMBER, 3.0)
	draw_line(iso_p(0, 0, 42), iso_p(54, 0, 42), TIMBER, 3.0)
	_plane_u(32, 42, -1, 0, 22, Color("2e2016"))
	_plane_u(33, 41, -2, 1, 20, Color("593a23"))
	draw_rect(Rect2(iso_p(44, -2, 16) - Vector2(1, 2), Vector2(3, 4)), LANTERN_GLOW)
	for wu in [12.0, 38.0]:
		_plane_u(wu, wu + 7, -1, 25, 34, TIMBER)
		_plane_u(wu + 1, wu + 6, -2, 26, 33, Color("f0b44d") if watermill_active else Color("34404a"))

	# Steep dark slate roof over millhouse
	draw_colored_polygon(PackedVector2Array([iso_p(-2, -2, 41), iso_p(56, -2, 41), iso_p(56, 19, 62), iso_p(-2, 19, 62)]), SLATE_LIGHT)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, 19, 62), iso_p(56, 19, 62), iso_p(56, 40, 41), iso_p(-2, 40, 41)]), SLATE)
	draw_line(iso_p(-2, 19, 62), iso_p(56, 19, 62), Color("6d7e94"), 2.5)

	# Upper stone granary/flume tower rising at back right (u = 30..54, v = 14..38, h = 46..74)
	_plane_u(30, 54, 14, 46, 74, STONE_LIGHT)
	_plane_v(30, 14, 38, 46, 74, STONE_MID)
	var tw_apex := iso_p(42, 26, 90)
	draw_colored_polygon(PackedVector2Array([iso_p(29, 13, 73), iso_p(55, 13, 73), tw_apex]), SLATE_LIGHT)
	draw_colored_polygon(PackedVector2Array([iso_p(29, 39, 73), iso_p(29, 13, 73), tw_apex]), SLATE)

	# Iconic isometric Wooden Waterwheel mounted on the front-left wall (centered u=14, v=-6, h=14)
	var hub := iso_p(14.0, -6.0, 14.0)
	var outer_pts: Array[Vector2] = []
	var inner_pts: Array[Vector2] = []
	var spoke_count: int = 8
	for i in range(spoke_count + 1):
		var a: float = wheel_angle + float(i) * TAU / float(spoke_count)
		var du: float = cos(a) * 16.0
		var dh: float = sin(a) * 16.0
		outer_pts.append(iso_p(14.0 + du, -6.0, 14.0 + dh))
		inner_pts.append(iso_p(14.0 + du * 0.72, -6.0, 14.0 + dh * 0.72))
	# Back rim for 3D wheel thickness
	var back_pts: Array[Vector2] = []
	for i in range(spoke_count + 1):
		var a: float = wheel_angle + float(i) * TAU / float(spoke_count)
		back_pts.append(iso_p(14.0 + cos(a) * 16.0, -1.5, 14.0 + sin(a) * 16.0))
	draw_polyline(PackedVector2Array(back_pts), Color("452c1b"), 3.0)
	for i in range(spoke_count):
		draw_line(hub, outer_pts[i], TIMBER_LIGHT, 2.0)
		draw_line(outer_pts[i], back_pts[i], Color("855936"), 2.5)
	draw_polyline(PackedVector2Array(outer_pts), Color("855936"), 3.0)
	draw_polyline(PackedVector2Array(inner_pts), TIMBER, 2.0)
	# Axle trestle & brass/iron hub center
	draw_line(iso_p(14.0, -10.0, 0.0), hub, TIMBER, 3.0)
	draw_circle(hub, 3.5, Color("8be6f0") if watermill_active else Color("7d868c"))

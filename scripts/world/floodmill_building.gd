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
					draw_line(_p(bx, v - 2, sh - 5 - posmod(bx,4)), _p(bx, v - 2, sh - 1), col, 2.0)
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
					draw_line(_p(u - 2, bv, sh - 5 - posmod(bv,4)), _p(u - 2, bv, sh - 1), col, 2.0)
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

		# Fine book bands, shelf edges and cracked coping preserve the original bay anchors.
		if bay_kind in ["nw","ne"]:
			for h in [18,29,40]:
				for t in range(int(pts[0])+4,int(pts[1])-3,4):
					var p: Vector2 = _p(t,66,h-3) if bay_kind == "nw" else _p(66,t,h-3)
					draw_rect(Rect2(p,Vector2(2,1)),Color("c1b389"))
			var mid: float = (pts[0]+pts[1])*0.5
			var top: Vector2 = _p(mid,68,59) if bay_kind == "nw" else _p(68,mid,59)
			draw_line(top,top+Vector2(2,4),Color("354747"),1)
			draw_line(top+Vector2(2,4),top+Vector2(0,8),Color("354747"),1)
		elif bay_kind == "pillar":
			for y in range(-35,-5,7):
				draw_line(Vector2(-4,y),Vector2(4,y+1),Color("3f5353"),1)
			draw_rect(Rect2(-1,-44,2,3),Color("fff1bf"))
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

var wheel_visual: Node2D
var wheel_tick: float = 0.0
func _process(delta: float) -> void:
	if kind != 3 or "--bake-floodmill" in OS.get_cmdline_user_args(): return
	if wheel_visual == null:
		wheel_visual = Node2D.new()
		wheel_visual.set_script(preload("res://scripts/world/floodmill_wheel.gd"))
		wheel_visual.position = Vector2(0,1)
		add_child(wheel_visual)
	wheel_tick += delta
	if wheel_tick >= 0.1:
		if watermill_active: wheel_angle = fmod(wheel_angle+wheel_tick*0.7,TAU)
		wheel_tick = 0
		wheel_visual.angle = wheel_angle
		wheel_visual.active = watermill_active
		wheel_visual.queue_redraw()
func _poly_pts(verts: Array) -> void:
	draw_colored_polygon(PackedVector2Array(verts), verts.pop_back())

func _plane_u(u0: float, u1: float, v: float, b: float, t: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([iso_p(u0, v, b), iso_p(u1, v, b), iso_p(u1, v, t), iso_p(u0, v, t)]), col)

func _plane_v(u: float, v0: float, v1: float, b: float, t: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([iso_p(u, v0, b), iso_p(u, v1, b), iso_p(u, v1, t), iso_p(u, v0, t)]), col)

func _slab(u0: float, u1: float, v0: float, v1: float, h: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([iso_p(u0, v0, h), iso_p(u1, v0, h), iso_p(u1, v1, h), iso_p(u0, v1, h)]), col)

func _draw() -> void:
	if kind < 4 and not "--bake-floodmill" in OS.get_cmdline_user_args():
		var state: int = 1 if kind == 3 and watermill_active else 0
		var texture: Texture2D = preload("res://scripts/world/floodmill_art.gd").texture("res://assets/floodmill/building_%d_%d.png" % [kind,state])
		draw_texture(texture,Vector2(-96,-160))
		return
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
	_masonry(48,36,10)
	# Moss waterline patina
	_plane_u(4, 24, -1, 1, 7, STONE_MOSS)
	_plane_v(-1, 6, 24, 2, 8, STONE_MOSS)
	_wall_weather(48,36,34)
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
	_roof_tiles(50,18,33,53,false)
	_door_detail(8,18,26)
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
	_masonry(44,32,12)
	_wall_weather(32,32,28)
	# Sagging doorway with crooked oak plank door
	_plane_u(14, 24, -1, 0, 21, Color("1d1916"))
	draw_colored_polygon(PackedVector2Array([iso_p(15, -2, 0), iso_p(22, -2, 2), iso_p(24, -2, 19), iso_p(17, -2, 20)]), Color("5e3e29"))
	# Intact left roof pitch + collapsed exposed rafters on right half (Reference Image 3 style!)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, -2, 27), iso_p(22, -2, 27), iso_p(20, 16, 44), iso_p(-2, 16, 44)]), SHINGLE)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, 16, 44), iso_p(20, 16, 44), iso_p(22, 33, 27), iso_p(-2, 33, 27)]), SHINGLE_DARK)
	_roof_tiles(20,16,27,44,false)
	_door_detail(14,24,21)
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
	_masonry(40,28,40)
	_door_detail(8,22,22)
	# Lancets + mossy tide mark
	_plane_u(28, 34, -1, 18, 29, Color("1f262e"))
	_plane_u(29, 33, -2, 19, 28, Color("84b8ba"))
	_plane_u(2, 38, -1, 2, 6, STONE_MOSS)
	# Slate pyramidal roof + iron chain wheel
	var apex := iso_p(20, 14, 58)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, -2, 39), iso_p(42, -2, 39), apex]), SLATE_LIGHT)
	draw_colored_polygon(PackedVector2Array([iso_p(-2, 30, 39), iso_p(-2, -2, 39), apex]), SLATE)
	draw_rect(Rect2(apex - Vector2(1, 7), Vector2(2, 7)), GOLD)
	for i in range(1,5):
		var ratio: float = i/5.0
		draw_line(apex.lerp(iso_p(-2,-2,39),ratio),apex.lerp(iso_p(42,-2,39),ratio),Color("748389"),1)
		draw_line(apex.lerp(iso_p(-2,30,39),ratio),apex.lerp(iso_p(-2,-2,39),ratio),Color("4d6269"),1)

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
	_masonry(54,38,20)
	_wall_weather(54,38,42)
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

	_roof_tiles(56,19,41,62,true)
	_door_detail(32,42,22)
	# Upper stone granary/flume tower rising at back right (u = 30..54, v = 14..38, h = 46..74)
	_plane_u(30, 54, 14, 46, 74, STONE_LIGHT)
	_plane_v(30, 14, 38, 46, 74, STONE_MID)
	var tw_apex := iso_p(42, 26, 90)
	draw_colored_polygon(PackedVector2Array([iso_p(29, 13, 73), iso_p(55, 13, 73), tw_apex]), SLATE_LIGHT)
	draw_colored_polygon(PackedVector2Array([iso_p(29, 39, 73), iso_p(29, 13, 73), tw_apex]), SLATE)

	for row in range(1,5):
		var ratio: float = row/5.0
		draw_line(tw_apex.lerp(iso_p(29,13,73),ratio),tw_apex.lerp(iso_p(55,13,73),ratio),Color("78878b"),1)
		draw_line(tw_apex.lerp(iso_p(29,39,73),ratio),tw_apex.lerp(iso_p(29,13,73),ratio),Color("526971"),1)
	for v in [20,27,33]:
		draw_line(iso_p(30,v,72),iso_p(30,v,64),Color("587165"),2)
	# Granary masonry, recessed loft window, hoist brackets and damp cornice.
	for h in range(48,74,6):
		draw_line(iso_p(30,14,h),iso_p(54,14,h),Color("5a6969"),1)
		draw_line(iso_p(30,14,h),iso_p(30,38,h),Color("414e50"),1)
		for u in range(32+h%12,54,10):
			draw_line(iso_p(u,14,h),iso_p(u,14,h+5),Color("596868"),1)
	_plane_u(38,47,13,54,66,Color("293d44"))
	_plane_u(39,46,12,55,65,Color("a99665") if watermill_active else Color("54727b"))
	draw_line(iso_p(42,12,55),iso_p(42,12,65),Color("343d37"),1)
	draw_line(iso_p(0,0,22),iso_p(0,18,40),Color("7e7258"),2)
	draw_line(iso_p(0,38,22),iso_p(0,18,40),Color("7e7258"),2)

func _masonry(w: int, d: int, height: int) -> void:
	for h in range(1,height,5):
		for u in range(1,w-1,9):
			var offset: int = 4 if h%2 else 0
			var start: int = mini(u+offset,w-2)
			_plane_u(start,mini(start+7,w-1),-0.2,h,h+3,Color("84918a") if (u+h)%3 else Color("576c68"))
		for v in range(1,d-1,9):
			_plane_v(-0.2,v,mini(v+7,d-1),h,h+3,Color("4e605e") if (v+h)%3 else Color("6b7b71"))

func _wall_weather(w: int, d: int, height: int) -> void:
	for u in range(3,w-2,11):
		_plane_u(u,mini(u+5,w-1),-0.3,11,15+(u%9),Color("8f9680"))
		draw_line(iso_p(u,-0.4,height-4),iso_p(u+2,-0.4,height-10),Color("797e6c"),1)
	for v in range(5,d-2,8):
		_plane_v(-0.3,v,v+3,9,18,Color("5d7163"))
	# Narrow framing with diagonal braces, leaving all original openings in place.
	for u in range(0,w,24):
		draw_line(iso_p(u,0,11),iso_p(u,0,height),TIMBER,2)
		draw_line(iso_p(u,0,13),iso_p(mini(u+15,w),0,height-3),Color("716247"),2)

func _door_detail(left: int, right: int, top: int) -> void:
	for u in range(left+1,right,3):
		draw_line(iso_p(u,-2,2),iso_p(u,-2,top-2),Color("8b7853"),1)
	for h in [5,top-5]:
		draw_line(iso_p(left+1,-3,h),iso_p(right-1,-3,h),Color("283b3c"),1)
	draw_rect(Rect2(iso_p(right-2,-3,top/2.0),Vector2(2,2)),Color("c7b680"))

func _roof_tiles(w: int, ridge: int, low: int, high: int, slate: bool) -> void:
	for back in [false,true]:
		for v in range(-2,ridge,4):
			for u in range(-2,w-3,7):
				var vv: float = ridge*2-v if back else v
				var vv2: float = vv-3 if back else vv+3
				var h: float = low+(v+2)*float(high-low)/(ridge+2)
				var h2: float = low+(v+5)*float(high-low)/(ridge+2)
				var shift: int = 3 if posmod(v,8) == 2 else 0
				var uu: int = mini(u+shift,w-5)
				var color: Color = Color("4b626b") if slate else Color("6f6550")
				if posmod(u*11+v*3,5) == 0: color = Color("7d8b81") if slate else Color("9a8864")
				if back: color = color.darkened(0.22)
				if posmod(u*7+v,23) == 0: color = Color("293d3d") # Missing tile / exposed felt.
				draw_colored_polygon(PackedVector2Array([iso_p(uu,vv,h),iso_p(uu+6,vv,h),iso_p(uu+6,vv2,h2),iso_p(uu,vv2,h2)]),color)
				draw_line(iso_p(uu,vv,h),iso_p(uu+6,vv,h),color.lightened(0.12),1)
	# Moss collects along one leaking valley.
	for i in range(7):
		draw_rect(Rect2(iso_p(8+i*2,4+i,low+6+i),Vector2(4,2)),Color("61794d"))

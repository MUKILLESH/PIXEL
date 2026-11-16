extends StaticBody2D
## Procedural 2.5D pixel-art alpine architecture for Dawnspire Mountain (Chapter 4):
## FoothillsArch, CliffShelter, SkybridgeAnchors, PilgrimChapel (cutaway murals),
## ObservatoryDome, DawnspireSanctum, and GreatBellPortal.

@export var kind: String = "foothills_arch"

class CutawayChapelInterior extends Node2D:
	var owner_building: Node2D
	func _draw() -> void:
		if owner_building != null:
			owner_building.draw_pilgrim_chapel_interior(self)

var interior_visual: Node2D
var beacons_synchronized: bool = false
var great_bell_unlocked: bool = false

func _ready() -> void:
	match kind:
		"foothills_arch":
			_add_box(Vector2(0, -10), Vector2(84, 22))
		"cliff_shelter":
			_add_box(Vector2(0, -12), Vector2(44, 16))
		"skybridge_anchors":
			# Twin flanking masonry winches; keep central bridge lane x=-24..24 open!
			_add_box(Vector2(-46, -6), Vector2(26, 22))
			_add_box(Vector2(46, -6), Vector2(26, 22))
		"pilgrim_chapel":
			# Back wall only so Aren walks freely inside Pilgrim's Refuge courtyard
			_add_box(Vector2(0, -20), Vector2(118, 16))
			z_index = -1
			interior_visual = CutawayChapelInterior.new()
			interior_visual.owner_building = self
			interior_visual.z_index = 1
			add_child(interior_visual)
		"observatory_dome":
			_add_box(Vector2(0, -12), Vector2(76, 18))
		"dawnspire_sanctum":
			_add_box(Vector2(0, -12), Vector2(106, 18))
		"great_bell_portal":
			_add_box(Vector2(0, -12), Vector2(90, 20))

func _add_box(pos: Vector2, sz: Vector2) -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = sz
	col.shape = rect
	col.position = pos
	add_child(col)

func _draw() -> void:
	match kind:
		"foothills_arch":
			_draw_foothills_arch()
		"cliff_shelter":
			_draw_cliff_shelter()
		"skybridge_anchors":
			_draw_skybridge_anchors()
		"pilgrim_chapel":
			_draw_pilgrim_chapel_base()
		"observatory_dome":
			_draw_observatory_dome()
		"dawnspire_sanctum":
			_draw_dawnspire_sanctum()
		"great_bell_portal":
			_draw_great_bell_portal()

func _draw_foothills_arch() -> void:
	draw_rect(Rect2(-40, -56, 18, 56), Color("364054"))
	draw_rect(Rect2(22, -56, 18, 56), Color("283040"))
	draw_rect(Rect2(-44, -66, 88, 14), Color("46536b"))
	draw_rect(Rect2(-44, -68, 88, 4), Color("dbe8f5")) # snow cap
	draw_rect(Rect2(-12, -58, 24, 5), Color("d9a94e"))

func _draw_cliff_shelter() -> void:
	draw_rect(Rect2(-22, -40, 44, 40), Color("2e3647"))
	draw_rect(Rect2(12, -40, 10, 40), Color("212736"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-26, -40), Vector2(0, -54), Vector2(26, -40)
	]), Color("455269"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-24, -40), Vector2(0, -53), Vector2(24, -40)
	]), Color("cfdeed"))
	draw_rect(Rect2(-8, -22, 16, 22), Color("161a24"))
	draw_circle(Vector2(0, -14), 5.0, Color(0.98, 0.72, 0.34, 0.72))

func _draw_skybridge_anchors() -> void:
	for sx in [-46.0, 46.0]:
		draw_rect(Rect2(sx - 12, -32, 24, 32), Color("3a4254"))
		draw_rect(Rect2(sx - 14, -36, 28, 6), Color("525e75"))
		draw_rect(Rect2(sx - 14, -38, 28, 3), Color("d4e2f0"))
		draw_circle(Vector2(sx, -16), 6.0, Color("c48a47"))

func _draw_pilgrim_chapel_base() -> void:
	draw_rect(Rect2(-58, -44, 116, 44), Color("2d3345"))
	draw_rect(Rect2(-60, -48, 120, 6), Color("535d78"))
	draw_rect(Rect2(-60, -50, 120, 3), Color("e2edf8"))
	# Warm crimson roof peak above cutaway chapel beam
	draw_colored_polygon(PackedVector2Array([
		Vector2(-56, -48), Vector2(0, -76), Vector2(56, -48)
	]), Color("7a3642"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-48, -50), Vector2(0, -73), Vector2(48, -50)
	]), Color("cfdeed"))

func draw_pilgrim_chapel_interior(c: Node2D) -> void:
	# Cutaway recessed stone floor + glowing pilgrim murals & vigil bench
	c.draw_rect(Rect2(-54, 0, 108, 46), Color("242938"))
	c.draw_rect(Rect2(-44, -32, 22, 20), Color("3b4259"))
	c.draw_rect(Rect2(-12, -34, 24, 22), Color("3b4259"))
	c.draw_rect(Rect2(20, -32, 22, 20), Color("3b4259"))
	c.draw_circle(Vector2(0, -24), 4.0, Color("f5c56b"))
	c.draw_circle(Vector2(-32, -22), 3.0, Color("88c9e0"))
	c.draw_circle(Vector2(30, -22), 3.0, Color("e68a65"))

func _draw_observatory_dome() -> void:
	draw_rect(Rect2(-38, -46, 76, 46), Color("333b4f"))
	draw_rect(Rect2(18, -46, 20, 46), Color("252c3d"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-40, -46), Vector2(-24, -74), Vector2(24, -74), Vector2(40, -46)
	]), Color("455873"))
	draw_rect(Rect2(-24, -74, 48, 4), Color("d9a94e"))
	draw_rect(Rect2(-10, -26, 20, 26), Color("161c29"))
	draw_circle(Vector2(0, -58), 6.0, Color("8be6f0"))

func _draw_dawnspire_sanctum() -> void:
	draw_rect(Rect2(-52, -48, 104, 48), Color("2e384f"))
	draw_rect(Rect2(-56, -54, 112, 8), Color("4a5878"))
	draw_rect(Rect2(-56, -56, 112, 3), Color("d9e6f5"))
	draw_rect(Rect2(-14, -40, 28, 40), Color("161c29"))
	var aura := Color("ffe38f") if beacons_synchronized else Color("6c7a9c")
	draw_rect(Rect2(-10, -36, 20, 34), Color(aura.r, aura.g, aura.b, 0.35))

func _draw_great_bell_portal() -> void:
	draw_rect(Rect2(-44, -62, 88, 62), Color("262d3d"))
	draw_rect(Rect2(20, -62, 24, 62), Color("1b202e"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-48, -62), Vector2(0, -88), Vector2(48, -62)
	]), Color("46536e"))
	draw_rect(Rect2(-14, -44, 28, 44), Color("10131c"))
	if great_bell_unlocked:
		draw_rect(Rect2(-10, -40, 20, 38), Color("ffdf7e"))
		draw_circle(Vector2(0, -54), 5.0, Color("8ef5ff"))
	else:
		draw_rect(Rect2(-10, -40, 20, 38), Color("3c2433"))
		for bx in [-5, 0, 5]:
			draw_line(Vector2(bx, -42), Vector2(bx, -2), Color("70798f"), 1.6)

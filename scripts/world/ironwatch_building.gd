extends StaticBody2D
## Procedural isometric pixel-art architecture for Ironwatch Keep (Chapter 3):
## GatehouseBastion, RuinedBarracks, CutawayArchives (with Gothic lancets),
## HallOfCrests, ShadowColonnade, and BeaconVaultSanctum.

@export var kind: String = "gatehouse_bastion"

class CutawayArchiveVisual extends Node2D:
	var owner_building: Node2D
	func _draw() -> void:
		if owner_building != null:
			owner_building.draw_cutaway_archive_interior(self)

var interior_visual: Node2D
var third_beacon_lit: bool = false

func _ready() -> void:
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	match kind:
		"gatehouse_bastion":
			rect.size = Vector2(96, 36)
			col.position = Vector2(0, -14)
		"ruined_barracks":
			rect.size = Vector2(104, 34)
			col.position = Vector2(0, -16)
		"cutaway_archives":
			# Back wall collision only so Aren walks cleanly onto the cutaway library floor
			rect.size = Vector2(120, 18)
			col.position = Vector2(0, -28)
			z_index = -1
			interior_visual = CutawayArchiveVisual.new()
			interior_visual.owner_building = self
			interior_visual.z_index = 1
			add_child(interior_visual)
		"hall_of_crests":
			rect.size = Vector2(88, 16)
			col.position = Vector2(0, -24)
		"shadow_colonnade":
			rect.size = Vector2(26, 150)
			col.position = Vector2(0, 0)
		"beacon_vault_sanctum":
			rect.size = Vector2(168, 22)
			col.position = Vector2(0, -24)
	col.shape = rect
	add_child(col)

func _draw() -> void:
	match kind:
		"gatehouse_bastion":
			_draw_gatehouse_bastion()
		"ruined_barracks":
			_draw_ruined_barracks()
		"cutaway_archives":
			_draw_cutaway_archives_base()
		"hall_of_crests":
			_draw_hall_of_crests()
		"shadow_colonnade":
			_draw_shadow_colonnade()
		"beacon_vault_sanctum":
			_draw_beacon_vault_sanctum()

func _draw_gatehouse_bastion() -> void:
	# Drop shadow
	draw_colored_polygon(PackedVector2Array([Vector2(-56, 8), Vector2(0, -18), Vector2(60, 8), Vector2(0, 26)]), Color(0.04, 0.04, 0.08, 0.55))
	# Basalt fortress facade
	draw_rect(Rect2(-48, -68, 96, 72), Color("323745"))
	draw_rect(Rect2(12, -68, 36, 72), Color("222633"))
	# Ashlar stone block joints
	for sy in range(-60, -2, 12):
		draw_line(Vector2(-46, sy), Vector2(46, sy), Color("1f222d"), 1.0)
	# Crenellated battlement teeth across parapet
	for mx in range(-48, 44, 14):
		draw_rect(Rect2(mx, -76, 9, 9), Color("464d5e"))
		draw_rect(Rect2(mx + 1, -76, 7, 2), Color("677087"))
	# Flanking conical slate turrets (inspired by Fortress Courtyard reference)
	for tx in [-42, 42]:
		draw_rect(Rect2(tx - 11, -74, 22, 74), Color("393f4f"))
		draw_rect(Rect2(tx + 2, -74, 9, 74), Color("252936"))
		draw_colored_polygon(PackedVector2Array([Vector2(tx - 15, -74), Vector2(tx, -108), Vector2(tx + 15, -74)]), Color("52385c"))
		draw_colored_polygon(PackedVector2Array([Vector2(tx, -108), Vector2(tx + 15, -74), Vector2(tx + 3, -74)]), Color("37233f"))
		draw_rect(Rect2(tx - 1, -112, 2, 5), Color("d9a94e"))
	# Warm amber arrow slits
	for wx in [-24, -4, 16]:
		draw_rect(Rect2(wx, -52, 6, 11), Color("161521"))
		draw_rect(Rect2(wx + 1, -50, 4, 7), Color("f5b64c"))
	# Iron-banded oak bastion door
	draw_rect(Rect2(-12, -26, 24, 26), Color("171821"))
	draw_rect(Rect2(-9, -23, 18, 23), Color("4d3627"))
	draw_line(Vector2(-9, -15), Vector2(9, -15), Color("292f3b"), 2.0)

func _draw_ruined_barracks() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-56, 10), Vector2(0, -14), Vector2(56, 10), Vector2(0, 22)]), Color(0.05, 0.05, 0.09, 0.50))
	# Stone garrison walls
	draw_rect(Rect2(-50, -56, 100, 56), Color("373d4a"))
	draw_rect(Rect2(16, -56, 34, 56), Color("252a36"))
	# Pitched violet-slate roof
	draw_colored_polygon(PackedVector2Array([Vector2(-56, -56), Vector2(-32, -84), Vector2(36, -84), Vector2(56, -56)]), Color("4a3654"))
	draw_colored_polygon(PackedVector2Array([Vector2(14, -84), Vector2(36, -84), Vector2(56, -56), Vector2(14, -56)]), Color("34243d"))
	# Roof rib seams
	for rx in range(-36, 40, 16):
		draw_line(Vector2(rx, -84), Vector2(rx + 4, -56), Color("2a1d31"), 1.5)
	# Warm candlelit garrison windows
	for gx in [-34, 22]:
		draw_rect(Rect2(gx, -40, 12, 13), Color("161822"))
		draw_rect(Rect2(gx + 2, -38, 8, 9), Color("ebae4b"))
		draw_line(Vector2(gx + 6, -40), Vector2(gx + 6, -27), Color("2b2d3a"), 1.0)
	# Recessed barracks doorway
	draw_rect(Rect2(-11, -30, 22, 30), Color("161821"))
	draw_rect(Rect2(-8, -27, 16, 27), Color("4f3b2c"))
	# Shield emblem over lintel
	draw_colored_polygon(PackedVector2Array([Vector2(-5, -44), Vector2(5, -44), Vector2(4, -36), Vector2(0, -33), Vector2(-4, -36)]), Color("7a8499"))

func _draw_cutaway_archives_base() -> void:
	# Recessed stone floor base for the cutaway library room (walks right over y = 0..70)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-68, 12), Vector2(0, -24), Vector2(68, 12), Vector2(0, 52)
	]), Color("2a2f3a"))

func draw_cutaway_archive_interior(canvas: Node2D) -> void:
	# Cutaway Gothic Fortress Archives inspired by reference image 2:
	# Back walls with tall leaded lancet windows, bookcases, hanging chandelier, & cyan memory flask
	# Left back wall
	canvas.draw_colored_polygon(PackedVector2Array([
		Vector2(-64, 12), Vector2(-64, -76), Vector2(0, -104), Vector2(0, -18)
	]), Color("2b303a"))
	# Right back wall
	canvas.draw_colored_polygon(PackedVector2Array([
		Vector2(0, -104), Vector2(64, -76), Vector2(64, 12), Vector2(0, -18)
	]), Color("20252e"))
	# Stone cornice molding along cutaway top edge
	canvas.draw_line(Vector2(-64, -76), Vector2(0, -104), Color("515869"), 4.0)
	canvas.draw_line(Vector2(0, -104), Vector2(64, -76), Color("3c4352"), 4.0)
	# Twin Gothic arched windows with warm glowing amber glass
	for wx in [-38, -16]:
		var wy: float = -54.0 + (-wx) * 0.25
		canvas.draw_rect(Rect2(wx - 6, wy - 28, 12, 24), Color("171a24"))
		canvas.draw_rect(Rect2(wx - 4, wy - 25, 8, 19), Color("d9be71"))
		canvas.draw_line(Vector2(wx, wy - 26), Vector2(wx, wy - 6), Color("383c47"), 1.0)
		canvas.draw_line(Vector2(wx - 4, wy - 16), Vector2(wx + 4, wy - 16), Color("383c47"), 1.0)
	for rx in [16, 38]:
		var ry: float = -54.0 + rx * 0.25
		canvas.draw_rect(Rect2(rx - 6, ry - 28, 12, 24), Color("171a24"))
		canvas.draw_rect(Rect2(rx - 4, ry - 25, 8, 19), Color("bfa45c"))
		canvas.draw_line(Vector2(rx, ry - 26), Vector2(rx, ry - 6), Color("2c303b"), 1.0)
	# Timber bookshelves stacked with tomes along back walls
	for bx in [-54, -28, 10, 34]:
		var by_off: float = -24.0 + absf(float(bx)) * 0.25
		canvas.draw_rect(Rect2(bx, by_off - 24, 18, 28), Color("4a3322"))
		for sy in range(int(by_off) - 20, int(by_off) + 2, 7):
			canvas.draw_rect(Rect2(bx + 2, sy, 14, 4), Color("70523a"))
			canvas.draw_rect(Rect2(bx + 3, sy + 1, 3, 3), Color("3f6185"))
			canvas.draw_rect(Rect2(bx + 8, sy + 1, 3, 3), Color("96433a"))
			canvas.draw_rect(Rect2(bx + 12, sy + 1, 3, 3), Color("c49b4f"))
	# Glowing teal memory-condenser cylinder on east dais
	canvas.draw_rect(Rect2(44, -18, 10, 14), Color("3a404f"))
	canvas.draw_rect(Rect2(46, -24, 6, 8), Color("68e8f5"))
	canvas.draw_rect(Rect2(47, -23, 4, 5), Color("d9ffff"))
	# Wrought-iron hanging candle chandelier at vault apex
	canvas.draw_line(Vector2(0, -98), Vector2(0, -68), Color("22252e"), 2.0)
	canvas.draw_rect(Rect2(-12, -70, 24, 3), Color("36322c"))
	for cx in [-10, -3, 3, 10]:
		canvas.draw_rect(Rect2(cx - 1, -74, 2, 4), Color("e8dec3"))
		canvas.draw_circle(Vector2(cx, -76), 2.5, Color(1.0, 0.84, 0.42, 0.85))

func _draw_hall_of_crests() -> void:
	# Three carved heraldic sandstone-and-basalt archways
	draw_rect(Rect2(-46, -54, 92, 34), Color("29263d"))
	draw_rect(Rect2(-48, -58, 96, 6), Color("534775"))
	for px in [-38, -6, 26]:
		draw_rect(Rect2(px, -48, 12, 26), Color("3f385c"))
		draw_rect(Rect2(px + 2, -45, 8, 16), Color("1b182b"))
		draw_rect(Rect2(px + 3, -43, 6, 12), Color("7a68ab") if px == -6 else Color("63538c"))
	# Twin gold-trimmed violet banners
	for bx in [-46, 38]:
		draw_rect(Rect2(bx, -52, 8, 28), Color("4f2469"))
		draw_rect(Rect2(bx + 1, -30, 6, 3), Color("e6b85c"))

func _draw_shadow_colonnade() -> void:
	# Western fortified colonnade framing the stealth passage
	draw_rect(Rect2(-14, -76, 28, 152), Color("242636"))
	draw_rect(Rect2(6, -76, 8, 152), Color("181926"))
	for wy in range(-64, 72, 36):
		draw_rect(Rect2(-12, wy, 20, 12), Color("3a3854"))
		draw_circle(Vector2(2, wy + 6), 3.0, Color("9b5de5"))

func _draw_beacon_vault_sanctum() -> void:
	# Cosmic violet/gold portal colonnade inspired by reference image 3
	draw_rect(Rect2(-84, -68, 168, 42), Color("221e38"))
	draw_rect(Rect2(-88, -72, 176, 6), Color("62528f"))
	# Left & Right amethyst pillars with sapphire lanterns
	for px in [-74, -36, 24, 62]:
		draw_rect(Rect2(px, -74, 14, 52), Color("3d345c"))
		draw_rect(Rect2(px + 2, -74, 10, 4), Color("d9a94e"))
		draw_rect(Rect2(px + 4, -52, 6, 12), Color("70d6ff") if third_beacon_lit else Color("6b4999"))
	# Central cosmic vault portal arch
	draw_rect(Rect2(-20, -78, 40, 56), Color("141126"))
	var core_col := Color("8be6ff") if third_beacon_lit else Color("7b44bf")
	draw_rect(Rect2(-14, -72, 28, 46), core_col)
	draw_rect(Rect2(-6, -68, 12, 42), Color("f7e49e") if third_beacon_lit else Color("ba82ff"))
	# Flanking violet heraldic banners
	for bx in [-56, 46]:
		draw_rect(Rect2(bx, -66, 10, 32), Color("532978"))
		draw_rect(Rect2(bx + 2, -40, 6, 3), Color("f2ca6b"))

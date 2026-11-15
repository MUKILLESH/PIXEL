extends Node2D
## Draws Floodmill's sunken streets, puddles/reflections, Sluice Canal channels,
## drainable Archive Causeway, cutaway Archive library floor, Sanctuary terrace, and mist.

var watermill_repaired: bool = false
var sluice_gate_states: Array[int] = [0, 0, 0] # 0:CLOSED, 1:DRAIN, 2:DIVERT, 3:OPEN
var sluice_solved: bool = false
var ledger_solved: bool = false
var second_beacon_activated: bool = false
var _mist_phase: float = 0.0

func _process(delta: float) -> void:
	_mist_phase = fmod(_mist_phase + delta * 0.45, TAU)
	if not Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	var stone_wet := Color("3b474a")
	var cobble := Color("4f5856")
	var cobble_light := Color("626b67")
	var plank := Color("63442a")
	var canal_bank := Color("2e3536")
	var deep_water := Color("163e4f")
	var mid_water := Color("215a70")
	var puddle := Color(0.14, 0.38, 0.48, 0.62)

	# 1. Entrance road -> Abandoned Village Square -> East Watermill -> South Bank Promenade
	draw_polyline(PackedVector2Array([Vector2(-216, 212), Vector2(-148, 192), Vector2(-84, 140), Vector2(-56, 92)]), stone_wet, 28.0)
	draw_polyline(PackedVector2Array([Vector2(-216, 212), Vector2(-148, 192), Vector2(-84, 140), Vector2(-56, 92)]), cobble, 20.0)

	# Floodmill Town Square mossy flagstones
	draw_rect(Rect2(-98, 56, 108, 72), Color("364244"))
	draw_rect(Rect2(-92, 62, 96, 60), cobble)
	for cx in range(-86, 0, 18):
		for cy in range(66, 118, 14):
			draw_rect(Rect2(cx, cy, 14, 10), cobble_light)
	# Square corner puddles with shimmering reflections
	draw_colored_polygon(PackedVector2Array([Vector2(-86, 104), Vector2(-54, 100), Vector2(-46, 114), Vector2(-78, 118)]), puddle)
	draw_colored_polygon(PackedVector2Array([Vector2(-22, 66), Vector2(4, 62), Vector2(8, 76), Vector2(-18, 80)]), puddle)

	# Path East to Ruined Homestead Locket & Old Watermill courtyard
	draw_polyline(PackedVector2Array([Vector2(-46, 106), Vector2(22, 120), Vector2(60, 122)]), cobble, 14.0)
	draw_polyline(PackedVector2Array([Vector2(0, 86), Vector2(86, 72), Vector2(156, 62)]), stone_wet, 24.0)
	draw_polyline(PackedVector2Array([Vector2(0, 86), Vector2(86, 72), Vector2(156, 62)]), cobble, 18.0)
	draw_circle(Vector2(156, 68), 40.0, Color("3c4746"))
	draw_circle(Vector2(156, 68), 32.0, cobble)

	# South Millpond & Eastern Mill Tailrace
	draw_rect(Rect2(208, -28, 72, 152), canal_bank)
	draw_rect(Rect2(214, -22, 60, 140), deep_water)
	draw_rect(Rect2(220, -18, 48, 130), mid_water)
	for my in range(-10, 108, 22):
		var shift: float = sin(_mist_phase + float(my) * 0.1) * 3.0
		draw_line(Vector2(226 + shift, my), Vector2(252 + shift, my), Color("67b5cc") if watermill_repaired else Color("3c768a"), 1.5)

	# Path North-West to Canal Sluice Promenade
	draw_polyline(PackedVector2Array([Vector2(-56, 72), Vector2(-36, 18), Vector2(36, 8)]), stone_wet, 22.0)
	draw_polyline(PackedVector2Array([Vector2(-56, 72), Vector2(-36, 18), Vector2(36, 8)]), cobble, 16.0)
	draw_polyline(PackedVector2Array([Vector2(-84, 14), Vector2(-64, 4), Vector2(48, 4), Vector2(108, 24)]), cobble, 18.0)

	# 2. East-West Sluice Canal at y = -32 (x in [-900..900], y in [-46..-18])
	draw_rect(Rect2(-900, -50, 1800, 38), canal_bank)
	draw_rect(Rect2(-900, -45, 1800, 28), deep_water)
	draw_rect(Rect2(-900, -41, 1800, 20), mid_water)
	for rx in range(-780, 780, 44):
		var wave: float = sin(_mist_phase + float(rx) * 0.04) * 4.0
		draw_line(Vector2(rx + wave, -35), Vector2(rx + 18 + wave, -35), Color("5ea8bf"), 1.0)
		draw_line(Vector2(rx + 14 - wave, -27), Vector2(rx + 32 - wave, -27), Color("468a9e"), 1.0)

	# Three readable Weir Channels across the Sluice Canal (West -124, Center -64, East 36)
	var gate_positions := [-124.0, -64.0, 36.0]
	for gi in range(3):
		var gx: float = gate_positions[gi]
		draw_rect(Rect2(gx - 12, -49, 24, 34), Color("495254"))
		draw_rect(Rect2(gx - 8, -46, 16, 28), Color("283036"))
		var g_state: int = sluice_gate_states[gi]
		var bar_col := Color("8be6f0") if sluice_solved else (Color("e6b85c") if g_state > 0 else Color("8a4d42"))
		if g_state == 0: # CLOSED
			draw_rect(Rect2(gx - 7, -36, 14, 10), Color("543828"))
		draw_rect(Rect2(gx - 8, -49, 16, 4), bar_col)

	# 3. Archive Causeway (x in [-92..-36], y in [-52..-12])
	draw_rect(Rect2(-94, -52, 60, 42), Color("555c5a"))
	if sluice_solved:
		# Drained mossy limestone steps across the canal
		draw_rect(Rect2(-90, -48, 52, 36), Color("626b67"))
		for sy in range(-44, -12, 8):
			draw_rect(Rect2(-87, sy, 46, 5), Color("7b8580"))
		draw_rect(Rect2(-88, -46, 6, 32), Color("3c6943"))
		draw_rect(Rect2(-44, -46, 6, 32), Color("3c6943"))
	else:
		# Submerged causeway beneath dark churning floodwater
		draw_rect(Rect2(-90, -48, 52, 36), Color("163c4d"))
		draw_rect(Rect2(-86, -42, 44, 24), Color("215b70"))
		draw_line(Vector2(-82, -36), Vector2(-48, -36), Color("8fd6e8"), 1.5)
		draw_line(Vector2(-78, -28), Vector2(-46, -28), Color("67b5cc"), 1.5)

	# 4. North Courtyard -> Cutaway Forgotten Archive Hall & Second Beacon Sanctuary
	draw_polyline(PackedVector2Array([Vector2(-64, -56), Vector2(-88, -82), Vector2(-104, -84)]), cobble, 18.0)

	# Isometric Cutaway Forgotten Archive Oak Plank Floor centered around (-134, -76) front tip
	var a_floor := PackedVector2Array([
		Vector2(-134, -76),
		Vector2(-66, -110),
		Vector2(-134, -144),
		Vector2(-202, -110),
	])
	draw_colored_polygon(a_floor, Color("291d14"))
	var a_inner := PackedVector2Array([
		Vector2(-134, -79),
		Vector2(-70, -110),
		Vector2(-134, -141),
		Vector2(-198, -110),
	])
	draw_colored_polygon(a_inner, Color("473121"))
	# Decorative Archive Bell-and-Star brass floor medallion under Ledger Table
	draw_colored_polygon(PackedVector2Array([
		Vector2(-134, -98), Vector2(-114, -108), Vector2(-134, -118), Vector2(-154, -108)
	]), Color("35545e") if ledger_solved else Color("2f3942"))
	draw_circle(Vector2(-134, -108), 6.0, Color("8be6f0") if ledger_solved else Color("b5904b"), false, 1.5)

	# Raised stone road from Archive Courtyard NE -> Second Beacon Sanctuary -> Ironwatch Gate
	draw_polyline(PackedVector2Array([Vector2(-64, -64), Vector2(-20, -96), Vector2(22, -148), Vector2(64, -206)]), stone_wet, 22.0)
	draw_polyline(PackedVector2Array([Vector2(-64, -64), Vector2(-20, -96), Vector2(22, -148), Vector2(64, -206)]), cobble, 15.0)
	draw_polyline(PackedVector2Array([Vector2(64, -206), Vector2(130, -202), Vector2(186, -196)]), cobble, 16.0)

	# Second Beacon Sanctuary Terraced Plaza (64, -208)
	draw_circle(Vector2(64, -208), 46.0, Color("313d40"))
	draw_circle(Vector2(64, -208), 38.0, Color("485457"))
	if second_beacon_activated:
		draw_circle(Vector2(64, -208), 58.0, Color(0.45, 0.90, 0.96, 0.16))
		draw_circle(Vector2(64, -208), 28.0, Color(1.0, 0.86, 0.50, 0.18))

	# Subtle animated swamp mist wisps across sunken regions
	for m in range(6):
		var mx: float = -180.0 + float(m) * 76.0 + sin(_mist_phase + float(m)) * 14.0
		var my: float = 156.0 - float(m % 3) * 112.0 + cos(_mist_phase * 0.7 + float(m)) * 4.0
		draw_rect(Rect2(mx, my, 42, 6), Color(0.68, 0.86, 0.90, 0.08))

	# Subtle crisp area labels
	var font := ThemeDB.fallback_font
	var labels := [
		[Vector2(-224, 232), "FLOODMILL ENTRANCE"],
		[Vector2(-88, 142), "ABANDONED VILLAGE"],
		[Vector2(122, 74), "OLD WATERMILL"],
		[Vector2(48, -10), "SLUICE CANAL"],
		[Vector2(-196, -64), "FORGOTTEN ARCHIVE"],
		[Vector2(18, -162), "SECOND BEACON SANCTUARY"],
		[Vector2(142, -218), "TO IRONWATCH KEEP"],
	]
	for item in labels:
		draw_string(font, item[0], item[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.90, 0.88, 0.74, 0.76))

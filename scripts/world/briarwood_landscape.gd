extends Node2D
## Draws Briarwood Forest dirt trails, ancient flagstones, stream, bridge, mirror beams,
## wayside shrines, swaying ferns, fireflies, and ambient glow.

var bridge_repaired: bool = false
var mirror_solved: bool = false
var beacon_activated: bool = false
var _anim_time: float = 0.0
var _redraw_accum: float = 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_anim_time = fmod(_anim_time + delta, TAU * 8.0)
	_redraw_accum += delta
	if _redraw_accum >= 0.08:
		_redraw_accum = 0.0
		queue_redraw()

func _draw() -> void:
	var dirt := Color("4f4334")
	var dirt_edge := Color("3b3326")
	var stone := Color("4a5452")

	# 1. Forest Edge -> Whispering Fork -> Branches
	draw_line(Vector2(0, 224), Vector2(0, 88), dirt_edge, 28.0)
	draw_line(Vector2(0, 224), Vector2(0, 88), dirt, 22.0)

	# Campfire clearing pad
	draw_circle(Vector2(44, 180), 34.0, dirt_edge)
	draw_circle(Vector2(44, 180), 28.0, Color("473e30"))

	# Fork West to Old Bridge
	draw_polyline(PackedVector2Array([Vector2(0, 88), Vector2(-66, 56), Vector2(-90, 12)]), dirt_edge, 26.0)
	draw_polyline(PackedVector2Array([Vector2(0, 88), Vector2(-66, 56), Vector2(-90, 12)]), dirt, 20.0)

	# Fork East to Carpenter's Worksite
	draw_polyline(PackedVector2Array([Vector2(0, 88), Vector2(88, 76), Vector2(158, 72)]), dirt_edge, 26.0)
	draw_polyline(PackedVector2Array([Vector2(0, 88), Vector2(88, 76), Vector2(158, 72)]), dirt, 20.0)
	draw_circle(Vector2(156, 72), 48.0, dirt_edge)
	draw_circle(Vector2(156, 72), 42.0, dirt)

	# 2. Northern Paths (Old Bridgehead -> Erased Ruins -> Mirror Grove -> Ruined Camp -> Beacon -> Floodmill)
	draw_polyline(PackedVector2Array([Vector2(-90, -44), Vector2(-90, -90), Vector2(-132, -138)]), dirt_edge, 22.0)
	draw_polyline(PackedVector2Array([Vector2(-90, -44), Vector2(-90, -90), Vector2(-132, -138)]), dirt, 16.0)

	# Ancient Oakhaven ruined cobbles
	draw_rect(Rect2(-64, -124, 128, 52), Color("28382f"))
	draw_rect(Rect2(-56, -118, 112, 40), Color("3c4743"))
	draw_line(Vector2(-90, -82), Vector2(114, -92), stone, 16.0)
	draw_polyline(PackedVector2Array([Vector2(114, -92), Vector2(166, -124), Vector2(184, -138)]), dirt, 14.0)

	# Path into First Beacon Shrine & Southeast to Floodmill
	draw_polyline(PackedVector2Array([Vector2(-132, -144), Vector2(-84, -186), Vector2(-32, -206)]), stone, 16.0)
	draw_polyline(PackedVector2Array([Vector2(-24, -108), Vector2(-32, -206), Vector2(78, -200), Vector2(166, -196)]), stone, 16.0)

	# 3. Briarwood Stream crossing East-West at y = -20
	draw_rect(Rect2(-900, -42, 1800, 44), Color("362d22"))
	draw_rect(Rect2(-900, -37, 1800, 34), Color("1e5066"))
	draw_rect(Rect2(-900, -32, 1800, 22), Color("276b85"))
	for rx in range(-820, 820, 48):
		var flow: float = fmod(_anim_time * 18.0, 48.0)
		draw_line(Vector2(rx + flow * 0.4, -26), Vector2(rx + 18 + flow * 0.4, -26), Color("67b5cc"), 1.0)
		draw_line(Vector2(rx + 14 + flow * 0.3, -16), Vector2(rx + 34 + flow * 0.3, -16), Color("4f9ab3"), 1.0)
	# Lily pads & stream boulders
	for lx in [-240, -160, 20, 120, 220]:
		draw_circle(Vector2(lx, -16), 4.0, Color("2f693e"))
		draw_circle(Vector2(lx + 1, -17), 1.5, Color("f08c9d"))

	# Swaying forest ferns and a small forgotten wayside stone shrine near the fork
	var fern_sway: float = sin(_anim_time * 1.8) * 1.5
	for fp: Vector2 in [Vector2(-42, 134), Vector2(36, 118), Vector2(-132, 36), Vector2(106, -4), Vector2(-180, -110), Vector2(118, -148)]:
		draw_rect(Rect2(fp.x - 5, fp.y - 2, 10, 4), Color("1e3628"))
		draw_line(fp, fp + Vector2(-4 + fern_sway, -7), Color("3c6e47"), 2.0)
		draw_line(fp, fp + Vector2(3 + fern_sway, -8), Color("4e8a59"), 2.0)
	# Small moss-draped forgotten shrine stone by the eastern bend (62, 116)
	draw_rect(Rect2(58, 108, 10, 10), Color("495452"))
	draw_rect(Rect2(56, 106, 14, 3), Color("365c3f"))
	draw_rect(Rect2(62, 102, 2, 4), Color("7de2f0"))

	# 4. Old Bridge Span (x in [-118, -62], y in [-44, 4])
	draw_rect(Rect2(-120, -6, 60, 12), Color("5c5852"))
	draw_rect(Rect2(-120, -48, 60, 12), Color("5c5852"))
	if bridge_repaired:
		# Solid repaired timber crossing
		draw_rect(Rect2(-114, -40, 48, 38), Color("6e4729"))
		draw_rect(Rect2(-112, -38, 6, 34), Color("8c5c36"))
		draw_rect(Rect2(-74, -38, 6, 34), Color("8c5c36"))
		for py in range(-36, 0, 7):
			draw_rect(Rect2(-111, py, 42, 5), Color("ab7244"))
		draw_rect(Rect2(-114, -36, 48, 3), Color("d9c082"))
		draw_rect(Rect2(-114, -5, 48, 3), Color("d9c082"))
	else:
		# Collapsed middle span with fallen rubble
		draw_rect(Rect2(-112, -8, 18, 6), Color("6e4729"))
		draw_rect(Rect2(-82, -40, 14, 6), Color("6e4729"))
		draw_circle(Vector2(-94, -22), 5.0, Color("485254"))
		draw_circle(Vector2(-82, -18), 4.0, Color("485254"))

	# 5. Mirror Grove Stone Plaza & Light Rays
	draw_circle(Vector2(-132, -152), 40.0, Color("38453d"))
	draw_circle(Vector2(-132, -152), 34.0, Color("4a5750"))
	draw_circle(Vector2(-32, -214), 46.0, Color("384245"))
	draw_circle(Vector2(-32, -214), 38.0, Color("4e595e"))
	if mirror_solved:
		var beam_glow := Color(0.55, 0.94, 0.98, 0.45)
		var beam_core := Color(0.98, 0.92, 0.62, 0.85)
		draw_line(Vector2(-168, -158), Vector2(-32, -216), beam_glow, 4.0)
		draw_line(Vector2(-132, -172), Vector2(-32, -216), beam_glow, 4.0)
		draw_line(Vector2(-96, -158), Vector2(-32, -216), beam_glow, 4.0)
		draw_line(Vector2(-132, -144), Vector2(-32, -216), beam_core, 2.0)
	else:
		# Glowing barrier ring sealing the Beacon before Mirror Grove is solved
		draw_arc(Vector2(-32, -214), 34.0, 0.0, TAU, 32, Color(0.45, 0.86, 0.92, 0.55), 2.0)

	if beacon_activated:
		var pulse_b: float = 1.0 + sin(_anim_time * 2.5) * 0.10
		draw_circle(Vector2(-32, -214), 56.0 * pulse_b, Color(0.42, 0.90, 0.94, 0.14))
		draw_circle(Vector2(-32, -214), 32.0 * pulse_b, Color(1.0, 0.88, 0.52, 0.18))

	# Warm Forest Edge campfire flicker glow & sparse drifting fireflies
	var camp_r: float = 22.0 + sin(_anim_time * 6.0) * 2.5
	draw_circle(Vector2(54, 180), camp_r, Color(1.0, 0.68, 0.25, 0.17))
	draw_circle(Vector2(54, 180), 5.0, Color("ff9e3b"))
	draw_circle(Vector2(54, 179), 2.5, Color("fff0a8"))
	var fireflies := [
		Vector2(-36, 150), Vector2(88, 146), Vector2(-112, 42),
		Vector2(138, 12), Vector2(-72, -138), Vector2(54, -168), Vector2(142, -112),
	]
	for fi in range(fireflies.size()):
		var fpos: Vector2 = fireflies[fi] + Vector2(sin(_anim_time * 1.4 + float(fi) * 1.7) * 9.0, cos(_anim_time * 1.1 + float(fi) * 2.3) * 6.0)
		var f_alpha: float = 0.45 + 0.40 * sin(_anim_time * 3.0 + float(fi))
		draw_rect(Rect2(fpos.round(), Vector2(2, 2)), Color(0.88, 0.98, 0.58, f_alpha))

	# Subtle crisp map labels matching Bellhaven world typography
	var font := ThemeDB.fallback_font
	var labels := [
		[Vector2(-42, 232), "FOREST EDGE"],
		[Vector2(-42, 114), "WHISPERING FORK"],
		[Vector2(118, 120), "WORKSITE"],
		[Vector2(-124, 28), "OLD BRIDGE"],
		[Vector2(-166, -110), "MIRROR GROVE"],
		[Vector2(150, -114), "RUINED CAMP"],
		[Vector2(-64, -162), "FIRST BEACON SHRINE"],
		[Vector2(96, -214), "TO FLOODMILL"],
	]
	for item in labels:
		draw_string(font, item[0], item[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.92, 0.88, 0.72, 0.72))

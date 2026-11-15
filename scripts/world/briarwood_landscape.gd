extends Node2D
## Draws Briarwood Forest dirt trails, ancient flagstones, stream, bridge, mirror beams, and ambient glow.

var bridge_repaired: bool = false
var mirror_solved: bool = false
var beacon_activated: bool = false

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
		draw_line(Vector2(rx, -26), Vector2(rx + 18, -26), Color("67b5cc"), 1.0)
		draw_line(Vector2(rx + 14, -16), Vector2(rx + 34, -16), Color("4f9ab3"), 1.0)
	# Lily pads & stream boulders
	for lx in [-240, -160, 20, 120, 220]:
		draw_circle(Vector2(lx, -16), 4.0, Color("2f693e"))
		draw_circle(Vector2(lx + 1, -17), 1.5, Color("f08c9d"))

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
		draw_circle(Vector2(-32, -214), 56.0, Color(0.42, 0.90, 0.94, 0.14))
		draw_circle(Vector2(-32, -214), 32.0, Color(1.0, 0.88, 0.52, 0.18))

	# Warm Forest Edge campfire ember glow
	draw_circle(Vector2(54, 180), 22.0, Color(1.0, 0.68, 0.25, 0.16))
	draw_circle(Vector2(54, 180), 5.0, Color("ff9e3b"))
	draw_circle(Vector2(54, 179), 2.5, Color("fff0a8"))

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

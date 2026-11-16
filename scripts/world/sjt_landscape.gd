extends Node2D
const FONT = preload("res://assets/fonts/after_hours.tres")

var pedestal_awakened: bool = false
var sunrise_epilogue: bool = false
var _anim_time: float = 0.0
var _redraw_accum: float = 0.0

func _ready() -> void:
	var static_ground := Node2D.new()
	static_ground.name = "StaticGroundDetail"
	static_ground.set_script(preload("res://scripts/world/bellhaven_ground.gd"))
	static_ground.show_behind_parent = true
	add_child(static_ground)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_anim_time = fmod(_anim_time + delta, TAU * 8.0)
	_redraw_accum += delta
	if _redraw_accum >= 0.08:
		_redraw_accum = 0.0
		queue_redraw()

func _draw() -> void:
	# Atmospheric warm lantern/candle pools at Cottage doorstep, Belfry steps, and Rune Pedestal
	var flicker: float = 1.0 + sin(_anim_time * 5.2) * 0.14
	for spot: Array in [[Vector2(-82,24),26,Color(0.96,0.72,0.34,0.11)],[Vector2(30,2),28,Color(0.96,0.76,0.38,0.12)],[Vector2(120,55),24,Color(0.98,0.80,0.36,0.10)]]:
		var pool := PackedVector2Array()
		var r: float = float(spot[1]) * flicker
		for i in range(12):
			pool.append(spot[0] + Vector2(cos(i * TAU / 12) * r, sin(i * TAU / 12) * r * 0.5).round())
		draw_colored_polygon(pool, spot[2])
	if pedestal_awakened:
		var beam := PackedVector2Array([Vector2(120,55),Vector2(75,28),Vector2(25,0),Vector2(-10,25),Vector2(-75,105),Vector2(-155,160),Vector2(-198,178)])
		draw_polyline(beam,Color(0.38,0.85,0.92,0.22),10)
		draw_polyline(beam,Color(0.70,0.96,0.98,0.62),2)
		for m in range(5):
			var mote_y: float = 48.0 - fmod(_anim_time * 12.0 + float(m) * 9.0, 28.0)
			var mote_x: float = 120.0 + sin(_anim_time * 2.0 + float(m)) * 8.0
			draw_rect(Rect2(mote_x, mote_y, 2, 2), Color(0.88, 0.96, 1.0, 0.72))
	if sunrise_epilogue:
		# Warm golden morning sunlight washes across Bellhaven Square in post-game sunrise state
		poly([Vector2(-220, -20), Vector2(260, -140), Vector2(360, 120), Vector2(-120, 240)], Color(1.0, 0.86, 0.52, 0.11))
		for s_pos: Vector2 in [Vector2(-36, 86), Vector2(16, 76), Vector2(30, 148)]:
			var glow := PackedVector2Array()
			for gi in range(12):
				glow.append(s_pos + Vector2(cos(gi * TAU / 12) * 26.0, sin(gi * TAU / 12) * 13.0).round())
			draw_colored_polygon(glow, Color(1.0, 0.88, 0.56, 0.14))

func poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points),color)

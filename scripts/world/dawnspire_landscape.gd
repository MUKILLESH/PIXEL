extends Node2D
## Procedural alpine precipice, storm-cloud horizon, Whispering Cliffs wind zones & shelters,
## deep ravine & counterweight Skybridge deck, Pilgrim's Refuge tiles, Celestial Observatory
## star ring, and Dawnspire Sanctuary three-beacon convergence terrain.
## Redraws throttled at ~12.5 Hz. No oversized permanent ground text labels.

var cliffs_navigated: bool = false
var skybridge_repaired: bool = false
var observatory_solved: bool = false
var beacons_synchronized: bool = false
var great_bell_gate_unlocked: bool = false
var active_cliff_checkpoint_id: String = "cliff_cp_0"
var wind_gust_active: bool = false
var wind_warning_active: bool = false
var wind_strength: float = 0.0

var _anim_phase: float = 0.0
var _redraw_accum: float = 0.0

func _process(delta: float) -> void:
	_anim_phase = fmod(_anim_phase + delta * 1.6, TAU)
	if not Engine.is_editor_hint():
		_redraw_accum += delta
		if _redraw_accum >= 0.08:
			_redraw_accum = 0.0
			queue_redraw()

func _ready() -> void:
	var ground := Sprite2D.new()
	ground.texture = preload("res://scripts/world/dawnspire_art.gd").texture("ground")
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground.show_behind_parent = true
	ground.z_index = -3
	add_child(ground)
	var air := Node2D.new()
	air.set_script(preload("res://scripts/world/dawnspire_air.gd"))
	add_child(air)

func _draw() -> void:
	# 4. Whispering Cliffs Checkpoints (Safe Shelter Stones) & Wind Gust Streaks
	var cps := [
		{"id": "cliff_cp_0", "pos": Vector2(30, 184)},
		{"id": "cliff_cp_1", "pos": Vector2(180, 174)},
		{"id": "cliff_cp_2", "pos": Vector2(210, 74)},
	]
	for cp in cps:
		var cp_pos: Vector2 = cp["pos"]
		var is_active: bool = (active_cliff_checkpoint_id == String(cp["id"]))
		var ring_col := Color("8be6f0") if is_active else Color("7c889e")
		draw_circle(cp_pos, 18.0, Color(0.20, 0.25, 0.34, 0.85))
		draw_arc(cp_pos, 18.0, 0.0, TAU, 24, ring_col, 1.8 if is_active else 1.1)
		draw_circle(cp_pos, 5.0, ring_col)

	# Telegraphed Wind Zone across eastern Whispering Cliffs (x: 118..278, y: 86..196)
	var wind_box := Rect2(118, 86, 160, 110)
	if wind_gust_active and not cliffs_navigated:
		draw_rect(wind_box, Color(0.55, 0.82, 0.96, 0.12))
		for wi in range(7):
			var wy: float = 96.0 + float(wi) * 14.0
			var wx: float = 122.0 + fmod((_anim_phase * 48.0 + float(wi) * 29.0), 130.0)
			draw_line(Vector2(wx, wy), Vector2(wx + 24.0, wy + 2.0), Color(0.84, 0.94, 1.0, 0.55), 1.6)
	elif wind_warning_active and not cliffs_navigated:
		draw_rect(wind_box, Color(0.95, 0.78, 0.42, 0.08))
		for wi in range(5):
			var wy: float = 100.0 + float(wi) * 20.0
			var wx: float = 128.0 + fmod((_anim_phase * 22.0 + float(wi) * 21.0), 120.0)
			draw_line(Vector2(wx, wy), Vector2(wx + 12.0, wy), Color(0.95, 0.84, 0.52, 0.35), 1.0)
	else:
		draw_line(Vector2(280, 78), Vector2(280, 208), Color(0.75, 0.35, 0.38, 0.45), 1.5)

	preload("res://scripts/world/dawnspire_art.gd").bridge(self,skybridge_repaired)
	# 6. Celestial Observatory Star Mandala Ring (centered around x = 204, y = -98)
	var obs_c := Vector2(204, -98)
	var ring_tint := Color("8be6f0") if observatory_solved else Color("6e7894")
	draw_circle(obs_c, 42.0, Color(0.14, 0.17, 0.28, 0.72))
	draw_arc(obs_c, 40.0, 0.0, TAU, 36, ring_tint, 1.5)
	draw_arc(obs_c, 26.0, 0.0, TAU, 30, Color("d4a84f"), 1.2)
	for ai in range(8):
		var ang: float = float(ai) * (PI / 4.0) + (_anim_phase * 0.25 if observatory_solved else 0.0)
		draw_line(obs_c + Vector2(cos(ang), sin(ang)) * 14.0, obs_c + Vector2(cos(ang), sin(ang)) * 38.0, ring_tint, 1.0)
	if not observatory_solved:
		# Sealed Sanctuary stair rune barrier
		draw_line(Vector2(-2, -150), Vector2(50, -150), Color("e67365"), 2.4)
	else:
		# Unsealed golden-cyan stair beam heading north into Dawnspire Sanctuary
		draw_line(obs_c, Vector2(24, -150), Color(0.55, 0.92, 1.0, 0.52), 2.5)
		draw_line(Vector2(24, -150), Vector2(-32, -196), Color(0.98, 0.85, 0.45, 0.58), 2.5)

	# 7. Dawnspire Sanctuary Three-Beacon Convergence Centerpiece (around Vector2(-32, -196))
	var sanc_c := Vector2(-32, -196)
	draw_circle(sanc_c, 34.0, Color(0.16, 0.20, 0.30, 0.80))
	draw_arc(sanc_c, 34.0, 0.0, TAU, 36, Color("ffe38f") if beacons_synchronized else Color("6b7694"), 2.0)
	if beacons_synchronized:
		var pulse_r: float = 16.0 + sin(_anim_phase * 2.0) * 3.0
		draw_arc(sanc_c, pulse_r, 0.0, TAU, 24, Color("8ef5ff"), 1.6)
		# Three incoming Beacon rays from Ashvale valley below (Briarwood, Floodmill, Ironwatch)
		draw_line(Vector2(-150, 40), sanc_c, Color(0.98, 0.82, 0.36, 0.45), 2.0)
		draw_line(Vector2(24, 40), sanc_c, Color(0.45, 0.90, 0.98, 0.45), 2.0)
		draw_line(Vector2(170, 40), sanc_c, Color(0.75, 0.62, 0.98, 0.45), 2.0)
		if great_bell_gate_unlocked:
			draw_line(sanc_c, Vector2(96, -194), Color(0.98, 0.88, 0.48, 0.72), 3.0)

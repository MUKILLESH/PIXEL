extends Node2D
## Draws Ironwatch Keep's basalt flagstones, ruined courtyard statue circle,
## cutaway archive library tiles, Hall of Crests heraldic floor, Shadowed Passage stealth
## lane with glowing Safe Alcoves, and northern Beacon Vault star-mandala.
## No oversized permanent ground text labels (landmarks speak through architecture).

var crest_puzzle_solved: bool = false
var shadow_passage_cleared: bool = false
var third_beacon_activated: bool = false
var active_checkpoint_id: String = "checkpoint_0"
var _pulse_phase: float = 0.0

func _process(delta: float) -> void:
	_pulse_phase = fmod(_pulse_phase + delta * 1.4, TAU)
	if not Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	var stone_dark := Color("1d202b")
	var basalt := Color("282c3a")
	var basalt_light := Color("363c4f")
	var road_trim := Color("43495e")
	var arcane_purple := Color("3b2759")
	var gold_inlay := Color("c99c49")

	# 1. Outer Fortress Foundation & Walkways connecting all 6 wings
	draw_rect(Rect2(-340, -240, 680, 490), Color("12131c"))
	draw_rect(Rect2(-315, -220, 630, 450), stone_dark)

	# Courtyard -> East Archives -> West Barracks -> North Hall of Crests paths
	draw_polyline(PackedVector2Array([Vector2(185, 222), Vector2(120, 185), Vector2(18, 152), Vector2(-18, 25)]), road_trim, 32.0)
	draw_polyline(PackedVector2Array([Vector2(185, 222), Vector2(120, 185), Vector2(18, 152), Vector2(-18, 25)]), basalt, 24.0)
	draw_polyline(PackedVector2Array([Vector2(18, 152), Vector2(-185, 130)]), basalt, 24.0)
	draw_polyline(PackedVector2Array([Vector2(18, 152), Vector2(185, 52)]), basalt, 24.0)
	draw_polyline(PackedVector2Array([Vector2(-18, 25), Vector2(-160, 12), Vector2(-160, -32)]), basalt, 22.0)

	# 2. Fortress Courtyard (Warden Statue Circle Plaza)
	draw_circle(Vector2(18, 152), 54.0, basalt_light)
	draw_circle(Vector2(18, 152), 46.0, basalt)
	for cx in range(-22, 60, 16):
		for cy in range(118, 186, 14):
			draw_rect(Rect2(cx, cy, 12, 10), Color("323747"))
	draw_arc(Vector2(18, 152), 26.0, 0.0, TAU, 32, Color("d4a448"), 1.5)

	# 3. Abandoned Barracks Stone Floor (South-West Wing)
	draw_rect(Rect2(-285, 86, 175, 118), Color("232733"))
	for bx in range(-278, -118, 18):
		for by in range(92, 198, 16):
			draw_rect(Rect2(bx, by, 14, 12), Color("2c303f"))

	# 4. Cutaway Fortress Archives Floor (East Wing)
	draw_rect(Rect2(138, -22, 150, 116), Color("242836"))
	for ax in range(144, 280, 16):
		for ay in range(-16, 86, 14):
			draw_rect(Rect2(ax, ay, 12, 10), Color("2e3345"))
	# Warm candle pool on Archive floor
	draw_circle(Vector2(204, 34), 34.0, Color(0.92, 0.72, 0.34, 0.14))

	# 5. Hall of Crests Arcane Mandala (Center Plaza)
	draw_rect(Rect2(-96, -34, 178, 86), arcane_purple)
	draw_rect(Rect2(-90, -28, 166, 74), Color("241e38"))
	draw_arc(Vector2(-18, 16), 28.0, 0.0, TAU, 32, Color("8be6f0") if crest_puzzle_solved else gold_inlay, 1.5)
	draw_arc(Vector2(-18, 16), 16.0, 0.0, TAU, 24, Color("7b52c9"), 1.5)

	# 6. Shadowed Passage Stealth Corridor (West North-South Lane)
	draw_rect(Rect2(-206, -188, 92, 164), Color("161524"))
	draw_rect(Rect2(-198, -182, 76, 154), Color("1d1c30"))
	# Crimson patrol lane stone strips along sentinel heights
	if not shadow_passage_cleared:
		draw_line(Vector2(-196, -82), Vector2(-124, -82), Color(0.75, 0.24, 0.42, 0.35), 4.0)
		draw_line(Vector2(-196, -136), Vector2(-124, -136), Color(0.75, 0.24, 0.42, 0.35), 4.0)

	# Three glowing Safe Alcove Ward Circles inside Shadowed Passage
	var alcoves := [
		{"id": "checkpoint_0", "pos": Vector2(-160, -48)},
		{"id": "checkpoint_1", "pos": Vector2(-160, -110)},
		{"id": "checkpoint_2", "pos": Vector2(-160, -164)},
	]
	var glow_alpha: float = 0.28 + 0.10 * sin(_pulse_phase)
	for alc in alcoves:
		var p: Vector2 = alc["pos"]
		var is_cp: bool = (alc["id"] == active_checkpoint_id)
		var ring_col := Color("8be6f0") if (is_cp or shadow_passage_cleared) else Color("4fa3b8")
		draw_circle(p, 21.0, Color(0.28, 0.85, 0.92, glow_alpha if is_cp else 0.16))
		draw_arc(p, 20.0, 0.0, TAU, 24, ring_col, 1.6)
		draw_arc(p, 11.0, 0.0, TAU, 18, Color("f0d173") if is_cp else ring_col, 1.0)

	# Portcullis threshold markers (South entry & North exit)
	var entry_col := Color("7be6f0") if crest_puzzle_solved else Color("b84444")
	draw_rect(Rect2(-198, -38, 76, 5), entry_col)
	var exit_col := Color("7be6f0") if shadow_passage_cleared else Color("b84444")
	draw_rect(Rect2(-118, -180, 6, 36), exit_col)

	# 7. Warden's Chamber & Beacon Vault (North Celestial Dais)
	draw_rect(Rect2(-102, -218, 304, 134), Color("1e1a30"))
	draw_rect(Rect2(-94, -210, 288, 118), Color("282242"))
	draw_polyline(PackedVector2Array([Vector2(-150, -164), Vector2(-45, -150), Vector2(70, -148), Vector2(152, -162)]), Color("373059"), 22.0)

	# Star Mandala Dais beneath Third Ancient Beacon
	var dais_center := Vector2(70, -148)
	draw_circle(dais_center, 44.0, Color("312952"))
	draw_arc(dais_center, 42.0, 0.0, TAU, 36, gold_inlay, 2.0)
	draw_arc(dais_center, 28.0, 0.0, TAU, 32, Color("8be6ff") if third_beacon_activated else Color("7b58bd"), 1.5)
	for star_i in range(8):
		var a1: float = float(star_i) * PI * 0.25
		var a2: float = a1 + PI * 0.75
		draw_line(dais_center + Vector2(cos(a1), sin(a1)) * 28.0, dais_center + Vector2(cos(a2), sin(a2)) * 28.0, Color(0.88, 0.72, 0.34, 0.55), 1.0)

	# 8. Connected Three-Beacon Harmonic Lattice Beams (when Third Beacon ignites!)
	if third_beacon_activated:
		var pulse_w: float = 2.6 + 0.8 * sin(_pulse_phase)
		# Briarwood (southwest origin) + Floodmill (southeast origin) converging into Ironwatch Vault!
		var briarwood_ray := Vector2(-260, 210)
		var floodmill_ray := Vector2(280, 210)
		var dawnspire_apex := Vector2(152, -225)
		draw_line(briarwood_ray, dais_center, Color(0.45, 0.90, 1.0, 0.52), pulse_w)
		draw_line(floodmill_ray, dais_center, Color(1.0, 0.84, 0.42, 0.52), pulse_w)
		draw_line(dais_center, dawnspire_apex, Color(0.80, 0.95, 1.0, 0.78), pulse_w + 1.0)
		draw_circle(dais_center, 48.0, Color(0.48, 0.90, 1.0, 0.14))

	# Flanking battlements & northern curtain walls
	draw_rect(Rect2(-335, -238, 670, 16), Color("242736"))
	draw_rect(Rect2(-335, 224, 670, 16), Color("242736"))
	draw_rect(Rect2(-115, -72, 430, 16), Color("262938"))

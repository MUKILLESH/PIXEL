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
var _redraw_accum: float = 0.0

func _ready() -> void:
	if "--bake-ironwatch" in OS.get_cmdline_user_args(): return
	var floor_sprite := Sprite2D.new()
	floor_sprite.texture = load("res://assets/ironwatch/ground.png")
	floor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	floor_sprite.show_behind_parent = true
	add_child(floor_sprite)
	var air := Node2D.new()
	air.set_script(preload("res://scripts/world/ironwatch_air.gd"))
	air.z_index = 2
	add_child(air)

func _process(delta: float) -> void:
	_pulse_phase = fmod(_pulse_phase+delta*1.4,TAU)
	_redraw_accum += delta
	if _redraw_accum >= 0.1:
		_redraw_accum = 0
		queue_redraw()

func _draw() -> void:
	var dais_center := Vector2(70,-148)
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

	if crest_puzzle_solved:
		draw_polyline(PackedVector2Array([Vector2(-53,11),Vector2(-18,-6),Vector2(17,11),Vector2(-18,28),Vector2(-53,11)]),Color("93d8de"),1)
	# Warm torchlight is bounded to the original five positions.
	for p: Vector2 in [Vector2(178,172),Vector2(72,168),Vector2(-206,118),Vector2(152,34),Vector2(132,-172)]:
		draw_colored_polygon(PackedVector2Array([p+Vector2(-18,0),p+Vector2(0,-10),p+Vector2(18,0),p+Vector2(0,10)]),Color(0.98,0.58,0.25,0.14))
		draw_rect(Rect2(p+Vector2(-2,-5),Vector2(4,7)),Color("d69c58"))
		draw_rect(Rect2(p+Vector2(-1,-4-int(sin(_pulse_phase*4))),Vector2(2,5)),Color("ffe8ad"))

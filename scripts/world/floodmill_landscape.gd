extends Node2D
## Draws Floodmill's sunken streets, puddles/reflections, Sluice Canal channels,
## drainable Archive Causeway, cutaway Archive library floor, Sanctuary terrace, and mist.

var watermill_repaired: bool = false
var sluice_gate_states: Array[int] = [0, 0, 0] # 0:CLOSED, 1:DRAIN, 2:DIVERT, 3:OPEN
var sluice_solved: bool = false
var ledger_solved: bool = false
var second_beacon_activated: bool = false
var _mist_phase: float = 0.0
var _redraw_accum: float = 0.0

func _ready() -> void:
	if "--bake-floodmill" in OS.get_cmdline_user_args(): return
	var floor_sprite := Sprite2D.new()
	floor_sprite.texture = load("res://assets/floodmill/ground.png")
	floor_sprite.show_behind_parent = true
	floor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(floor_sprite)
	var air := Node2D.new()
	air.set_script(preload("res://scripts/world/floodmill_air.gd"))
	air.z_index = 2
	add_child(air)

func _process(delta: float) -> void:
	_mist_phase += delta
	_redraw_accum += delta
	if _redraw_accum >= 0.1:
		_redraw_accum = 0
		queue_redraw()

func _draw() -> void:
	for x in range(-650,650,37):
		var shift: int = int(_mist_phase*9)%27
		var y: int = -37+posmod(x*7,12)
		draw_rect(Rect2(x+shift,y,11,1),Color("5b999c"))
		draw_rect(Rect2(x+shift+4,y+2,4,1),Color("87b4ad"))
	for y in range(-14,113,13):
		var p := Vector2(226+posmod(y*7,27),y+int(_mist_phase*9)%9)
		draw_rect(Rect2(p,Vector2(9,1)),Color("a2d0bf") if watermill_repaired else Color("537f86"))
		if watermill_repaired: draw_rect(Rect2(p+Vector2(4,2),Vector2(3,1)),Color("bad7c9"))
	for p: Vector2 in [Vector2(-118,118),Vector2(195,38),Vector2(94,-184)]:
		var length: int = 6+int(sin(_mist_phase*2+p.x)*2)
		for row in range(3):
			draw_rect(Rect2(p+Vector2(-length/2.0,row*3+2),Vector2(length-row,1)),Color(0.8,0.65,0.32,0.25))	# Three readable Weir Channels across the Sluice Canal (West -124, Center -64, East 36)
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

	# Runic response stays below actors; a sparse elevated layer carries beacon energy.
	if second_beacon_activated:
		draw_colored_polygon(PackedVector2Array([Vector2(18,-209),Vector2(64,-232),Vector2(110,-209),Vector2(64,-186)]),Color(0.4,0.85,0.82,0.14))
	# Tiny contact ripples; no full-screen distortion or fluid simulation.
	for p: Vector2 in [Vector2(-74,108),Vector2(-4,62),Vector2(142,118)]:
		var width: int = 7+int(_mist_phase*3)%4
		draw_polyline(PackedVector2Array([p+Vector2(-width,0),p+Vector2(0,-3),p+Vector2(width,0)]),Color("527d7e"),1)

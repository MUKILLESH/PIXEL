extends Panel
## Three-Ring Astronomical Alignment Puzzle for Dawnspire's Celestial Observatory (Chapter 4).

signal celestial_solved_signal()
signal celestial_closed_signal()

const ALIGNMENTS := ["ECLIPSE SHADOW", "FIRST BEACON DAWN", "SECOND BEACON TIDE", "THIRD BEACON CROWN"]
const RING_NAMES := ["SOLAR RING (SUN)", "LUNAR RING (MOON)", "STELLAR RING (STARS)"]
const SOLUTION := [1, 2, 3] # FIRST BEACON DAWN, SECOND BEACON TIDE, THIRD BEACON CROWN

var selections: Array[int] = [0, 0, 0]
var selected_ring: int = 0
var solved: bool = false
var all_clues_found: bool = false
var opened_frame: int = -1
var pulse_time: float = 0.0
var feedback_text: String = "Rotate the three celestial rings to focus Briarwood, Floodmill, and Ironwatch."
var feedback_color: Color = Color("d6c7ad")

var ring_rows: Array[Dictionary] = []
var feedback_label: Label

class AstrolabeCanvas extends Control:
	var owner_panel: Panel
	func _draw() -> void:
		if owner_panel != null:
			owner_panel.draw_celestial_rings(self)

var astrolabe_canvas: Control

func _ready() -> void:
	visible = false
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -268
	offset_right = 268
	offset_top = -134
	offset_bottom = 134

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.11, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.text = "CELESTIAL OBSERVATORY - TRIAD RING ALIGNMENT"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "BIND SUN, MOON, AND STARS RINGS TO THE THREE ANCIENT BEACONS"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9cd6de"))
	add_child(subtitle)

	astrolabe_canvas = AstrolabeCanvas.new()
	astrolabe_canvas.owner_panel = self
	astrolabe_canvas.position = Vector2(16, 52)
	astrolabe_canvas.size = Vector2(164, 174)
	add_child(astrolabe_canvas)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var ring_btn := Button.new()
		ring_btn.text = RING_NAMES[i]
		ring_btn.position = Vector2(188, y_pos)
		ring_btn.size = Vector2(138, 22)
		_style_button(ring_btn)
		ring_btn.pressed.connect(select_ring.bind(i))
		add_child(ring_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(330, y_pos)
		prev_btn.size = Vector2(20, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_rotate_pressed.bind(i, -1))
		add_child(prev_btn)

		var opt_label := Label.new()
		opt_label.position = Vector2(352, y_pos + 6)
		opt_label.size = Vector2(142, 14)
		opt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		opt_label.add_theme_font_size_override("font_size", 8)
		add_child(opt_label)

		var next_btn := Button.new()
		next_btn.text = ">"
		next_btn.position = Vector2(496, y_pos)
		next_btn.size = Vector2(20, 22)
		_style_button(next_btn)
		next_btn.pressed.connect(_on_rotate_pressed.bind(i, 1))
		add_child(next_btn)

		ring_rows.append({
			"ring": ring_btn,
			"opt": opt_label,
		})

	feedback_label = Label.new()
	feedback_label.position = Vector2(188, 158)
	feedback_label.size = Vector2(328, 38)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	var apply_btn := Button.new()
	apply_btn.text = "[ ALIGN OBSERVATORY ]"
	apply_btn.position = Vector2(188, 204)
	apply_btn.size = Vector2(178, 24)
	_style_button(apply_btn)
	apply_btn.pressed.connect(attempt_solve)
	add_child(apply_btn)

	var close_btn := Button.new()
	close_btn.text = "[ CLOSE ]"
	close_btn.position = Vector2(376, 204)
	close_btn.size = Vector2(140, 24)
	_style_button(close_btn)
	close_btn.pressed.connect(close_puzzle)
	add_child(close_btn)

	var controls := Label.new()
	controls.text = "[W/S] RING   [A/D] ROTATE BEACON   [E/ENTER] ALIGN   [ESC] CLOSE"
	controls.position = Vector2(16, 242)
	controls.size = Vector2(504, 14)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 8)
	controls.add_theme_color_override("font_color", Color("9c937e"))
	add_child(controls)
	_refresh()

func _process(delta: float) -> void:
	if visible:
		pulse_time += delta * 2.2
		if astrolabe_canvas != null:
			astrolabe_canvas.queue_redraw()

func _style_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", 8)
	btn.add_theme_color_override("font_color", Color("efe3c8"))
	btn.focus_mode = Control.FOCUS_NONE

func open_puzzle(clues_ok: bool = true, saved_states: Array = []) -> void:
	all_clues_found = clues_ok
	if saved_states.size() == 3:
		selections = [clampi(int(saved_states[0]), 0, 3), clampi(int(saved_states[1]), 0, 3), clampi(int(saved_states[2]), 0, 3)]
	else:
		selections = [0, 0, 0]
	selected_ring = 0
	feedback_color = Color("d6c7ad")
	feedback_text = "Match each astronomical ring to its restored Beacon from the three pillars." if all_clues_found else "Inspect all three celestial pillars around the Observatory first."
	opened_frame = Engine.get_process_frames()
	show()
	_refresh()

func close_puzzle() -> void:
	hide()
	celestial_closed_signal.emit()

func select_ring(idx: int) -> void:
	selected_ring = clampi(idx, 0, 2)
	_refresh()

func rotate_ring(idx: int, delta: int) -> void:
	if solved:
		return
	selected_ring = clampi(idx, 0, 2)
	selections[selected_ring] = posmod(selections[selected_ring] + delta, ALIGNMENTS.size())
	_refresh()

func _on_rotate_pressed(idx: int, delta: int) -> void:
	rotate_ring(idx, delta)

func attempt_solve() -> bool:
	if not all_clues_found:
		feedback_color = Color("e8786d")
		feedback_text = "Incomplete star charts. Inspect all 3 Celestial Pillars around the terrace first."
		_refresh()
		return false
	if selections == SOLUTION:
		solved = true
		feedback_color = Color("8ef5ff")
		feedback_text = "SUN, MOON, AND STARS LOCK! Energy from all three Beacons surges toward Dawnspire Sanctuary!"
		_refresh()
		hide()
		celestial_solved_signal.emit()
		return true
	feedback_color = Color("e8786d")
	feedback_text = "Astronomical gears slip out of phase! Recall: Sun-Dawn, Moon-Tide, Stars-Crown."
	_refresh()
	return false

func _refresh() -> void:
	for i in range(ring_rows.size()):
		var row: Dictionary = ring_rows[i]
		var is_sel: bool = (i == selected_ring)
		var btn: Button = row["ring"]
		var lbl: Label = row["opt"]
		btn.add_theme_color_override("font_color", Color("ffd978") if is_sel else Color("d6c7ad"))
		lbl.text = ALIGNMENTS[selections[i]]
		var ok: bool = (selections[i] == SOLUTION[i])
		lbl.add_theme_color_override("font_color", Color("8ef5ff") if (solved or ok) else (Color("f2deaa") if is_sel else Color("c9d1e0")))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)
	if astrolabe_canvas != null:
		astrolabe_canvas.queue_redraw()

func draw_celestial_rings(c: Control) -> void:
	c.draw_rect(Rect2(0, 0, 164, 174), Color("111524"))
	c.draw_rect(Rect2(2, 2, 160, 170), Color("182036"))
	var center := Vector2(82, 88)
	var radii := [62.0, 44.0, 26.0]
	var ring_cols := [Color("f2c252"), Color("8be6f0"), Color("b994ff")]

	# Zenith sanctuary focus vector
	var all_ok: bool = (selections == SOLUTION)
	c.draw_line(center, Vector2(center.x, 12), Color("8ef5ff") if all_ok else Color("4a546e"), 2.4 if all_ok else 1.2)
	c.draw_circle(Vector2(center.x, 12), 4.0, Color("ffe38f") if all_ok else Color("636e8a"))

	for i in range(3):
		var r: float = radii[i]
		var is_sel: bool = (i == selected_ring)
		var is_ok: bool = (selections[i] == SOLUTION[i])
		var col: Color = ring_cols[i]
		c.draw_arc(center, r, 0.0, TAU, 36, Color("ffffff") if is_sel else col, 2.2 if is_sel else 1.4)
		# Orbiting celestial body indicator rotates by 90 deg per selection state (matches solution at -PI/2 zenith)
		var angle_offset: float = float(selections[i] - SOLUTION[i]) * (PI * 0.5) - PI * 0.5
		var orb := center + Vector2(cos(angle_offset), sin(angle_offset)) * r
		c.draw_circle(orb, 5.5 if is_sel else 4.5, col)
		c.draw_circle(orb, 2.0, Color("ffffff") if is_ok else Color("2b3245"))

	c.draw_circle(center, 9.0, Color("29324d"))
	c.draw_circle(center, 5.0, Color("ffe38f") if all_ok else Color("7c889e"))

func _input(event: InputEvent) -> void:
	if not visible or Engine.get_process_frames() == opened_frame:
		return
	if event.is_echo():
		return
	var vp: Viewport = get_viewport()
	if event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel"):
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
		close_puzzle()
		return
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_W, KEY_UP:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				select_ring(selected_ring - 1)
				return
			KEY_S, KEY_DOWN:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				select_ring(selected_ring + 1)
				return
			KEY_A, KEY_LEFT:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				rotate_ring(selected_ring, -1)
				return
			KEY_D, KEY_RIGHT:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				rotate_ring(selected_ring, 1)
				return
			KEY_E, KEY_ENTER, KEY_KP_ENTER:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				attempt_solve()
				return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
		attempt_solve()

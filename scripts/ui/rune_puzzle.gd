extends Panel
## Concentric three-ring Rune-Alignment Minigame for the Bellhaven Stone Rune Pedestal.

signal puzzle_solved_signal()
signal puzzle_closed_signal()

const SYMBOLS := ["SUN", "MOON", "STAR", "WAVE"]
const RING_NAMES := ["OUTER RING", "MIDDLE RING", "INNER RING"]
const SOLUTION := [1, 0, 2] # MOON, SUN, STAR
const CENTER := Vector2(114, 134)

var discs: Array[int] = [0, 3, 1]
var visual_angles: Array[float] = [0.0, -PI * 0.5, PI * 0.5]
var selected_disc: int = 0
var solved: bool = false
var opened_frame: int = -1
var pulse_time: float = 0.0
var feedback_text: String = "Rotate each stone ring until the matching symbol rests under the golden pointer."
var feedback_color: Color = Color("d6c7ad")

var row_buttons: Array[Dictionary] = []
var feedback_label: Label
var confirm_button: Button
var close_button: Button

func _ready() -> void:
	visible = false
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -236
	offset_right = 236
	offset_top = -132
	offset_bottom = 132

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.08, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.text = "STONE RUNE PEDESTAL - ALIGNMENT CIPHER"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "ALIGN OUTER, MIDDLE, AND INNER SYMBOLS TO THE ZENITH POINTER"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var ring_btn := Button.new()
		ring_btn.text = RING_NAMES[i]
		ring_btn.position = Vector2(216, y_pos)
		ring_btn.size = Vector2(92, 22)
		_style_button(ring_btn)
		ring_btn.pressed.connect(select_disc.bind(i))
		add_child(ring_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(314, y_pos)
		prev_btn.size = Vector2(24, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_rotate_pressed.bind(i, -1))
		add_child(prev_btn)

		var sym_label := Label.new()
		sym_label.position = Vector2(342, y_pos + 6)
		sym_label.size = Vector2(68, 14)
		sym_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sym_label.add_theme_font_size_override("font_size", 8)
		add_child(sym_label)

		var next_btn := Button.new()
		next_btn.text = ">"
		next_btn.position = Vector2(414, y_pos)
		next_btn.size = Vector2(24, 22)
		_style_button(next_btn)
		next_btn.pressed.connect(_on_rotate_pressed.bind(i, 1))
		add_child(next_btn)

		row_buttons.append({
			"ring": ring_btn,
			"sym": sym_label,
		})

	feedback_label = Label.new()
	feedback_label.position = Vector2(216, 158)
	feedback_label.size = Vector2(232, 38)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	confirm_button = Button.new()
	confirm_button.text = "[ ALIGN RUNES ]"
	confirm_button.position = Vector2(216, 204)
	confirm_button.size = Vector2(126, 24)
	_style_button(confirm_button)
	confirm_button.pressed.connect(verify_alignment)
	add_child(confirm_button)

	close_button = Button.new()
	close_button.text = "[ CLOSE ]"
	close_button.position = Vector2(352, 204)
	close_button.size = Vector2(86, 24)
	_style_button(close_button)
	close_button.pressed.connect(close_puzzle)
	add_child(close_button)

	var controls := Label.new()
	controls.text = "W/S RING   A/D ROTATE   E/ENTER ALIGN   ESC CLOSE"
	controls.position = Vector2(16, 240)
	controls.add_theme_font_size_override("font_size", 8)
	controls.add_theme_color_override("font_color", Color("9c937e"))
	add_child(controls)

	_refresh_labels()

func _style_button(btn: Button) -> void:
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 8)
	btn.add_theme_color_override("font_color", Color("e8dbb8"))
	btn.add_theme_color_override("font_hover_color", Color("ffe89e"))
	btn.add_theme_color_override("font_pressed_color", Color("8be6f0"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("191624")
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.border_color = Color("7a633d")
	var hover := normal.duplicate()
	hover.bg_color = Color("262136")
	hover.border_color = Color("d9b366")
	var pressed := normal.duplicate()
	pressed.bg_color = Color("110f18")
	pressed.border_color = Color("8be6f0")
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_stylebox_override("pressed", pressed)

func _process(delta: float) -> void:
	if not visible:
		return
	pulse_time += delta
	for i in range(3):
		var target_angle: float = float(discs[i]) * (PI * 0.5)
		visual_angles[i] = lerp_angle(visual_angles[i], target_angle, minf(1.0, delta * 14.0))
	queue_redraw()

func open_puzzle() -> void:
	if solved:
		return
	discs = [0, 3, 1]
	for i in range(3):
		visual_angles[i] = float(discs[i]) * (PI * 0.5)
	selected_disc = 0
	feedback_text = "Elena's note: Outer MOON, Middle SUN, Inner STAR."
	feedback_color = Color("d6c7ad")
	opened_frame = Engine.get_process_frames()
	visible = true
	_refresh_labels()
	queue_redraw()

func close_puzzle() -> void:
	if not visible:
		return
	visible = false
	puzzle_closed_signal.emit()

func select_disc(disc_index: int) -> void:
	selected_disc = clampi(disc_index, 0, 2)
	_refresh_labels()
	queue_redraw()

func set_disc_symbol(disc_index: int, symbol_name: String) -> void:
	var idx: int = SYMBOLS.find(symbol_name)
	if idx == -1 or disc_index < 0 or disc_index > 2:
		return
	discs[disc_index] = idx
	visual_angles[disc_index] = float(idx) * (PI * 0.5)
	_refresh_labels()
	queue_redraw()

func rotate_disc(disc_index: int, step: int) -> void:
	if solved or disc_index < 0 or disc_index > 2:
		return
	discs[disc_index] = posmod(discs[disc_index] + step, SYMBOLS.size())
	feedback_text = "%s turned to %s." % [RING_NAMES[disc_index], SYMBOLS[discs[disc_index]]]
	feedback_color = Color("d6c7ad")
	_refresh_labels()
	queue_redraw()

func _on_rotate_pressed(disc_index: int, step: int) -> void:
	select_disc(disc_index)
	rotate_disc(disc_index, step)

func verify_alignment() -> bool:
	if solved:
		return false
	if discs == SOLUTION:
		solved = true
		feedback_text = "THE ANCIENT RUNES LOCK INTO HARMONY!"
		feedback_color = Color("8be6f0")
		_refresh_labels()
		queue_redraw()
		visible = false
		puzzle_solved_signal.emit()
		return true
	feedback_text = "Stone grinds stone. The alignment does not hold."
	feedback_color = Color("e6735c")
	_refresh_labels()
	queue_redraw()
	return false

func _refresh_labels() -> void:
	for i in range(row_buttons.size()):
		var entry: Dictionary = row_buttons[i]
		var ring_btn: Button = entry["ring"]
		var sym_lbl: Label = entry["sym"]
		var is_sel: bool = (i == selected_disc)
		ring_btn.add_theme_color_override("font_color", Color("ffe89e") if is_sel else Color("b8b09c"))
		sym_lbl.text = SYMBOLS[discs[i]]
		sym_lbl.add_theme_color_override("font_color", Color("8be6f0") if solved else (Color("ffe89e") if is_sel else Color("e0d4ba")))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	if not ((event is InputEventKey or event is InputEventAction) and event.is_pressed()):
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_disc(posmod(selected_disc - 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_disc(posmod(selected_disc + 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		rotate_disc(selected_disc, -1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		rotate_disc(selected_disc, 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		verify_alignment()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel"):
		close_puzzle()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	# Dark circular pedestal socket
	draw_circle(CENTER, 76.0, Color("14131c"))
	draw_arc(CENTER, 76.0, 0.0, TAU, 32, Color("595043"), 2.0)

	var radii: Array[float] = [66.0, 47.0, 28.0]
	var widths: Array[float] = [16.0, 16.0, 16.0]
	for i in range(3):
		var is_sel: bool = (i == selected_disc)
		var base_color := Color("3b3842") if is_sel else Color("282630")
		var rim_color := Color("ffd466") if (is_sel or solved) else Color("6e6456")
		draw_circle(CENTER, radii[i], base_color)
		draw_arc(CENTER, radii[i], 0.0, TAU, 32, rim_color, 2.0)
		draw_circle(CENTER, radii[i] - widths[i], Color("181721"))

		# Draw all 4 symbols etched around this concentric ring
		var mid_r: float = radii[i] - widths[i] * 0.5
		for sym_idx in range(4):
			var rel_angle: float = float(sym_idx) * (PI * 0.5) - visual_angles[i] - PI * 0.5
			var pos: Vector2 = CENTER + Vector2(cos(rel_angle), sin(rel_angle)) * mid_r
			var at_zenith: bool = (sym_idx == discs[i])
			var glyph_color := Color("8be6f0") if solved else (Color("ffe07d") if at_zenith else Color("7d7668"))
			_draw_symbol(pos.round(), sym_idx, glyph_color)

	# Inner core stone & golden zenith alignment ray
	draw_circle(CENTER, 11.0, Color("2e2c36"))
	draw_circle(CENTER, 4.0, Color("8be6f0") if solved else Color("ffca57"))
	var zenith_top := CENTER + Vector2(0, -82)
	draw_colored_polygon(PackedVector2Array([zenith_top + Vector2(-5, 0), zenith_top + Vector2(5, 0), zenith_top + Vector2(0, 8)]), Color("ffd466"))
	draw_line(CENTER + Vector2(0, -72), CENTER + Vector2(0, -14), Color(0.98, 0.85, 0.45, 0.28), 1.0)

func _draw_symbol(pos: Vector2, sym_idx: int, color: Color) -> void:
	match sym_idx:
		0:
			# SUN: radiant circle with cardinal rays
			draw_rect(Rect2(pos.x - 2, pos.y - 2, 5, 5), color)
			draw_line(pos + Vector2(-4, 0), pos + Vector2(4, 0), color, 1.0)
			draw_line(pos + Vector2(0, -4), pos + Vector2(0, 4), color, 1.0)
		1:
			# MOON: crescent arc
			draw_rect(Rect2(pos.x - 3, pos.y - 3, 4, 7), color)
			draw_rect(Rect2(pos.x, pos.y - 2, 3, 5), Color("181721"))
			draw_rect(Rect2(pos.x - 1, pos.y - 4, 3, 1), color)
			draw_rect(Rect2(pos.x - 1, pos.y + 4, 3, 1), color)
		2:
			# STAR: diamond four-point star
			draw_line(pos + Vector2(0, -4), pos + Vector2(0, 4), color, 1.0)
			draw_line(pos + Vector2(-4, 0), pos + Vector2(4, 0), color, 1.0)
			draw_rect(Rect2(pos.x - 1, pos.y - 1, 3, 3), color)
		3:
			# WAVE: twin horizon tide bars
			draw_line(pos + Vector2(-4, -2), pos + Vector2(4, -2), color, 1.0)
			draw_line(pos + Vector2(-3, 0), pos + Vector2(5, 0), color, 1.0)
			draw_line(pos + Vector2(-4, 2), pos + Vector2(4, 2), color, 1.0)

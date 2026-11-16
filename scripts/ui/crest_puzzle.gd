extends Panel
## Symbolic Logic Puzzle for Ironwatch Keep's Hall of Crests (Chapter 3).

signal crest_solved_signal()
signal crest_closed_signal()

const CRESTS := ["IRON SWORD", "SILVER BELL", "SUNDERED SHIELD", "CROWNED FLAME"]
const PILLAR_NAMES := ["PILLAR I - FIRST", "PILLAR II - SECOND", "PILLAR III - THIRD"]
const SOLUTION := [1, 2, 3] # SILVER BELL, SUNDERED SHIELD, CROWNED FLAME

var selections: Array[int] = [0, 0, 0]
var selected_pillar: int = 0
var solved: bool = false
var all_clues_found: bool = false
var opened_frame: int = -1
var feedback_text: String = "Align each Watch Pillar with the three historical crest clues."
var feedback_color: Color = Color("d6c7ad")

var pillar_rows: Array[Dictionary] = []
var feedback_label: Label

class CrestBoardCanvas extends Control:
	var owner_panel: Panel
	func _draw() -> void:
		if owner_panel != null:
			owner_panel.draw_crest_emblems(self)

var board_canvas: Control

func _ready() -> void:
	visible = false
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -260
	offset_right = 260
	offset_top = -134
	offset_bottom = 134

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.06, 0.11, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.text = "HALL OF CRESTS - HERALDIC SEAL ALIGNMENT"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "MATCH FIRST, SECOND, AND THIRD WATCH EMBLEMS"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("a89bc4"))
	add_child(subtitle)

	board_canvas = CrestBoardCanvas.new()
	board_canvas.owner_panel = self
	board_canvas.position = Vector2(16, 52)
	board_canvas.size = Vector2(164, 174)
	add_child(board_canvas)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var pil_btn := Button.new()
		pil_btn.text = PILLAR_NAMES[i]
		pil_btn.position = Vector2(188, y_pos)
		pil_btn.size = Vector2(124, 22)
		_style_button(pil_btn)
		pil_btn.pressed.connect(select_pillar.bind(i))
		add_child(pil_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(316, y_pos)
		prev_btn.size = Vector2(20, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_cycle_pressed.bind(i, -1))
		add_child(prev_btn)

		var opt_label := Label.new()
		opt_label.position = Vector2(338, y_pos + 6)
		opt_label.size = Vector2(138, 14)
		opt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		opt_label.add_theme_font_size_override("font_size", 8)
		add_child(opt_label)

		var next_btn := Button.new()
		next_btn.text = ">"
		next_btn.position = Vector2(478, y_pos)
		next_btn.size = Vector2(20, 22)
		_style_button(next_btn)
		next_btn.pressed.connect(_on_cycle_pressed.bind(i, 1))
		add_child(next_btn)

		pillar_rows.append({
			"pillar": pil_btn,
			"opt": opt_label,
		})

	feedback_label = Label.new()
	feedback_label.position = Vector2(190, 158)
	feedback_label.size = Vector2(304, 38)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	var apply_btn := Button.new()
	apply_btn.text = "UNSEAL PORTCULLIS [ENTER]"
	apply_btn.position = Vector2(188, 204)
	apply_btn.size = Vector2(176, 24)
	_style_button(apply_btn)
	apply_btn.pressed.connect(attempt_solve)
	add_child(apply_btn)

	var close_btn := Button.new()
	close_btn.text = "CLOSE [ESC]"
	close_btn.position = Vector2(376, 204)
	close_btn.size = Vector2(122, 24)
	_style_button(close_btn)
	close_btn.pressed.connect(close_puzzle)
	add_child(close_btn)

	var controls := Label.new()
	controls.text = "[W/S] PILLAR   [A/D] CREST   [E/ENTER] TEST   [ESC] CLOSE"
	controls.position = Vector2(16, 242)
	controls.size = Vector2(488, 14)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 8)
	controls.add_theme_color_override("font_color", Color("9c937e"))
	add_child(controls)
	_refresh()

func _style_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", 8)
	btn.add_theme_color_override("font_color", Color("efe3c8"))
	btn.focus_mode = Control.FOCUS_NONE

func open_puzzle(clues_found_ok: bool = true) -> void:
	all_clues_found = clues_found_ok
	selections = [0, 0, 0]
	selected_pillar = 0
	feedback_color = Color("d6c7ad")
	feedback_text = "Set Pillars I, II, and III using the Watch tablets from Archives, Barracks, and Stele." if all_clues_found else "Inspect all three historical crest tablets in the Keep first."
	opened_frame = Engine.get_process_frames()
	show()
	_refresh()

func close_puzzle() -> void:
	hide()
	crest_closed_signal.emit()

func select_pillar(idx: int) -> void:
	selected_pillar = clampi(idx, 0, 2)
	_refresh()

func cycle_pillar(idx: int, delta: int) -> void:
	selected_pillar = clampi(idx, 0, 2)
	selections[selected_pillar] = posmod(selections[selected_pillar] + delta, CRESTS.size())
	_refresh()

func _on_cycle_pressed(idx: int, delta: int) -> void:
	cycle_pillar(idx, delta)

func attempt_solve() -> bool:
	if not all_clues_found:
		feedback_color = Color("e8786d")
		feedback_text = "Missing historical tablets. Discover all 3 Watch crest clues first."
		_refresh()
		return false
	if selections == SOLUTION:
		solved = true
		feedback_color = Color("8be6f0")
		feedback_text = "The three Watch crests lock in sapphire resonance! The Shadowed Passage portcullis lifts!"
		_refresh()
		hide()
		crest_solved_signal.emit()
		return true
	feedback_color = Color("e8786d")
	feedback_text = "Stone tumblers grind and reset. Recall: 1st Watch called shelter, 2nd held shield, 3rd swore by flame."
	_refresh()
	return false

func _refresh() -> void:
	for i in range(pillar_rows.size()):
		var row: Dictionary = pillar_rows[i]
		var is_sel: bool = (i == selected_pillar)
		var btn: Button = row["pillar"]
		var lbl: Label = row["opt"]
		btn.add_theme_color_override("font_color", Color("ffd978") if is_sel else Color("d6c7ad"))
		lbl.text = CRESTS[selections[i]]
		var ok: bool = (selections[i] == SOLUTION[i])
		lbl.add_theme_color_override("font_color", Color("8be6f0") if (solved and ok) else (Color("f2deaa") if is_sel else Color("c9d1e0")))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)
	if board_canvas != null:
		board_canvas.queue_redraw()

func draw_crest_emblems(c: Control) -> void:
	c.draw_rect(Rect2(0, 0, 164, 174), Color("161324"))
	c.draw_rect(Rect2(2, 2, 160, 170), Color("201b36"))
	for i in range(3):
		var cy: float = 28.0 + float(i) * 56.0
		var active: bool = (i == selected_pillar)
		var border_col := Color("ffd978") if active else Color("534775")
		c.draw_rect(Rect2(10, cy - 20, 144, 44), border_col)
		c.draw_rect(Rect2(12, cy - 18, 140, 40), Color("18142b"))
		# Shield silhouette
		var sx: float = 34.0
		c.draw_colored_polygon(PackedVector2Array([
			Vector2(sx - 12, cy - 12), Vector2(sx + 12, cy - 12),
			Vector2(sx + 10, cy + 4), Vector2(sx, cy + 14), Vector2(sx - 10, cy + 4)
		]), Color("352d52"))
		var crest_id: int = selections[i]
		match crest_id:
			0: # IRON SWORD
				c.draw_rect(Rect2(sx - 1, cy - 10, 2, 18), Color("9eb0c9"))
				c.draw_rect(Rect2(sx - 6, cy + 3, 12, 2), Color("d9a94e"))
			1: # SILVER BELL
				c.draw_colored_polygon(PackedVector2Array([
					Vector2(sx - 5, cy - 8), Vector2(sx + 5, cy - 8),
					Vector2(sx + 8, cy + 6), Vector2(sx - 8, cy + 6)
				]), Color("d8e6f5"))
				c.draw_circle(Vector2(sx, cy + 8), 2.5, Color("ffd978"))
			2: # SUNDERED SHIELD
				c.draw_rect(Rect2(sx - 7, cy - 8, 6, 15), Color("8895ab"))
				c.draw_rect(Rect2(sx + 2, cy - 7, 6, 15), Color("67738a"))
				c.draw_line(Vector2(sx - 2, cy - 10), Vector2(sx + 2, cy + 10), Color("e8786d"), 2.0)
			3: # CROWNED FLAME
				c.draw_colored_polygon(PackedVector2Array([
					Vector2(sx, cy - 10), Vector2(sx + 6, cy + 4),
					Vector2(sx, cy + 9), Vector2(sx - 6, cy + 4)
				]), Color("ffad42"))
				c.draw_rect(Rect2(sx - 6, cy - 10, 12, 3), Color("ffd978"))
		c.draw_rect(Rect2(58, cy - 6, 84, 3), Color("62528f"))
		c.draw_rect(Rect2(58, cy + 2, 62, 3), Color("8be6f0") if (crest_id == SOLUTION[i]) else Color("4a3f6b"))

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
				select_pillar(selected_pillar - 1)
				return
			KEY_S, KEY_DOWN:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				select_pillar(selected_pillar + 1)
				return
			KEY_A, KEY_LEFT:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				cycle_pillar(selected_pillar, -1)
				return
			KEY_D, KEY_RIGHT:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				cycle_pillar(selected_pillar, 1)
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

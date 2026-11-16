extends Panel
## Mechanical Counterweight & Balance Puzzle for Chapter 4's Broken Skybridge.

signal skybridge_repaired_signal()
signal skybridge_closed_signal()

const OPTIONS := ["GRANITE WEIGHT", "BRONZE PINION", "TENSION CHAIN", "CRACKED BALLAST"]
const BAY_NAMES := ["BAY 1: WEST DRUM", "BAY 2: WINCH MESH", "BAY 3: EAST ANCHOR"]
const SOLUTION := [0, 1, 2] # GRANITE WEIGHT, BRONZE PINION, TENSION CHAIN

var selections: Array[int] = [3, 0, 1]
var selected_bay: int = 0
var repaired: bool = false
var all_parts_ready: bool = false
var opened_frame: int = -1
var feedback_text: String = "Balance the Skybridge counterweights using the Masonry Winch Diagram."
var feedback_color: Color = Color("d6c7ad")

var row_buttons: Array[Dictionary] = []
var feedback_label: Label

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
	style.bg_color = Color(0.06, 0.06, 0.10, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.text = "ANCIENT SKYBRIDGE - COUNTERWEIGHT BALANCE"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "SEAT COUNTERWEIGHT, PINION, AND TENSION ANCHOR IN EQUILIBRIUM"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var bay_btn := Button.new()
		bay_btn.text = BAY_NAMES[i]
		bay_btn.position = Vector2(194, y_pos)
		bay_btn.size = Vector2(124, 22)
		_style_button(bay_btn)
		bay_btn.pressed.connect(select_bay.bind(i))
		add_child(bay_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(322, y_pos)
		prev_btn.size = Vector2(20, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_cycle_pressed.bind(i, -1))
		add_child(prev_btn)

		var opt_label := Label.new()
		opt_label.position = Vector2(344, y_pos + 6)
		opt_label.size = Vector2(132, 14)
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

		row_buttons.append({
			"bay": bay_btn,
			"opt": opt_label,
		})

	feedback_label = Label.new()
	feedback_label.position = Vector2(196, 158)
	feedback_label.size = Vector2(300, 38)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	var confirm_button := Button.new()
	confirm_button.text = "[ BALANCE SKYBRIDGE ]"
	confirm_button.position = Vector2(196, 204)
	confirm_button.size = Vector2(166, 24)
	_style_button(confirm_button)
	confirm_button.pressed.connect(verify_repair)
	add_child(confirm_button)

	var close_button := Button.new()
	close_button.text = "[ CLOSE ]"
	close_button.position = Vector2(370, 204)
	close_button.size = Vector2(126, 24)
	_style_button(close_button)
	close_button.pressed.connect(close_puzzle)
	add_child(close_button)

	var controls := Label.new()
	controls.text = "W/S BAY   A/D COMPONENT   E/ENTER BALANCE   ESC CLOSE"
	controls.position = Vector2(16, 242)
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
	normal.bg_color = Color("181b29")
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 1
	normal.border_color = Color("7a633d")
	var hover := normal.duplicate()
	hover.bg_color = Color("24293d")
	hover.border_color = Color("d9b366")
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("focus", hover)

func open_puzzle(parts_ready: bool = true) -> void:
	if repaired:
		return
	all_parts_ready = parts_ready
	selections = [3, 0, 1]
	selected_bay = 0
	feedback_color = Color("d6c7ad")
	feedback_text = "Seat Granite Weight, Bronze Pinion, and Tension Chain to level the Skybridge." if all_parts_ready else "Recover all 3 Skybridge components and read the diagram first."
	opened_frame = Engine.get_process_frames()
	visible = true
	_refresh_labels()
	queue_redraw()

func close_puzzle() -> void:
	if not visible:
		return
	visible = false
	skybridge_closed_signal.emit()

func select_bay(bay_index: int) -> void:
	selected_bay = clampi(bay_index, 0, 2)
	_refresh_labels()
	queue_redraw()

func rotate_bay(bay_index: int, delta_step: int) -> void:
	if repaired or bay_index < 0 or bay_index > 2:
		return
	selections[bay_index] = posmod(selections[bay_index] + delta_step, OPTIONS.size())
	feedback_text = "%s fitted with %s." % [BAY_NAMES[bay_index], OPTIONS[selections[bay_index]]]
	feedback_color = Color("d6c7ad")
	_refresh_labels()
	queue_redraw()

func _on_cycle_pressed(bay_index: int, delta_step: int) -> void:
	select_bay(bay_index)
	rotate_bay(bay_index, delta_step)

func verify_repair() -> bool:
	if repaired:
		return false
	if not all_parts_ready:
		feedback_text = "Missing counterweight hardware! Recover all 3 bridge parts and inspect the diagram first."
		feedback_color = Color("e6735c")
		_refresh_labels()
		queue_redraw()
		return false
	if selections == SOLUTION:
		repaired = true
		feedback_text = "COUNTERWEIGHTS BALANCED! The Skybridge span rises cleanly into horizontal lock."
		feedback_color = Color("8be6f0")
		_refresh_labels()
		queue_redraw()
		visible = false
		skybridge_repaired_signal.emit()
		return true
	# Reset tilt safely on mistake without penalty
	feedback_text = "The span tilts dangerously over the ravine and resets safely! Check Bay 1->2->3 balance order."
	feedback_color = Color("e6735c")
	_refresh_labels()
	queue_redraw()
	return false

func _refresh_labels() -> void:
	for i in range(row_buttons.size()):
		var entry: Dictionary = row_buttons[i]
		var bay_btn: Button = entry["bay"]
		var opt_lbl: Label = entry["opt"]
		var is_sel: bool = (i == selected_bay)
		bay_btn.add_theme_color_override("font_color", Color("ffe89e") if is_sel else Color("b8b09c"))
		opt_lbl.text = OPTIONS[selections[i]]
		var matches: bool = (selections[i] == SOLUTION[i])
		opt_lbl.add_theme_color_override("font_color", Color("8be6f0") if repaired else (Color("a5e082") if matches else (Color("ffe89e") if is_sel else Color("e0d4ba"))))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
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
				select_bay(posmod(selected_bay - 1, 3))
				return
			KEY_S, KEY_DOWN:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				select_bay(posmod(selected_bay + 1, 3))
				return
			KEY_A, KEY_LEFT:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				rotate_bay(selected_bay, -1)
				return
			KEY_D, KEY_RIGHT:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				rotate_bay(selected_bay, 1)
				return
			KEY_E, KEY_ENTER, KEY_KP_ENTER:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				verify_repair()
				return
			KEY_ESCAPE:
				if vp != null and is_inside_tree():
					vp.set_input_as_handled()
				close_puzzle()
				return
	if not ((event is InputEventKey or event is InputEventAction) and event.is_pressed()):
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_bay(posmod(selected_bay - 1, 3))
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_bay(posmod(selected_bay + 1, 3))
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		rotate_bay(selected_bay, -1)
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		rotate_bay(selected_bay, 1)
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		verify_repair()
		if vp != null and is_inside_tree():
			vp.set_input_as_handled()

func _draw() -> void:
	var box := Rect2(18, 56, 164, 168)
	draw_rect(box, Color("0f1522"))
	draw_rect(box, Color("595043"), false, 2.0)

	# Chasm silhouette & twin stone anchor piers
	draw_rect(Rect2(26, 74, 24, 134), Color("364054"))
	draw_rect(Rect2(150, 74, 24, 134), Color("364054"))

	# Balance tilt reflects left/right match vs mistake
	var left_ok: int = 1 if selections[0] == SOLUTION[0] else 0
	var mid_ok: int = 1 if selections[1] == SOLUTION[1] else 0
	var right_ok: int = 1 if selections[2] == SOLUTION[2] else 0
	var tilt_y: float = float(left_ok - right_ok) * -14.0 if (left_ok + mid_ok + right_ok) < 3 else 0.0
	var p_left := Vector2(44, 132.0 + tilt_y)
	var p_mid := Vector2(100, 132.0)
	var p_right := Vector2(156, 132.0 - tilt_y)

	# Skybridge balance beam & cables
	var span_col := Color("8be6f0") if (left_ok + mid_ok + right_ok) == 3 else Color("c78e46")
	draw_line(p_left, p_right, span_col, 5.0)
	draw_line(Vector2(38, 86), p_left, Color("d9b366") if left_ok == 1 else Color("6e685f"), 2.0)
	draw_line(Vector2(162, 86), p_right, Color("d9b366") if right_ok == 1 else Color("6e685f"), 2.0)

	# Center fulcrum drum
	draw_circle(p_mid, 14.0, Color("293245"))
	draw_circle(p_mid, 14.0, Color("a5e082") if mid_ok == 1 else Color("e09648"), false, 2.0)
	draw_circle(p_left, 9.0, Color("a5e082") if left_ok == 1 else Color("8a7659"))
	draw_circle(p_right, 9.0, Color("a5e082") if right_ok == 1 else Color("8a7659"))

	# Equilibrium spirit-level gauge at top of diagram
	draw_rect(Rect2(52, 66, 96, 10), Color("1b2230"))
	var level_col := Color("8be6f0") if (left_ok + mid_ok + right_ok) == 3 else Color("e6735c")
	draw_rect(Rect2(96 - clampf(tilt_y * 2.0, -34.0, 34.0), 68, 8, 6), level_col)

	# Selection indicator dot beside chosen bay
	var focus_pt: Vector2 = [p_left, p_mid, p_right][selected_bay]
	draw_circle(focus_pt, 16.0, Color("ffd978"), false, 1.5)

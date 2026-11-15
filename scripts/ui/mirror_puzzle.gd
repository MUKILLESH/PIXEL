extends Panel
## Mirror Grove three-mirror light alignment minigame unlocking the First Ancient Beacon.

signal mirror_solved_signal()
signal mirror_closed_signal()

const ANGLES := ["HORIZON", "DAWN", "ZENITH", "DUSK"]
const MIRROR_NAMES := ["WEST MIRROR", "CENTER MIRROR", "EAST MIRROR"]
const SOLUTION := [1, 2, 3] # DAWN, ZENITH, DUSK

var mirrors: Array[int] = [0, 0, 1]
var selected_mirror: int = 0
var solved: bool = false
var opened_frame: int = -1
var feedback_text: String = "Inscriptions: West DAWN, Center ZENITH, East DUSK."
var feedback_color: Color = Color("d6c7ad")

var row_buttons: Array[Dictionary] = []
var feedback_label: Label

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
	title.text = "MIRROR GROVE - BEACON LIGHT MATRIX"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "ANGLE ALL THREE MIRRORS TO CHANNEL LIGHT INTO THE SHRINE RECEPTORS"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var mirror_btn := Button.new()
		mirror_btn.text = MIRROR_NAMES[i]
		mirror_btn.position = Vector2(204, y_pos)
		mirror_btn.size = Vector2(96, 22)
		_style_button(mirror_btn)
		mirror_btn.pressed.connect(select_mirror.bind(i))
		add_child(mirror_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(304, y_pos)
		prev_btn.size = Vector2(22, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_rotate_pressed.bind(i, -1))
		add_child(prev_btn)

		var ang_label := Label.new()
		ang_label.position = Vector2(328, y_pos + 6)
		ang_label.size = Vector2(88, 14)
		ang_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ang_label.add_theme_font_size_override("font_size", 8)
		add_child(ang_label)

		var next_btn := Button.new()
		next_btn.text = ">"
		next_btn.position = Vector2(418, y_pos)
		next_btn.size = Vector2(22, 22)
		_style_button(next_btn)
		next_btn.pressed.connect(_on_rotate_pressed.bind(i, 1))
		add_child(next_btn)

		row_buttons.append({
			"mirror": mirror_btn,
			"angle": ang_label,
		})

	feedback_label = Label.new()
	feedback_label.position = Vector2(204, 158)
	feedback_label.size = Vector2(246, 38)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	var confirm_button := Button.new()
	confirm_button.text = "[ CHANNEL LIGHT ]"
	confirm_button.position = Vector2(204, 204)
	confirm_button.size = Vector2(138, 24)
	_style_button(confirm_button)
	confirm_button.pressed.connect(verify_mirrors)
	add_child(confirm_button)

	var close_button := Button.new()
	close_button.text = "[ CLOSE ]"
	close_button.position = Vector2(352, 204)
	close_button.size = Vector2(88, 24)
	_style_button(close_button)
	close_button.pressed.connect(close_puzzle)
	add_child(close_button)

	var controls := Label.new()
	controls.text = "W/S MIRROR   A/D ANGLE   E/ENTER CHANNEL   ESC CLOSE"
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

func open_puzzle() -> void:
	if solved:
		return
	mirrors = [0, 0, 1]
	selected_mirror = 0
	feedback_text = "Inscriptions: West DAWN, Center ZENITH, East DUSK."
	feedback_color = Color("d6c7ad")
	opened_frame = Engine.get_process_frames()
	visible = true
	_refresh_labels()
	queue_redraw()

func close_puzzle() -> void:
	if not visible:
		return
	visible = false
	mirror_closed_signal.emit()

func select_mirror(mirror_index: int) -> void:
	selected_mirror = clampi(mirror_index, 0, 2)
	_refresh_labels()
	queue_redraw()

func set_mirror_angle(mirror_index: int, angle_name: String) -> void:
	var idx: int = ANGLES.find(angle_name)
	if idx == -1 or mirror_index < 0 or mirror_index > 2:
		return
	mirrors[mirror_index] = idx
	_refresh_labels()
	queue_redraw()

func rotate_mirror(mirror_index: int, delta_step: int) -> void:
	if solved or mirror_index < 0 or mirror_index > 2:
		return
	mirrors[mirror_index] = posmod(mirrors[mirror_index] + delta_step, ANGLES.size())
	feedback_text = "%s turned to %s." % [MIRROR_NAMES[mirror_index], ANGLES[mirrors[mirror_index]]]
	feedback_color = Color("d6c7ad")
	_refresh_labels()
	queue_redraw()

func _on_rotate_pressed(mirror_index: int, delta_step: int) -> void:
	select_mirror(mirror_index)
	rotate_mirror(mirror_index, delta_step)

func verify_mirrors() -> bool:
	if solved:
		return false
	if mirrors == SOLUTION:
		solved = true
		feedback_text = "THE THREE RECEPTORS IGNITE! THE SHRINE BARRIER DISSOLVES."
		feedback_color = Color("8be6f0")
		_refresh_labels()
		queue_redraw()
		visible = false
		mirror_solved_signal.emit()
		return true
	feedback_text = "The beam scatters across moss. Match all three inscribed solar angles."
	feedback_color = Color("e6735c")
	_refresh_labels()
	queue_redraw()
	return false

func _refresh_labels() -> void:
	for i in range(row_buttons.size()):
		var entry: Dictionary = row_buttons[i]
		var m_btn: Button = entry["mirror"]
		var a_lbl: Label = entry["angle"]
		var is_sel: bool = (i == selected_mirror)
		m_btn.add_theme_color_override("font_color", Color("ffe89e") if is_sel else Color("b8b09c"))
		a_lbl.text = ANGLES[mirrors[i]]
		var ok: bool = (mirrors[i] == SOLUTION[i])
		a_lbl.add_theme_color_override("font_color", Color("8be6f0") if solved else (Color("a5e082") if ok else (Color("ffe89e") if is_sel else Color("e0d4ba"))))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	if not ((event is InputEventKey or event is InputEventAction) and event.is_pressed()):
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_mirror(posmod(selected_mirror - 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_mirror(posmod(selected_mirror + 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		rotate_mirror(selected_mirror, -1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		rotate_mirror(selected_mirror, 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		verify_mirrors()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel"):
		close_puzzle()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	var box := Rect2(20, 56, 168, 166)
	draw_rect(box, Color("131a18"))
	draw_rect(box, Color("595043"), false, 2.0)

	# Shrine receptor crystal at top-center
	var shrine_pos := Vector2(104, 78)
	var m_pos := [Vector2(54, 152), Vector2(104, 184), Vector2(154, 152)]
	var r_pos := [Vector2(54, 102), Vector2(104, 122), Vector2(154, 102)]

	# Source sun-well beam to all 3 mirrors
	for i in range(3):
		var ok: bool = (mirrors[i] == SOLUTION[i])
		draw_line(shrine_pos + Vector2(0, 124), m_pos[i], Color("5a6e63"), 1.0)
		var ray_dir: Vector2 = Vector2.UP.rotated((float(mirrors[i]) - 2.0) * 0.65)
		var end_pt: Vector2 = r_pos[i] if ok else (m_pos[i] + ray_dir * 34.0)
		var beam_color := Color("8be6f0") if (solved or ok) else Color("c9974c")
		draw_line(m_pos[i], end_pt, beam_color, 2.0)
		if ok:
			draw_line(r_pos[i], shrine_pos, Color("8be6f0"), 2.0)
		# Receptor & mirror plinths
		draw_circle(r_pos[i], 6.0, Color("8be6f0") if ok else Color("3b4248"))
		draw_rect(Rect2(m_pos[i].x - 8, m_pos[i].y - 5, 16, 10), Color("4c565e"))
		draw_line(m_pos[i] + ray_dir.rotated(PI * 0.5) * -7.0, m_pos[i] + ray_dir.rotated(PI * 0.5) * 7.0, Color("e8dbb8"), 2.0)
		if i == selected_mirror:
			draw_circle(m_pos[i], 13.0, Color("ffd466"), false, 1.0)

	draw_circle(shrine_pos, 10.0, Color("8be6f0") if (mirrors == SOLUTION or solved) else Color("4a545e"))
	draw_circle(shrine_pos, 14.0, Color("8be6f0") if (mirrors == SOLUTION or solved) else Color("787066"), false, 1.5)

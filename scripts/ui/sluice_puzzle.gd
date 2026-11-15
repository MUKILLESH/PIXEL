extends Panel
## Deterministic Sluice-Gate Water Flow Control puzzle for Floodmill Canal.

signal sluice_solved_signal()
signal sluice_closed_signal()
signal sluice_states_changed(states: Array[int])

const GATE_STATES := ["CLOSED", "DRAIN", "DIVERT", "OPEN"]
const GATE_NAMES := ["WEST WEIR", "CENTER LOCK", "EAST SPILLWAY"]
const SOLUTION := [2, 1, 3] # DIVERT, DRAIN, OPEN

var states: Array[int] = [0, 0, 0]
var selected_gate: int = 0
var solved: bool = false
var opened_frame: int = -1
var feedback_text: String = "Gauge clue: WEST DIVERT, CENTER DRAIN, EAST SPILLWAY OPEN."
var feedback_color: Color = Color("d6c7ad")

var row_buttons: Array[Dictionary] = []
var level_label: Label
var feedback_label: Label

func _ready() -> void:
	visible = false
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	offset_left = -244
	offset_right = 244
	offset_top = -134
	offset_bottom = 134

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.08, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.78, 0.62, 0.36, 1)
	add_theme_stylebox_override("panel", style)

	var title := Label.new()
	title.text = "FLOODMILL CANAL - SLUICE GATE CONTROL"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "LOWER THE ARCHIVE CAUSEWAY WATER LEVEL TO 0 CUBITS"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var g_btn := Button.new()
		g_btn.text = GATE_NAMES[i]
		g_btn.position = Vector2(204, y_pos)
		g_btn.size = Vector2(106, 22)
		_style_button(g_btn)
		g_btn.pressed.connect(select_gate.bind(i))
		add_child(g_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(314, y_pos)
		prev_btn.size = Vector2(22, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_cycle_pressed.bind(i, -1))
		add_child(prev_btn)

		var state_lbl := Label.new()
		state_lbl.position = Vector2(338, y_pos + 6)
		state_lbl.size = Vector2(88, 14)
		state_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		state_lbl.add_theme_font_size_override("font_size", 8)
		add_child(state_lbl)

		var next_btn := Button.new()
		next_btn.text = ">"
		next_btn.position = Vector2(428, y_pos)
		next_btn.size = Vector2(22, 22)
		_style_button(next_btn)
		next_btn.pressed.connect(_on_cycle_pressed.bind(i, 1))
		add_child(next_btn)

		row_buttons.append({
			"gate": g_btn,
			"state": state_lbl,
		})

	level_label = Label.new()
	level_label.position = Vector2(204, 150)
	level_label.size = Vector2(256, 16)
	level_label.add_theme_font_size_override("font_size", 8)
	add_child(level_label)

	feedback_label = Label.new()
	feedback_label.position = Vector2(204, 168)
	feedback_label.size = Vector2(256, 32)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	var confirm_button := Button.new()
	confirm_button.text = "[ ENGAGE SLUICES ]"
	confirm_button.position = Vector2(204, 206)
	confirm_button.size = Vector2(144, 24)
	_style_button(confirm_button)
	confirm_button.pressed.connect(verify_sluice)
	add_child(confirm_button)

	var close_button := Button.new()
	close_button.text = "[ CLOSE ]"
	close_button.position = Vector2(356, 206)
	close_button.size = Vector2(96, 24)
	_style_button(close_button)
	close_button.pressed.connect(close_puzzle)
	add_child(close_button)

	var controls := Label.new()
	controls.text = "W/S GATE   A/D POSITION   E/ENTER ENGAGE   ESC CLOSE"
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

func open_puzzle(saved_states: Array = []) -> void:
	if solved:
		return
	if saved_states.size() == 3:
		states = [clampi(int(saved_states[0]), 0, 3), clampi(int(saved_states[1]), 0, 3), clampi(int(saved_states[2]), 0, 3)]
	else:
		states = [0, 0, 0]
	selected_gate = 0
	feedback_text = "Gauge clue: WEST DIVERT, CENTER DRAIN, EAST SPILLWAY OPEN."
	feedback_color = Color("d6c7ad")
	opened_frame = Engine.get_process_frames()
	visible = true
	_refresh_labels()
	queue_redraw()

func close_puzzle() -> void:
	if not visible:
		return
	visible = false
	sluice_closed_signal.emit()

func select_gate(gate_index: int) -> void:
	selected_gate = clampi(gate_index, 0, 2)
	_refresh_labels()
	queue_redraw()

func set_gate_state(gate_index: int, state_name: String) -> void:
	var idx: int = GATE_STATES.find(state_name)
	if idx == -1 or gate_index < 0 or gate_index > 2:
		return
	states[gate_index] = idx
	sluice_states_changed.emit(states.duplicate())
	_refresh_labels()
	queue_redraw()

func rotate_gate(gate_index: int, delta_step: int) -> void:
	if solved or gate_index < 0 or gate_index > 2:
		return
	states[gate_index] = posmod(states[gate_index] + delta_step, GATE_STATES.size())
	feedback_text = "%s turned to %s." % [GATE_NAMES[gate_index], GATE_STATES[states[gate_index]]]
	feedback_color = Color("d6c7ad")
	sluice_states_changed.emit(states.duplicate())
	_refresh_labels()
	queue_redraw()

func _on_cycle_pressed(gate_index: int, delta_step: int) -> void:
	select_gate(gate_index)
	rotate_gate(gate_index, delta_step)

func get_archive_water_level() -> int:
	# Deterministic hydraulic calculation: base 6 cubits, -2 per properly routed channel
	var level: int = 6
	if states[0] == 2: # WEST DIVERT removes inflow (-2)
		level -= 2
	elif states[0] == 3:
		level += 1
	if states[1] == 1: # CENTER DRAIN empties causeway basin (-2)
		level -= 2
	if states[2] == 3: # EAST SPILLWAY OPEN vents pressure into mill tailrace (-2)
		level -= 2
	elif states[2] == 0:
		level += 1
	return clampi(level, 0, 8)

func verify_sluice() -> bool:
	if solved:
		return false
	if states == SOLUTION and get_archive_water_level() == 0:
		solved = true
		feedback_text = "CANAL DRAINED - THE ARCHIVE STONE CAUSEWAY IS CLEAR!"
		feedback_color = Color("8be6f0")
		_refresh_labels()
		queue_redraw()
		visible = false
		sluice_solved_signal.emit()
		return true
	var depth: int = get_archive_water_level()
	feedback_text = "Archive steps still sit %d cubits deep! Divert West, Drain Center, Open East Spillway." % depth
	feedback_color = Color("e6735c")
	_refresh_labels()
	queue_redraw()
	return false

func _refresh_labels() -> void:
	for i in range(row_buttons.size()):
		var entry: Dictionary = row_buttons[i]
		var g_btn: Button = entry["gate"]
		var s_lbl: Label = entry["state"]
		var is_sel: bool = (i == selected_gate)
		g_btn.add_theme_color_override("font_color", Color("ffe89e") if is_sel else Color("b8b09c"))
		s_lbl.text = GATE_STATES[states[i]]
		var matches: bool = (states[i] == SOLUTION[i])
		s_lbl.add_theme_color_override("font_color", Color("8be6f0") if solved else (Color("a5e082") if matches else (Color("ffe89e") if is_sel else Color("e0d4ba"))))
	if level_label != null:
		var depth: int = 0 if solved else get_archive_water_level()
		level_label.text = "ARCHIVE CAUSEWAY WATER DEPTH: %d CUBITS" % depth
		level_label.add_theme_color_override("font_color", Color("8be6f0") if depth == 0 else Color("ffbe52"))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	if not ((event is InputEventKey or event is InputEventAction) and event.is_pressed()):
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_gate(posmod(selected_gate - 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_gate(posmod(selected_gate + 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		rotate_gate(selected_gate, -1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		rotate_gate(selected_gate, 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		verify_sluice()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel"):
		close_puzzle()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	# Left hydraulic channel schematic
	var box := Rect2(18, 56, 172, 168)
	draw_rect(box, Color("141a24"))
	draw_rect(box, Color("595043"), false, 2.0)

	# Three parallel stone weir channels feeding bottom causeway gauge
	var depth: int = 0 if solved else get_archive_water_level()
	for i in range(3):
		var cx: int = 44 + i * 48
		draw_rect(Rect2(cx - 12, 66, 24, 96), Color("2b3438"))
		var matches: bool = (states[i] == SOLUTION[i])
		var water_col := Color("67d4e6") if matches else (Color("245973") if states[i] > 0 else Color("17303d"))
		draw_rect(Rect2(cx - 8, 70, 16, 88), water_col)
		# Gate bar across middle
		var bar_y: int = 104 - states[i] * 5
		draw_rect(Rect2(cx - 11, bar_y, 22, 6), Color("ffd466") if i == selected_gate else Color("b8a88a"))

	# Bottom Archive Causeway water gauge basin
	draw_rect(Rect2(28, 172, 152, 42), Color("283036"))
	var fill_h: int = clampi(depth * 5, 0, 36)
	if fill_h > 0:
		draw_rect(Rect2(32, 210 - fill_h, 144, fill_h), Color("215b70"))
		draw_line(Vector2(34, 210 - fill_h), Vector2(174, 210 - fill_h), Color("8be6f0"), 1.5)
	else:
		draw_rect(Rect2(32, 198, 144, 12), Color("66706b"))
		draw_line(Vector2(34, 198), Vector2(174, 198), Color("8be6f0"), 1.5)

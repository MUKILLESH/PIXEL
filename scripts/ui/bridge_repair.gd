extends Panel
## Self-contained Bridge Repair sequencing minigame for Briarwood's collapsed Old Bridge.

signal bridge_repaired_signal()
signal bridge_closed_signal()

const OPTIONS := ["LEFT BEAM", "RIGHT PLANK", "ROPE LASHING", "LOOSE TIMBER"]
const STEP_NAMES := ["STEP 1: SUPPORT", "STEP 2: WALKWAY", "STEP 3: BINDING"]
const SOLUTION := [0, 1, 2] # LEFT BEAM -> RIGHT PLANK -> ROPE LASHING

var selections: Array[int] = [1, 3, 0]
var selected_step: int = 0
var repaired: bool = false
var opened_frame: int = -1
var feedback_text: String = "Worksite ledger: 1. LEFT BEAM, 2. RIGHT PLANK, 3. ROPE LASHING."
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
	title.text = "OLD BRIDGE - CARPENTER REPAIR PLAN"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("f2deaa"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "SET THE TIMBER BEAM, WALKWAY PLANK, AND ROPE LASHING IN ORDER"
	subtitle.position = Vector2(16, 26)
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color("9c937e"))
	add_child(subtitle)

	for i in range(3):
		var y_pos: int = 56 + i * 32
		var step_btn := Button.new()
		step_btn.text = STEP_NAMES[i]
		step_btn.position = Vector2(204, y_pos)
		step_btn.size = Vector2(96, 22)
		_style_button(step_btn)
		step_btn.pressed.connect(select_step.bind(i))
		add_child(step_btn)

		var prev_btn := Button.new()
		prev_btn.text = "<"
		prev_btn.position = Vector2(304, y_pos)
		prev_btn.size = Vector2(22, 22)
		_style_button(prev_btn)
		prev_btn.pressed.connect(_on_cycle_pressed.bind(i, -1))
		add_child(prev_btn)

		var opt_label := Label.new()
		opt_label.position = Vector2(328, y_pos + 6)
		opt_label.size = Vector2(88, 14)
		opt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		opt_label.add_theme_font_size_override("font_size", 8)
		add_child(opt_label)

		var next_btn := Button.new()
		next_btn.text = ">"
		next_btn.position = Vector2(418, y_pos)
		next_btn.size = Vector2(22, 22)
		_style_button(next_btn)
		next_btn.pressed.connect(_on_cycle_pressed.bind(i, 1))
		add_child(next_btn)

		row_buttons.append({
			"step": step_btn,
			"opt": opt_label,
		})

	feedback_label = Label.new()
	feedback_label.position = Vector2(204, 158)
	feedback_label.size = Vector2(246, 38)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 8)
	add_child(feedback_label)

	var confirm_button := Button.new()
	confirm_button.text = "[ SECURE BRIDGE ]"
	confirm_button.position = Vector2(204, 204)
	confirm_button.size = Vector2(138, 24)
	_style_button(confirm_button)
	confirm_button.pressed.connect(verify_repair)
	add_child(confirm_button)

	var close_button := Button.new()
	close_button.text = "[ CLOSE ]"
	close_button.position = Vector2(352, 204)
	close_button.size = Vector2(88, 24)
	_style_button(close_button)
	close_button.pressed.connect(close_puzzle)
	add_child(close_button)

	var controls := Label.new()
	controls.text = "W/S STEP   A/D MATERIAL   E/ENTER SECURE   ESC CLOSE"
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
	if repaired:
		return
	selections = [1, 3, 0]
	selected_step = 0
	feedback_text = "Worksite ledger: 1. LEFT BEAM, 2. RIGHT PLANK, 3. ROPE LASHING."
	feedback_color = Color("d6c7ad")
	opened_frame = Engine.get_process_frames()
	visible = true
	_refresh_labels()
	queue_redraw()

func close_puzzle() -> void:
	if not visible:
		return
	visible = false
	bridge_closed_signal.emit()

func select_step(step_index: int) -> void:
	selected_step = clampi(step_index, 0, 2)
	_refresh_labels()
	queue_redraw()

func set_step_material(step_index: int, mat_name: String) -> void:
	var idx: int = OPTIONS.find(mat_name)
	if idx == -1 or step_index < 0 or step_index > 2:
		return
	selections[step_index] = idx
	_refresh_labels()
	queue_redraw()

func rotate_step(step_index: int, delta_step: int) -> void:
	if repaired or step_index < 0 or step_index > 2:
		return
	selections[step_index] = posmod(selections[step_index] + delta_step, OPTIONS.size())
	feedback_text = "%s set to %s." % [STEP_NAMES[step_index], OPTIONS[selections[step_index]]]
	feedback_color = Color("d6c7ad")
	_refresh_labels()
	queue_redraw()

func _on_cycle_pressed(step_index: int, delta_step: int) -> void:
	select_step(step_index)
	rotate_step(step_index, delta_step)

func verify_repair() -> bool:
	if repaired:
		return false
	if selections == SOLUTION:
		repaired = true
		feedback_text = "TIMBER LOCKED AND ROPE BOUND FAST!"
		feedback_color = Color("8be6f0")
		_refresh_labels()
		queue_redraw()
		visible = false
		bridge_repaired_signal.emit()
		return true
	feedback_text = "The span shifts unsteadily. Set beam support before planks and rope."
	feedback_color = Color("e6735c")
	_refresh_labels()
	queue_redraw()
	return false

func _refresh_labels() -> void:
	for i in range(row_buttons.size()):
		var entry: Dictionary = row_buttons[i]
		var step_btn: Button = entry["step"]
		var opt_lbl: Label = entry["opt"]
		var is_sel: bool = (i == selected_step)
		step_btn.add_theme_color_override("font_color", Color("ffe89e") if is_sel else Color("b8b09c"))
		opt_lbl.text = OPTIONS[selections[i]]
		var matches_step: bool = (selections[i] == SOLUTION[i])
		opt_lbl.add_theme_color_override("font_color", Color("8be6f0") if repaired else (Color("a5e082") if matches_step else (Color("ffe89e") if is_sel else Color("e0d4ba"))))
	if feedback_label != null:
		feedback_label.text = feedback_text
		feedback_label.add_theme_color_override("font_color", feedback_color)

func _input(event: InputEvent) -> void:
	if not visible or event.is_echo() or Engine.get_process_frames() == opened_frame:
		return
	if not ((event is InputEventKey or event is InputEventAction) and event.is_pressed()):
		return
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		select_step(posmod(selected_step - 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		select_step(posmod(selected_step + 1, 3))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		rotate_step(selected_step, -1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		rotate_step(selected_step, 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		verify_repair()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dismiss") or event.is_action_pressed("ui_cancel"):
		close_puzzle()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	# Bridge schematic box on the left side
	var box := Rect2(20, 56, 168, 166)
	draw_rect(box, Color("141a24"))
	draw_rect(box, Color("595043"), false, 2.0)

	# Stream flowing through center of schematic
	draw_rect(Rect2(22, 108, 164, 58), Color("22536e"))
	draw_rect(Rect2(34, 126, 26, 2), Color("67b5cc"))
	draw_rect(Rect2(118, 146, 30, 2), Color("67b5cc"))

	# North & south stone bridgeheads
	draw_rect(Rect2(72, 62, 64, 46), Color("595652"))
	draw_rect(Rect2(72, 166, 64, 52), Color("595652"))

	# Step 1 visualization: LEFT BEAM support
	var step1_ok: bool = (selections[0] == 0)
	var beam_col := Color("a87444") if step1_ok else Color("4d433b")
	draw_rect(Rect2(78, 100, 10, 74), beam_col)
	draw_rect(Rect2(120, 100, 10, 74), beam_col if step1_ok else Color("3b342e"))

	# Step 2 visualization: RIGHT PLANK walkway
	if selections[1] == 1:
		for py in range(106, 166, 12):
			draw_rect(Rect2(74, py, 60, 8), Color("c48a52"))

	# Step 3 visualization: ROPE LASHING knots
	if selections[2] == 2:
		draw_rect(Rect2(76, 105, 56, 4), Color("e2c98d"))
		draw_rect(Rect2(76, 161, 56, 4), Color("e2c98d"))

	# Active step indicator frame
	var highlight_y: int = [100, 118, 152][selected_step]
	draw_rect(Rect2(70, highlight_y, 68, 22), Color("ffd466"), false, 1.0)
